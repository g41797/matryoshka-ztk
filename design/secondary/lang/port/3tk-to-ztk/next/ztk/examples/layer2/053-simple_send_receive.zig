// SPDX-FileCopyrightText: Copyright (c) 2026 g41797
// SPDX-License-Identifier: MIT

//! Simple send-receive.
//!
//! - One thread sends an Event, then a Sensor, into a mailbox.
//! - Same thread receives both back, in order.
//! - Verifies each roundtrip value.
//!
//!
//! ```
//!  alloc.create ──► slot ──mbx.send──► mailbox (owns)
//!                                              │ mbx.receive
//!                                              ▼
//!                                         slot ──► destroySlot
//! ```
//!

pub fn simple_send_receive(allocator: std.mem.Allocator, io: std.Io) !void {
    var mbx_slot: Slot = null;
    try matryoshka.mbox.new(allocator, io, &mbx_slot);
    const mbx: *Mbox = Mbox.moveFromSlot(&mbx_slot).?;
    defer {
        var rem: matryoshka.queue.Queue = mbx.close();
        items.destroyQueue(&rem, allocator, io);
        mbx.destroy();
    }

    {
        var slot: Slot = null;
        defer items.destroySlot(&slot, allocator, io);
        try items.Event.EventHelper.create(allocator, io, &slot);
        items.Event.EventHelper.mustFromSlot(&slot).code = 53;
        try mbx.send(&slot);
    }

    {
        var slot: Slot = null;
        defer items.destroySlot(&slot, allocator, io);
        try items.Sensor.SensorHelper.create(allocator, io, &slot);
        items.Sensor.SensorHelper.mustFromSlot(&slot).value = 5.3;
        try mbx.send(&slot);
    }

    {
        var slot: Slot = null;
        defer items.destroySlot(&slot, allocator, io);
        try mbx.receive(&slot, 1_000_000_000);
        const ev_recv: *items.Event = items.Event.EventHelper.fromSlot(&slot) orelse return error.WrongTag;
        try helpers.expect(error.SimpleSendReceiveFailed, ev_recv.*.code == 53, "wrong event code");
        std.log.info("received Event code={d}", .{ev_recv.*.code});
    }

    {
        var slot: Slot = null;
        defer items.destroySlot(&slot, allocator, io);
        try mbx.receive(&slot, 1_000_000_000);
        const sn_recv: *items.Sensor = items.Sensor.SensorHelper.fromSlot(&slot) orelse return error.WrongTag;
        try helpers.expect(error.SimpleSendReceiveFailed, sn_recv.*.value == 5.3, "wrong sensor value");
        std.log.info("received Sensor value={d:.1}", .{sn_recv.*.value});
    }
}

const items = @import("../items/items.zig");
const helpers = @import("../helpers/helpers.zig");
const matryoshka = @import("matryoshka");
const std = @import("std");
const Mbox = matryoshka.Mbox;
const Slot = matryoshka.inner.Slot;
