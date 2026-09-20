# Close ordering: mailbox then pool

## Description

Close ordering: mailbox then pool.

- Seed the pool with 1 outer, the mailbox with 1 outer.
- closeMailbox closes the mailbox, returns its queue.
- returnCloseQueueToPool walks that queue, puts each outer in the still-open pool.
- pl.close (deferred) then releases both outers via on_close.

## Diagram

```
 pool (1 outer stored)    mailbox (1 outer queued)
 │
 mbx.close ──► Queue (1 outer)
 walk queue: popFirst ──► slot ──► pl.put (pool still open)
 │                                     └──► pool store (now 2 outers)
 pl.close ──► on_close ──► destroyQueue (both outers released)
 │
 Verify: pool received the outer from the mailbox close queue.
```

## Source

```zig
pub fn close_ordering_mailbox_then_pool(allocator: std.mem.Allocator, io: std.Io) !void {
    var pool_ctx: hooks.AlwaysCreateHooks = .{ .alloc = allocator, .io = io };
    const ids = [_]OuterId{items.Event.EventHelper.ID};

    var pl_slot: Slot = null;
    try matryoshka.pool.new(allocator, io, &ids, pool_ctx.poolHooks(), &pl_slot);
    const pl: *Pool = Pool.moveFromSlot(&pl_slot).?;
    defer {
        pl.close();
        pl.destroy();
    }

    var mbx_slot: Slot = null;
    try matryoshka.mbox.new(allocator, io, &mbx_slot);
    const mbx: *Mbox = Mbox.moveFromSlot(&mbx_slot).?;

    try seedPool(pl);
    try seedMailbox(mbx, allocator, io);
    std.log.info("before close: 1 outer in pool, 1 outer in mailbox", .{});

    var rem: Queue = closeMailbox(mbx);
    const returned = try returnCloseQueueToPool(pl, &rem);

    try helpers.expect(error.CrossLayerCloseOrderFailed, returned == 1, "expected 1 outer from mailbox close");
    std.log.info("pool now has 2 outers — Pool.close will release all via on_close", .{});
    // Deferred pl.close calls on_close with both outers.
}

fn seedPool(pl: *Pool) !void {
    var slot: Slot = null;
    try pl.get(items.Event.EventHelper.ID, .new_only, &slot);
    items.Event.EventHelper.mustFromSlot(&slot).code = 1;
    try pl.put(&slot);
}

fn seedMailbox(mbx: *Mbox, alloc: std.mem.Allocator, io: std.Io) !void {
    var slot: Slot = null;
    defer items.Event.EventHelper.destroy(alloc, io, &slot);
    try items.Event.EventHelper.create(alloc, io, &slot);
    items.Event.EventHelper.mustFromSlot(&slot).code = 2;
    try mbx.send(&slot);
}

fn closeMailbox(mbx: *Mbox) Queue {
    const rem: Queue = mbx.close();
    mbx.destroy();
    return rem;
}

fn returnCloseQueueToPool(pl: *Pool, rem: *Queue) !usize {
    var returned: usize = 0;
    while (rem.popFirst()) |item| {
        var slot: Slot = item;
        std.log.info("mailbox close queue: returning outer to pool (code={d})", .{items.Event.EventHelper.mustFromSlot(&slot).code});
        try pl.put(&slot);
        returned += 1;
    }
    return returned;
}

const items = @import("../items/items.zig");
const hooks = @import("../hooks/hooks.zig");
const helpers = @import("../helpers/helpers.zig");
const matryoshka = @import("matryoshka");
const std = @import("std");
const Mbox = matryoshka.Mbox;
const OuterId = matryoshka.inner.OuterId;
const Pool = matryoshka.Pool;
const Queue = matryoshka.queue.Queue;
const Slot = matryoshka.inner.Slot;
```
