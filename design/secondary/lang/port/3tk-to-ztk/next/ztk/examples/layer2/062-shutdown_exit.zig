// SPDX-FileCopyrightText: Copyright (c) 2026 g41797
// SPDX-License-Identifier: MIT

//! Shutdown via ShutdownCommand.
//!
//! - Main sends 3 Events, then a ShutdownCommand outer.
//! - Worker processes each Event, exits cleanly on the sentinel.
//! - Mailbox stays open throughout — worker owns every item it received.
//!
//!
//! ```
//!  main ──Event×3──► mailbox ──► worker (processes, destroySlot)
//!  main ──ShutdownCommand──► mailbox ──► worker (exits, destroySlot)
//!  (mailbox stays open; worker owns all received items)
//! ```
//!

pub fn shutdown_via_shutdowncommand(allocator: std.mem.Allocator, io: std.Io) !void {
    var mbx_slot: Slot = null;
    try matryoshka.mbox.new(allocator, io, &mbx_slot);
    const mbx: *Mbox = Mbox.moveFromSlot(&mbx_slot).?;

    defer {
        var rem: matryoshka.queue.Queue = mbx.close();
        items.destroyQueue(&rem, allocator, io);
        mbx.destroy();
    }

    var ctx: WorkerCtx = .{ .mbx = mbx, .alloc = allocator, .io = io };
    var fut = try io.concurrent(workerFn, .{&ctx});

    const codes = [_]i32{ 10, 20, 30 };
    for (codes) |code| {
        var slot: Slot = null;
        defer items.Event.EventHelper.destroy(allocator, io, &slot);
        try items.Event.EventHelper.create(allocator, io, &slot);
        items.Event.EventHelper.mustFromSlot(&slot).code = code;
        try mbx.send(&slot);
    }

    // Send shutdown signal — mailbox stays open.
    {
        var slot: Slot = null;
        defer items.ShutdownCommand.ShutdownCommandHelper.destroy(allocator, io, &slot);
        try items.ShutdownCommand.ShutdownCommandHelper.create(allocator, io, &slot);
        try mbx.send(&slot);
    }

    fut.await(io);

    std.log.info("shutdown_exit: worker processed {d} items before ShutdownCommand", .{ctx.processed});
    try helpers.expect(error.ShutdownExitFailed, ctx.processed == 3, "wrong processed count");
}

const WorkerCtx = struct {
    mbx: *Mbox,
    alloc: std.mem.Allocator,
    io: std.Io,
    processed: usize = 0,
};

fn workerFn(ctx: *WorkerCtx) void {
    while (true) {
        var slot: Slot = null;
        defer items.destroySlot(&slot, ctx.alloc, ctx.io);
        ctx.mbx.receive(&slot, null) catch return;
        const item: *Inner = slot.?;
        if (items.ShutdownCommand.ShutdownCommandHelper.fromInner(item)) |_| {
            std.log.info("worker: ShutdownCommand received, exiting cleanly", .{});
            return;
        } else if (items.Event.EventHelper.fromInner(item)) |ev| {
            std.log.debug("worker: Event code={d}", .{ev.*.code});
            ctx.processed += 1;
        } else if (items.Sensor.SensorHelper.fromInner(item)) |sn| {
            std.log.debug("worker: Sensor value={d:.1}", .{sn.*.value});
            ctx.processed += 1;
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
