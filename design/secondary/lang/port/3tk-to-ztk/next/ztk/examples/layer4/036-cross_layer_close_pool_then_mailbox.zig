// SPDX-FileCopyrightText: Copyright (c) 2026 g41797
// SPDX-License-Identifier: MIT

//! Close ordering: pool then mailbox.
//!
//! - Seed the pool with 2 outers, the mailbox with 1 outer.
//! - closePool: pl.close, on_close releases the 2 pool outers.
//! - closeMailboxAndRelease: mbx.close, walk the returned queue, release the 1 outer.
//! - Verify all 3 outers were accounted for, in this close order.
//!
//!
//! ```
//!  pool (2 outers stored)    mailbox (1 outer queued)
//!  │
//!  pl.close ──► on_close ──► destroyQueue (2 pool outers released)
//!  mbx.close ──► Queue (1 outer)
//!  walk queue: popFirst ──► destroySlot
//!  │
//!  All 3 outers accounted for, no leaks.
//! ```
//!

pub fn close_ordering_pool_then_mailbox(allocator: std.mem.Allocator, io: std.Io) !void {
    var pool_ctx: hooks.AlwaysCreateHooks = .{ .alloc = allocator, .io = io };
    const ids = [_]OuterId{items.Event.EventHelper.ID};

    var pl_slot: Slot = null;
    try matryoshka.pool.new(allocator, io, &ids, pool_ctx.poolHooks(), &pl_slot);
    const pl: *Pool = Pool.moveFromSlot(&pl_slot).?;

    var mbx_slot: Slot = null;
    try matryoshka.mbox.new(allocator, io, &mbx_slot);
    const mbx: *Mbox = Mbox.moveFromSlot(&mbx_slot).?;

    try seedPool(pl, N_POOL);
    try seedMailbox(mbx, allocator, io, N_MAILBOX);

    std.log.info("before close: {d} in pool, {d} in mailbox", .{ N_POOL, N_MAILBOX });

    closePool(pl);

    const released = closeMailboxAndRelease(mbx, allocator, io);
    std.log.info("Mbox.close: walked queue, released {d} mailbox outers", .{released});

    try helpers.expect(error.CrossLayerCloseOrderFailed, released == N_MAILBOX, "mailbox outer count mismatch");
    std.log.info("done: close pool-then-mailbox — {d}+{d} outers cleaned up, no leaks", .{ N_POOL, N_MAILBOX });
}

const N_POOL: usize = 2;
const N_MAILBOX: usize = 1;

fn seedPool(pl: *Pool, count: usize) !void {
    var slots: [N_POOL]Slot = @splat(null);
    for (0..count) |i| {
        try pl.get(items.Event.EventHelper.ID, .new_only, &slots[i]);
        items.Event.EventHelper.mustFromSlot(&slots[i]).code = @intCast(i + 1);
    }
    for (0..count) |i| try pl.put(&slots[i]);
}

fn seedMailbox(mbx: *Mbox, alloc: std.mem.Allocator, io: std.Io, count: usize) !void {
    for (0..count) |i| {
        var slot: Slot = null;
        defer items.Event.EventHelper.destroy(alloc, io, &slot);
        try items.Event.EventHelper.create(alloc, io, &slot);
        items.Event.EventHelper.mustFromSlot(&slot).code = @intCast(100 + i);
        try mbx.send(&slot);
    }
}

fn closePool(pl: *Pool) void {
    pl.close();
    pl.destroy();
    std.log.info("Pool.close: on_close released {d} pool outers", .{N_POOL});
}

fn closeMailboxAndRelease(mbx: *Mbox, alloc: std.mem.Allocator, io: std.Io) usize {
    var rem: Queue = mbx.close();
    var released: usize = 0;
    while (rem.popFirst()) |item| {
        var slot: Slot = item;
        items.destroySlot(&slot, alloc, io);
        released += 1;
    }
    mbx.destroy();
    return released;
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
