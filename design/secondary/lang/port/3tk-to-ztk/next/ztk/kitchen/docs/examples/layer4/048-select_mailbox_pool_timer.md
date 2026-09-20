# Mixed mailbox + pool event sources in Select

## Description

Mixed mailbox + pool event sources in Select.

- Mailbox pre-loaded with 2 Events, pool seeded with 1 Event, both are Select sources.
- eventLoop handles each with a uniform switch, re-spawning after mailbox items.
- Timer ticks independently; the loop exits once both targets are met.

## Diagram

```
 mailbox (pre-loaded: Event×2)   pool (seeded: Event×1)
    │ receiveResult                  │ getWaitResult
    └────────────┬───────────────────┘
                 ▼
        Select(MasterEvent) ◄── sleepFn (timer)
                 │ sel.await()
                 ▼
 .inbox .item ──► freeSlot
 .pool_ev .item ──► pl.put
 .timer         ──► log tick, re-spawn
 done when inbox×2 + pool×1 received ──► sel.cancelDiscard()
```

## Source

```zig
pub fn mixed_mailbox_pool_event_sources_in_select(allocator: std.mem.Allocator, io: std.Io) !void {
    const master = try MailboxPoolTimerMaster.init(allocator, io);
    defer master.destroy();
    try master.run();
}

const TIMER_NS: i96 = 20_000_000; // 20 ms

const MasterEvent = union(enum) {
    inbox: Mbox.Result,
    pool_ev: Pool.Result,
    timer: void,
};

fn sleepFn(sleep_t: std.Io.Timeout, io: std.Io) void {
    std.Io.Timeout.sleep(sleep_t, io) catch {};
}

const MailboxPoolTimerMaster = struct {
    fn timerTimeout() std.Io.Timeout {
        return .{ .duration = .{ .raw = .{ .nanoseconds = TIMER_NS }, .clock = .real } };
    }

    fn run(self: *MailboxPoolTimerMaster) !void {
        try self.setupSelect();
        try self.eventLoop();
        try helpers.expect(error.SelectMailboxPoolTimerFailed, self.inbox_count == 2, "mailbox items mismatch");
        try helpers.expect(error.SelectMailboxPoolTimerFailed, self.pool_count == 1, "pool items mismatch");
        std.log.info("done: inbox={d}, pool={d}, ticks={d}", .{ self.inbox_count, self.pool_count, self.ticks });
    }

    fn setupSelect(self: *MailboxPoolTimerMaster) !void {
        try self.sel.concurrent(.inbox, matryoshka.mbox.receiveResult, .{ self.mbx, null });
        try self.sel.concurrent(.pool_ev, matryoshka.pool.getWaitResult, .{ self.pl, items.Event.EventHelper.ID, null });
        try self.sel.concurrent(.timer, sleepFn, .{ timerTimeout(), self.io });
    }

    fn eventLoop(self: *MailboxPoolTimerMaster) !void {
        while (self.inbox_count < 2 or self.pool_count < 1) {
            const event: MasterEvent = try self.sel.await();
            switch (event) {
                .inbox => |r| switch (r) {
                    .item => |handle| {
                        var slot: Slot = handle;
                        defer items.destroySlot(&slot, self.allocator, self.io);
                        const ev: *items.Event = items.Event.EventHelper.mustFromSlot(&slot);
                        self.inbox_count += 1;
                        std.log.info("inbox: Event code={d} ({d}/2)", .{ ev.code, self.inbox_count });
                        if (self.inbox_count < 2) {
                            try self.sel.concurrent(.inbox, matryoshka.mbox.receiveResult, .{ self.mbx, null });
                        }
                    },
                    .closed, .canceled, .timeout, .wakeup => break,
                },
                .pool_ev => |r| switch (r) {
                    .item => |handle| {
                        var slot: Slot = handle;
                        defer self.pl.put(&slot) catch unreachable;
                        const ev: *items.Event = items.Event.EventHelper.mustFromSlot(&slot);
                        self.pool_count += 1;
                        std.log.info("pool_ev: Event code={d} ({d}/1)", .{ ev.code, self.pool_count });
                    },
                    .closed, .canceled, .timeout, .unknown_identity => break,
                },
                .timer => {
                    self.ticks += 1;
                    std.log.info("timer: tick {d}", .{self.ticks});
                    try self.sel.concurrent(.timer, sleepFn, .{ timerTimeout(), self.io });
                },
            }
        }
        self.sel.cancelDiscard();
    }

    allocator: std.mem.Allocator,
    io: std.Io,
    mbx: *Mbox,
    pl: *Pool,
    pool_ctx: hooks.AlwaysCreateHooks,
    ids: [1]OuterId,
    inbox_count: usize,
    pool_count: usize,
    ticks: usize,
    buf: [8]MasterEvent,
    sel: std.Io.Select(MasterEvent),

    fn init(allocator: std.mem.Allocator, io: std.Io) !*MailboxPoolTimerMaster {
        const self = try allocator.create(MailboxPoolTimerMaster);
        errdefer allocator.destroy(self);
        self.allocator = allocator;
        self.io = io;
        self.inbox_count = 0;
        self.pool_count = 0;
        self.ticks = 0;

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
        try self.seedResources();
        self.sel = std.Io.Select(MasterEvent).init(self.io, &self.buf);
        return self;
    }

    fn destroy(self: *MailboxPoolTimerMaster) void {
        var rem: Queue = self.mbx.close();
        items.destroyQueue(&rem, self.allocator, self.io);
        self.mbx.destroy();
        self.pl.close();
        self.pl.destroy();
        self.allocator.destroy(self);
    }

    fn seedResources(self: *MailboxPoolTimerMaster) !void {
        for (0..2) |i| {
            var slot: Slot = null;
            defer items.Event.EventHelper.destroy(self.allocator, self.io, &slot);
            try items.Event.EventHelper.create(self.allocator, self.io, &slot);
            items.Event.EventHelper.mustFromSlot(&slot).code = @intCast(i + 1);
            try self.mbx.send(&slot);
        }
        {
            var slot: Slot = null;
            try self.pl.get(items.Event.EventHelper.ID, .new_only, &slot);
            items.Event.EventHelper.mustFromSlot(&slot).code = 10;
            try self.pl.put(&slot);
        }
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
