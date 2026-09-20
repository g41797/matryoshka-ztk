// SPDX-FileCopyrightText: Copyright (c) 2026 g41797
// SPDX-License-Identifier: MIT

//! Fan-in.
//!
//! - 3 concurrent senders: Events, Sensors, and a mixed sender.
//! - All send into one shared mailbox.
//! - Single receiver empties it with mbx.receiveAll.
//! - Counts events and sensors received, verifies the total.
//!
//!
//! ```
//!  eventSenderFn ──Event×5──►
//!  sensorSenderFn ──Sensor×5──► mailbox ──receiveAll──► destroyItem per node
//!  altSenderFn ──mixed×4──►
//!  (3 concurrent senders fan-in to one mailbox)
//! ```
//!

pub fn fan_in(allocator: std.mem.Allocator, io: std.Io) !void {
    var mbx_slot: Slot = null;
    try matryoshka.mbox.new(allocator, io, &mbx_slot);
    const mbx: *Mbox = Mbox.moveFromSlot(&mbx_slot).?;
    defer {
        var rem: matryoshka.queue.Queue = mbx.close();
        items.destroyQueue(&rem, allocator, io);
        mbx.destroy();
    }

    var ctx_ev: SenderCtx = .{ .mbx = mbx, .alloc = allocator, .io = io };
    var ctx_sn: SenderCtx = .{ .mbx = mbx, .alloc = allocator, .io = io };
    var ctx_alt: SenderCtx = .{ .mbx = mbx, .alloc = allocator, .io = io };

    var f1 = try io.concurrent(eventSenderFn, .{&ctx_ev});
    var f2 = try io.concurrent(sensorSenderFn, .{&ctx_sn});
    var f3 = try io.concurrent(altSenderFn, .{&ctx_alt});

    f1.await(io);
    f2.await(io);
    f3.await(io);

    const total_sent: usize = ctx_ev.sent + ctx_sn.sent + ctx_alt.sent;
    var batch: matryoshka.queue.Queue = try mbx.receiveAll();
    var events_received: usize = 0;
    var sensors_received: usize = 0;

    while (batch.popFirst()) |item| {
        if (items.Event.EventHelper.fromInner(item)) |_| {
            events_received += 1;
        } else if (items.Sensor.SensorHelper.fromInner(item)) |_| {
            sensors_received += 1;
        }
        {
            var s: Slot = item;
            items.destroySlot(&s, allocator, io);
        }
    }

    std.log.info("fan-in: sent={d} events={d} sensors={d}", .{ total_sent, events_received, sensors_received });
    try helpers.expect(error.FanInFailed, events_received + sensors_received == total_sent, "wrong total");
}

const SenderCtx = struct {
    mbx: *Mbox,
    alloc: std.mem.Allocator,
    io: std.Io,
    sent: usize = 0,
};

fn eventSenderFn(ctx: *SenderCtx) void {
    var i: i32 = 0;
    while (i < 5) : (i += 1) {
        var slot: Slot = null;
        items.Event.EventHelper.create(ctx.alloc, ctx.io, &slot) catch return;
        items.Event.EventHelper.mustFromSlot(&slot).code = i;
        ctx.mbx.send(&slot) catch {
            items.destroySlot(&slot, ctx.alloc, ctx.io);
            return;
        };
        ctx.sent += 1;
    }
}

fn sensorSenderFn(ctx: *SenderCtx) void {
    var i: usize = 0;
    while (i < 5) : (i += 1) {
        var slot: Slot = null;
        items.Sensor.SensorHelper.create(ctx.alloc, ctx.io, &slot) catch return;
        items.Sensor.SensorHelper.mustFromSlot(&slot).value = @as(f64, @floatFromInt(i)) * 0.1;
        ctx.mbx.send(&slot) catch {
            items.destroySlot(&slot, ctx.alloc, ctx.io);
            return;
        };
        ctx.sent += 1;
    }
}

fn altSenderFn(ctx: *SenderCtx) void {
    var i: i32 = 0;
    while (i < 4) : (i += 1) {
        var slot: Slot = null;
        if (@rem(i, 2) == 0) {
            items.Event.EventHelper.create(ctx.alloc, ctx.io, &slot) catch return;
            items.Event.EventHelper.mustFromSlot(&slot).code = 100 + i;
        } else {
            items.Sensor.SensorHelper.create(ctx.alloc, ctx.io, &slot) catch return;
            items.Sensor.SensorHelper.mustFromSlot(&slot).value = @as(f64, @floatFromInt(i));
        }
        ctx.mbx.send(&slot) catch {
            items.destroySlot(&slot, ctx.alloc, ctx.io);
            return;
        };
        ctx.sent += 1;
    }
}

const items = @import("../items/items.zig");
const helpers = @import("../helpers/helpers.zig");
const matryoshka = @import("matryoshka");
const std = @import("std");
const Mbox = matryoshka.Mbox;
const Slot = matryoshka.inner.Slot;
