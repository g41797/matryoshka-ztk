# Builder pattern

## Description

Builder pattern.

- Builder wraps an allocator and an Io, no other state.
- createEvent / createSensor build a typed outer into a Slot.
- mustFromSlot recovers the typed pointer for field access.
- release frees whichever type the Slot holds.

## Diagram

```
 create ──► slot (non-null)
      │
 Builder.createEvent ──► field set (no transfer)
      │
 Builder.release ──► slot empty
```

## Source

```zig
pub fn builder_pattern(allocator: std.mem.Allocator, io: std.Io) !void {
    const b: Builder = .{ .alloc = allocator, .io = io };

    {
        var slot: Slot = null;
        defer b.release(&slot);
        try b.createEvent(100, &slot);
        const ev = items.Event.EventHelper.mustFromSlot(&slot);
        try helpers.expect(error.BuilderFailed, ev.code == 100, "wrong event code");
    }

    {
        var slot: Slot = null;
        defer b.release(&slot);
        try b.createSensor(9.8, &slot);
        const sn = items.Sensor.SensorHelper.mustFromSlot(&slot);
        try helpers.expect(error.BuilderFailed, sn.value == 9.8, "wrong sensor value");
    }
}

pub const Builder = struct {
    alloc: std.mem.Allocator,
    io: std.Io,

    pub fn createEvent(self: Builder, code: i32, slot: *Slot) !void {
        try items.Event.EventHelper.create(self.alloc, self.io, slot);
        items.Event.EventHelper.mustFromSlot(slot).code = code;
    }

    pub fn createSensor(self: Builder, value: f64, slot: *Slot) !void {
        try items.Sensor.SensorHelper.create(self.alloc, self.io, slot);
        items.Sensor.SensorHelper.mustFromSlot(slot).value = value;
    }

    pub fn release(self: Builder, slot: *Slot) void {
        items.destroySlot(slot, self.alloc, self.io);
    }
};

const items = @import("../items/items.zig");
const helpers = @import("../helpers/helpers.zig");
const Slot = @import("matryoshka").inner.Slot;
const std = @import("std");
```
