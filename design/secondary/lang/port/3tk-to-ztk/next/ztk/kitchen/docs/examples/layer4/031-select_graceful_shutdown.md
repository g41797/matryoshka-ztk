# Graceful shutdown with in-flight items

## Description

Graceful shutdown with in-flight items.

- Master has 2 event sources: mailbox (Events + ShutdownCommand) and pool.
- eventLoop processes Events, then a ShutdownCommand triggers graceful shutdown.
- gracefulShutdown empties sel.cancel(), frees inbox items, recycles pool items.
- No item is lost across cancellation, at whatever stage each source was in.

## Diagram

```
 mbx (Event items + ShutdownCommand)    pool (Event items)
 │ receiveResult                         │ getWaitResult
 └──────────────────────┬───────────────┘
                        ▼
                Select(MasterEvent) ◄── sleepFn (timer)
                        │ event loop
                        ▼
 .inbox .item (Event)   ──► process, re-spawn inbox
 .inbox .item (Shutdown)──► initiate graceful shutdown:
                             sel.cancel() loop
                             .inbox  .item ──► freeSlot   (no item lost)
                             .pool_ev .item──► pl.put    (no item lost)
 sel.cancelDiscard() ──► pl.close ──► mbx.close
```

## Source

```zig
pub fn graceful_shutdown_with_in_flight_items(allocator: std.mem.Allocator, io: std.Io) !void {
    const master = try GracefulShutdownMaster.init(allocator, io);
    defer master.destroy();
    try master.run();
}

const TIMER_NS: i96 = 30_000_000; // 30 ms
const N_EVENTS: usize = 2;

const MasterEvent = union(enum) {
    inbox: Mbox.Result,
    pool_ev: Pool.Result,
    timer: void,
};

fn sleepFn(sleep_t: std.Io.Timeout, io: std.Io) void {
    std.Io.Timeout.sleep(sleep_t, io) catch {};
}

const GracefulShutdownMaster = struct {
    fn run(self: *GracefulShutdownMaster) !void {
        try self.seedResources();
        try self.eventLoop();
        self.gracefulShutdown();
        try helpers.expect(error.SelectGracefulShutdownFailed, self.shutdown_seen, "shutdown command not received");
        try helpers.expect(error.SelectGracefulShutdownFailed, self.events_processed == N_EVENTS, "events not all processed");
        std.log.info("done: events={d}, freed_inbox={d}, recycled_pool={d}", .{ self.events_processed, self.freed_inbox, self.recycled_pool });
    }

    fn seedResources(self: *GracefulShutdownMaster) !void {
        for (0..N_EVENTS) |i| {
            var slot: Slot = null;
            defer items.Event.EventHelper.destroy(self.allocator, self.io, &slot);
            try items.Event.EventHelper.create(self.allocator, self.io, &slot);
            items.Event.EventHelper.mustFromSlot(&slot).code = @intCast(i + 1);
            try self.mbx.send(&slot);
        }
        {
            var slot: Slot = null;
            defer items.ShutdownCommand.ShutdownCommandHelper.destroy(self.allocator, self.io, &slot);
            try items.ShutdownCommand.ShutdownCommandHelper.create(self.allocator, self.io, &slot);
            try self.mbx.send(&slot);
        }
        {
            var slot: Slot = null;
            try self.pl.get(items.Event.EventHelper.ID, .new_only, &slot);
            items.Event.EventHelper.mustFromSlot(&slot).code = 99;
            try self.pl.put(&slot);
        }
    }

    fn eventLoop(self: *GracefulShutdownMaster) !void {
        const sleep_t: std.Io.Timeout = .{
            .duration = .{ .raw = .{ .nanoseconds = TIMER_NS }, .clock = .real },
        };
        try self.sel.concurrent(.inbox, matryoshka.mbox.receiveResult, .{ self.mbx, null });
        try self.sel.concurrent(.pool_ev, matryoshka.pool.getWaitResult, .{ self.pl, items.Event.EventHelper.ID, null });
        try self.sel.concurrent(.timer, sleepFn, .{ sleep_t, self.io });

        outer: while (true) {
            const event: MasterEvent = try self.sel.await();
            switch (event) {
                .inbox => |r| switch (r) {
                    .item => |handle| {
                        if (items.Event.EventHelper.fromInner(handle)) |ev| {
                            var slot: Slot = handle;
                            defer items.destroySlot(&slot, self.allocator, self.io);
                            self.events_processed += 1;
                            std.log.info("inbox: Event code={d}", .{ev.code});
                            try self.sel.concurrent(.inbox, matryoshka.mbox.receiveResult, .{ self.mbx, null });
                        } else if (items.ShutdownCommand.ShutdownCommandHelper.fromInner(handle)) |_| {
                            var slot: Slot = handle;
                            items.destroySlot(&slot, self.allocator, self.io);
                            std.log.info("inbox: ShutdownCommand — initiating graceful shutdown", .{});
                            self.shutdown_seen = true;
                            break :outer;
                        } else {
                            var slot: Slot = handle;
                            items.destroySlot(&slot, self.allocator, self.io);
                        }
                    },
                    .closed, .canceled, .timeout, .wakeup => break :outer,
                },
                .pool_ev => |r| switch (r) {
                    .item => |handle| {
                        var slot: Slot = handle;
                        defer self.pl.put(&slot) catch unreachable;
                        std.log.info("pool_ev: item received", .{});
                        try self.sel.concurrent(.pool_ev, matryoshka.pool.getWaitResult, .{ self.pl, items.Event.EventHelper.ID, null });
                    },
                    .closed, .canceled, .timeout, .unknown_identity => {},
                },
                .timer => {
                    std.log.info("timer: tick", .{});
                    try self.sel.concurrent(.timer, sleepFn, .{ sleep_t, self.io });
                },
            }
        }
    }

    fn gracefulShutdown(self: *GracefulShutdownMaster) void {
        while (self.sel.cancel()) |event| {
            switch (event) {
                .inbox => |r| switch (r) {
                    .item => |handle| {
                        var slot: Slot = handle;
                        items.destroySlot(&slot, self.allocator, self.io);
                        self.freed_inbox += 1;
                        std.log.info("graceful cancel: freed inbox item", .{});
                    },
                    .canceled, .closed, .timeout, .wakeup => {},
                },
                .pool_ev => |r| switch (r) {
                    .item => |handle| {
                        var slot: Slot = handle;
                        self.pl.put(&slot) catch unreachable;
                        self.recycled_pool += 1;
                        std.log.info("graceful cancel: recycled pool item", .{});
                    },
                    .canceled, .closed, .timeout, .unknown_identity => {},
                },
                .timer => {},
            }
        }
    }

    allocator: std.mem.Allocator,
    io: std.Io,
    mbx: *Mbox,
    pl: *Pool,
    pool_ctx: hooks.AlwaysCreateHooks,
    ids: [1]OuterId,
    events_processed: usize,
    shutdown_seen: bool,
    freed_inbox: usize,
    recycled_pool: usize,
    buf: [8]MasterEvent,
    sel: std.Io.Select(MasterEvent),

    fn init(allocator: std.mem.Allocator, io: std.Io) !*GracefulShutdownMaster {
        const self = try allocator.create(GracefulShutdownMaster);
        errdefer allocator.destroy(self);
        self.allocator = allocator;
        self.io = io;
        self.events_processed = 0;
        self.shutdown_seen = false;
        self.freed_inbox = 0;
        self.recycled_pool = 0;

        var mbx_slot: Slot = null;
        try matryoshka.mbox.new(allocator, io, &mbx_slot);
        self.mbx = Mbox.moveFromSlot(&mbx_slot).?;
        errdefer {
            var rem: Queue = self.mbx.close();
            items.destroyQueue(&rem, allocator, io);
            self.mbx.destroy();
        }
        self.pool_ctx = .{ .alloc = allocator, .io = io };
        self.ids = .{items.Event.EventHelper.ID};

        var pl_slot: Slot = null;
        try matryoshka.pool.new(allocator, io, &self.ids, self.pool_ctx.poolHooks(), &pl_slot);
        self.pl = Pool.moveFromSlot(&pl_slot).?;
        errdefer {
            self.pl.close();
            self.pl.destroy();
        }
        self.sel = std.Io.Select(MasterEvent).init(self.io, &self.buf);
        return self;
    }

    fn destroy(self: *GracefulShutdownMaster) void {
        var rem: Queue = self.mbx.close();
        items.destroyQueue(&rem, self.allocator, self.io);
        self.mbx.destroy();
        self.pl.close();
        self.pl.destroy();
        self.allocator.destroy(self);
    }
};

const items = @import("../items/items.zig");
const hooks = @import("../hooks/hooks.zig");
const helpers = @import("../helpers/helpers.zig");
const matryoshka = @import("matryoshka");
const std = @import("std");
const Mbox = matryoshka.Mbox;
const Pool = matryoshka.Pool;
const OuterId = matryoshka.inner.OuterId;
const Queue = matryoshka.queue.Queue;
const Slot = matryoshka.inner.Slot;
```
