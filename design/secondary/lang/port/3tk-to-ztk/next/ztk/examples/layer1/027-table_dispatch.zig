// SPDX-FileCopyrightText: Copyright (c) 2026 g41797
// SPDX-License-Identifier: MIT

//! Table dispatch — the third way, where the choice is data.
//!
//! 023 and 026 write the choice as code. This one writes it as a value.
//!
//! - 023 has the outer and asks each type to cast it: fromInner.
//! - 026 has the id and asks each type to confirm it: isIt.
//! - Both put the choice in the chain, so the choice is fixed where the
//!   chain is written. Two receivers that treat an Event differently write
//!   two chains.
//! - A table is `{id, handler}` pairs the receiver owns. Change the table
//!   and the same id reaches a different handler.
//!
//! - Append an Event, a Sensor and a Timer to one mixed queue.
//! - Dispatch each through a table that names all three.
//! - Then dispatch an Event through a second table, which maps the same
//!   id to a different handler. No chain can express that.
//! - An id no table names gives error.NoHandler with the outer still in the
//!   Slot, so the caller releases it. The last branch of a chain cannot.
//!
//!
//! ```
//!  create (Event, Sensor, Timer)  ──► queue
//!       │ queue.popFirst
//!       ▼
//!  table.dispatch(&recorder, &slot)
//!       │ find: entry.id == inner.id
//!       ▼
//!  handler(recorder, slot) ──► Slot says where the outer went
//!       │ destroySlot per outer
//! ```
//!

/// A receiver. Its handlers look at the outer and leave it in the Slot.
const Recorder = struct {
    events: usize = 0,
    sensors: usize = 0,
    timers: usize = 0,
    marked: usize = 0,
    last_code: i32 = 0,

    fn onEvent(self: *Recorder, slot: *Slot) anyerror!void {
        // The table matched the id, so this cast cannot fail.
        self.last_code = items.Event.EventHelper.mustFromSlot(slot).code;
        self.events += 1;
    }

    fn onSensor(self: *Recorder, slot: *Slot) anyerror!void {
        const sn = items.Sensor.SensorHelper.mustFromSlot(slot);
        try helpers.expect(error.TableDispatchFailed, sn.value == 2.71, "wrong sensor value");
        self.sensors += 1;
    }

    fn onTimer(self: *Recorder, _: *Slot) anyerror!void {
        // A handler that never reaches the outer. The id was enough.
        self.timers += 1;
    }

    /// The second table's handler for an Event. Same id, other work.
    fn markEvent(self: *Recorder, _: *Slot) anyerror!void {
        self.marked += 1;
    }
};

const Table = helpers.IdTable(Recorder);

/// The table is a value, so it is a container-level const. Every Recorder
/// this receiver type makes shares it.
const record_table: Table = .{ .entries = &.{
    .{ .id = items.Event.EventHelper.ID, .handler = Recorder.onEvent },
    .{ .id = items.Sensor.SensorHelper.ID, .handler = Recorder.onSensor },
    .{ .id = items.Timer.TimerHelper.ID, .handler = Recorder.onTimer },
} };

/// Another receiver's table. It sends the same Event id to a different
/// handler. The Sensor id is in neither — a receiver with no handler for a
/// type is a normal state of affairs.
const mark_table: Table = .{ .entries = &.{
    .{ .id = items.Event.EventHelper.ID, .handler = Recorder.markEvent },
} };

pub fn table_dispatch_loop(allocator: std.mem.Allocator, io: std.Io) !void {
    var queue: Queue = .{};

    defer items.destroyQueue(&queue, allocator, io);

    {
        var slot: Slot = null;
        try items.Event.EventHelper.create(allocator, io, &slot);
        items.Event.EventHelper.mustFromSlot(&slot).code = 7;
        queue.appendFromSlot(&slot);
    }

    {
        var slot: Slot = null;
        try items.Sensor.SensorHelper.create(allocator, io, &slot);
        items.Sensor.SensorHelper.mustFromSlot(&slot).value = 2.71;
        queue.appendFromSlot(&slot);
    }

    {
        var slot: Slot = null;
        try items.Timer.TimerHelper.create(allocator, io, &slot);
        queue.appendFromSlot(&slot);
    }

    var recorder: Recorder = .{};

    while (queue.popFirst()) |item| {
        var slot: Slot = item;

        // Covers every outcome. The handler may take the outer, forward it,
        // or leave it — this releases whatever is left, and does nothing
        // when the Slot is null.
        defer items.destroySlot(&slot, allocator, io);

        try record_table.dispatch(&recorder, &slot);
    }

    try helpers.expect(error.TableDispatchFailed, recorder.events == 1, "wrong event count");
    try helpers.expect(error.TableDispatchFailed, recorder.sensors == 1, "wrong sensor count");
    try helpers.expect(error.TableDispatchFailed, recorder.timers == 1, "wrong timer count");
    try helpers.expect(error.TableDispatchFailed, recorder.last_code == 7, "wrong event code");

    try secondTable(allocator, io, &recorder);
}

/// The same id, the other table, the other handler.
fn secondTable(allocator: std.mem.Allocator, io: std.Io, recorder: *Recorder) !void {
    {
        var slot: Slot = null;
        defer items.destroySlot(&slot, allocator, io);

        try items.Event.EventHelper.create(allocator, io, &slot);
        try mark_table.dispatch(recorder, &slot);

        // The Event id reached markEvent, not onEvent. The outer is the
        // same one record_table would have sent to onEvent.
        try helpers.expect(error.TableDispatchFailed, recorder.marked == 1, "wrong marked count");
        try helpers.expect(error.TableDispatchFailed, recorder.events == 1, "onEvent ran again");
    }

    {
        var slot: Slot = null;
        defer items.destroySlot(&slot, allocator, io);

        try items.Sensor.SensorHelper.create(allocator, io, &slot);

        // mark_table has no entry for a Sensor. Nothing is called and the
        // outer never leaves the Slot, so the defer above releases it. The
        // last branch of an isIt chain has no type and cannot.
        const missed = mark_table.dispatch(recorder, &slot);
        try helpers.expect(error.TableDispatchFailed, missed == error.NoHandler, "expected NoHandler");
        try helpers.expect(error.TableDispatchFailed, slot != null, "miss took the outer");
    }
}

const items = @import("../items/items.zig");
const helpers = @import("../helpers/helpers.zig");
const matryoshka = @import("matryoshka");
const Queue = matryoshka.queue.Queue;
const Slot = matryoshka.inner.Slot;
const std = @import("std");
