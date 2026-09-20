// SPDX-FileCopyrightText: Copyright (c) 2026 g41797
// SPDX-License-Identifier: MIT

//! Request-response between Masters.
//!
//! - Master A sends an Event request to Master B's inbox.
//! - Master B computes a response, sends a Sensor to Master A's inbox.
//! - Both masters run concurrently; runMasters awaits both.
//!
//!
//! ```
//!  master A ──Event(request)──► b_inbox ──► master B
//!  master A ◄──Sensor(response)── a_inbox ◄── master B
//!  (fut_a + fut_b run concurrently; fut_a.await → fut_b.await)
//! ```
//!

pub fn request_response_between_masters(allocator: std.mem.Allocator, io: std.Io) !void {
    var a_inbox_slot: Slot = null;
    try matryoshka.mbox.new(allocator, io, &a_inbox_slot);
    const a_inbox: *Mbox = Mbox.moveFromSlot(&a_inbox_slot).?;
    defer {
        var rem: Queue = a_inbox.close();
        items.destroyQueue(&rem, allocator, io);
        a_inbox.destroy();
    }

    var b_inbox_slot: Slot = null;
    try matryoshka.mbox.new(allocator, io, &b_inbox_slot);
    const b_inbox: *Mbox = Mbox.moveFromSlot(&b_inbox_slot).?;
    defer {
        var rem: Queue = b_inbox.close();
        items.destroyQueue(&rem, allocator, io);
        b_inbox.destroy();
    }

    try runMasters(a_inbox, b_inbox, allocator, io);
    std.log.info("request-response done: both masters completed", .{});
}

const MasterACtx = struct {
    a_inbox: *Mbox,
    b_inbox: *Mbox,
    alloc: std.mem.Allocator,
    io: std.Io,
};

fn masterAFn(ctx: *MasterACtx) anyerror!void {
    {
        var slot: Slot = null;
        defer items.destroySlot(&slot, ctx.alloc, ctx.io);
        try items.Event.EventHelper.create(ctx.alloc, ctx.io, &slot);
        items.Event.EventHelper.mustFromSlot(&slot).code = 42;
        try ctx.b_inbox.send(&slot);
        std.log.info("master A: sent Event code=42 request to B", .{});
    }

    var slot: Slot = null;
    defer items.destroySlot(&slot, ctx.alloc, ctx.io);
    try ctx.a_inbox.receive(&slot, null);

    if (items.Sensor.SensorHelper.fromSlot(&slot)) |sn| {
        std.log.info("master A: received Sensor response value={d}", .{sn.value});
        items.destroySlot(&slot, ctx.alloc, ctx.io);
    } else {
        items.destroySlot(&slot, ctx.alloc, ctx.io);
    }
}

const MasterBCtx = struct {
    a_inbox: *Mbox,
    b_inbox: *Mbox,
    alloc: std.mem.Allocator,
    io: std.Io,
};

fn masterBFn(ctx: *MasterBCtx) anyerror!void {
    var slot: Slot = null;
    defer items.destroySlot(&slot, ctx.alloc, ctx.io);
    try ctx.b_inbox.receive(&slot, null);

    var response_value: f64 = 0.0;
    if (items.Event.EventHelper.fromSlot(&slot)) |ev| {
        response_value = @floatFromInt(ev.code);
        std.log.info("master B: received Event code={d}, computing response", .{ev.code});
        items.destroySlot(&slot, ctx.alloc, ctx.io);
    } else {
        items.destroySlot(&slot, ctx.alloc, ctx.io);
    }

    try items.Sensor.SensorHelper.create(ctx.alloc, ctx.io, &slot);
    items.Sensor.SensorHelper.mustFromSlot(&slot).value = response_value;
    try ctx.a_inbox.send(&slot);
    std.log.info("master B: sent Sensor response value={d}", .{response_value});
}

fn runMasters(a_inbox: *Mbox, b_inbox: *Mbox, alloc: std.mem.Allocator, io: std.Io) !void {
    var ctx_a: MasterACtx = .{ .a_inbox = a_inbox, .b_inbox = b_inbox, .alloc = alloc, .io = io };
    var ctx_b: MasterBCtx = .{ .a_inbox = a_inbox, .b_inbox = b_inbox, .alloc = alloc, .io = io };
    var fut_a = try io.concurrent(masterAFn, .{&ctx_a});
    var fut_b = try io.concurrent(masterBFn, .{&ctx_b});
    try fut_a.await(io);
    try fut_b.await(io);
}

const items = @import("../items/items.zig");
const matryoshka = @import("matryoshka");
const std = @import("std");
const Mbox = matryoshka.Mbox;
const Slot = matryoshka.inner.Slot;
const Queue = matryoshka.queue.Queue;
