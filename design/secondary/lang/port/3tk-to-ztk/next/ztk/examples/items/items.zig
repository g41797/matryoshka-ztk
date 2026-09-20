//! Fake outers for the examples — don't ship these.
pub const Event = @import("Event.zig");
pub const Sensor = @import("Sensor.zig");
pub const ShutdownCommand = @import("ShutdownCommand.zig");
pub const Timer = @import("Timer.zig");

/// Releases the outer in `slot`, whichever of the four it is.
///
/// A helper releases one type, because it must know the type. Something that
/// holds outers of several types finds the type by the id and calls that
/// type's helper. These four are the whole set of the examples, so an id that
/// is none of them means the caller passed something else.
pub fn destroySlot(slot: *Slot, alloc: std.mem.Allocator, io: std.Io) void {
    const item = slot.* orelse return;
    destroyById(item.id, alloc, io, slot);
}

/// Releases the outer in `slot`, given its id.
pub fn destroyById(id: OuterId, alloc: std.mem.Allocator, io: std.Io, slot: *Slot) void {
    if (Event.EventHelper.isIt(id)) {
        Event.EventHelper.destroy(alloc, io, slot);
    } else if (Sensor.SensorHelper.isIt(id)) {
        Sensor.SensorHelper.destroy(alloc, io, slot);
    } else if (Timer.TimerHelper.isIt(id)) {
        Timer.TimerHelper.destroy(alloc, io, slot);
    } else if (ShutdownCommand.ShutdownCommandHelper.isIt(id)) {
        ShutdownCommand.ShutdownCommandHelper.destroy(alloc, io, slot);
    } else {
        unreachable;
    }
}

/// Releases every outer on the queue, and leaves it empty.
pub fn destroyQueue(queue: *Queue, alloc: std.mem.Allocator, io: std.Io) void {
    while (queue.popFirst()) |item| {
        var slot: Slot = item;
        destroySlot(&slot, alloc, io);
    }
}

/// Makes an outer of the type `id` names, and puts it in the empty `slot`.
/// Only Event and Sensor can be made this way.
pub fn createById(id: OuterId, alloc: std.mem.Allocator, io: std.Io, slot: *Slot) !void {
    if (Event.EventHelper.isIt(id)) {
        try Event.EventHelper.create(alloc, io, slot);
    } else if (Sensor.SensorHelper.isIt(id)) {
        try Sensor.SensorHelper.create(alloc, io, slot);
    } else unreachable;
}

/// Puts the outer in `slot` back to its defaults, whichever of the two it is.
pub fn resetOnPut(slot: *Slot) void {
    if (Event.EventHelper.fromSlot(slot)) |ev| {
        ev.code = 0;
    } else if (Sensor.SensorHelper.fromSlot(slot)) |sn| {
        sn.value = 0.0;
    }
}

const matryoshka = @import("matryoshka");
const OuterId = matryoshka.inner.OuterId;
const Queue = matryoshka.queue.Queue;
const Slot = matryoshka.inner.Slot;
const std = @import("std");
