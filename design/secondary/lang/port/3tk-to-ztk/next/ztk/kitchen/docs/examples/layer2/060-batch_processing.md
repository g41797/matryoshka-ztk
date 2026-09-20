# Batch processing

## Description

Batch processing.

- Main sends 10 Events, then a ShutdownCommand sentinel.
- Worker blocks on the first item via mbx.receive.
- Worker then empties the rest with mbx.receiveAll.
- Sentinel found in either place ends the worker.

## Diagram

```
 main ──Event×10 + ShutdownCommand──► mailbox
      │
 worker: receive (first item) ──► destroySlot
         receiveAll (rest) ──► walk + destroyItem
         (ShutdownCommand in batch → exit)
```

## Source

```zig
pub fn batch_processing(allocator: std.mem.Allocator, io: std.Io) !void {
    var mbx_slot: Slot = null;
    try matryoshka.mbox.new(allocator, io, &mbx_slot);
    const mbx: *Mbox = Mbox.moveFromSlot(&mbx_slot).?;
    defer {
        var rem: matryoshka.queue.Queue = mbx.close();
        items.destroyQueue(&rem, allocator, io);
        mbx.destroy();
    }

    var ctx: WorkerCtx = .{ .mbx = mbx, .alloc = allocator, .io = io };
    var fut = try io.concurrent(batchWorkerFn, .{&ctx});

    const n: usize = 10;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        var slot: Slot = null;
        defer items.Event.EventHelper.destroy(allocator, io, &slot);
        try items.Event.EventHelper.create(allocator, io, &slot);
        items.Event.EventHelper.mustFromSlot(&slot).code = @intCast(i);
        try mbx.send(&slot);
    }

    // Signal worker to stop — all n items are already queued before this.
    {
        var slot: Slot = null;
        defer items.ShutdownCommand.ShutdownCommandHelper.destroy(allocator, io, &slot);
        try items.ShutdownCommand.ShutdownCommandHelper.create(allocator, io, &slot);
        try mbx.send(&slot);
    }

    fut.await(io);

    const total = ctx.first_count + ctx.batch_count;
    std.log.info("batch: first={d} batch={d} total={d}", .{ ctx.first_count, ctx.batch_count, total });
    try helpers.expect(error.BatchProcessingFailed, total == n, "wrong total");
    try helpers.expect(error.BatchProcessingFailed, ctx.first_count > 0, "no items received as first");
}

const WorkerCtx = struct {
    mbx: *Mbox,
    alloc: std.mem.Allocator,
    io: std.Io,
    first_count: usize = 0,
    batch_count: usize = 0,
};

fn batchWorkerFn(ctx: *WorkerCtx) void {
    while (true) {
        var slot: Slot = null;
        ctx.mbx.receive(&slot, null) catch return;
        const item: *Inner = slot.?;

        if (items.ShutdownCommand.ShutdownCommandHelper.fromInner(item)) |_| {
            items.destroySlot(&slot, ctx.alloc, ctx.io);
            return;
        }

        items.destroySlot(&slot, ctx.alloc, ctx.io);
        ctx.first_count += 1;

        var batch: matryoshka.queue.Queue = ctx.mbx.receiveAll() catch return;
        while (batch.popFirst()) |queued| {
            if (items.ShutdownCommand.ShutdownCommandHelper.fromInner(queued)) |_| {
                {
                    var s: Slot = queued;
                    items.destroySlot(&s, ctx.alloc, ctx.io);
                }
                return;
            }
            {
                var s: Slot = queued;
                items.destroySlot(&s, ctx.alloc, ctx.io);
            }
            ctx.batch_count += 1;
        }
    }
}

const items = @import("../items/items.zig");
const helpers = @import("../helpers/helpers.zig");
const matryoshka = @import("matryoshka");
const std = @import("std");
const Mbox = matryoshka.Mbox;
const Inner = matryoshka.inner.Inner;
const Slot = matryoshka.inner.Slot;
```
