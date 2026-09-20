# Id-dispatch consume loop

## Description

Id-dispatch consume loop.

- Append an Event and a Sensor to one queue.
- Pop each inner, and ask each type to cast it: fromInner.
- The cast that matches gives the typed pointer, the others give null.
- Release each outer as it is handled.

## Diagram

```
 create (Event) ──► queue
 create (Sensor) ──► queue
      │ queue.popFirst
      ▼
 EventHelper.fromInner or SensorHelper.fromInner
      │ destroySlot per outer
```

## Source

```zig
pub fn id_dispatch_consume_loop(allocator: std.mem.Allocator, io: std.Io) !void {
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

    var processed_events: usize = 0;
    var processed_sensors: usize = 0;

    while (queue.popFirst()) |item| {
        var slot: Slot = item;
        defer items.destroySlot(&slot, allocator, io);

        if (items.Event.EventHelper.fromInner(item)) |recovered_ev| {
            try helpers.expect(error.IdDispatchFailed, recovered_ev.code == 7, "wrong event code");
            processed_events += 1;
        } else if (items.Sensor.SensorHelper.fromInner(item)) |recovered_sn| {
            try helpers.expect(error.IdDispatchFailed, recovered_sn.value == 2.71, "wrong sensor value");
            processed_sensors += 1;
        } else {
            return error.UnknownId;
        }
    }

    try helpers.expect(error.IdDispatchFailed, processed_events == 1, "wrong event count");
    try helpers.expect(error.IdDispatchFailed, processed_sensors == 1, "wrong sensor count");
}

const items = @import("../items/items.zig");
const helpers = @import("../helpers/helpers.zig");
const matryoshka = @import("matryoshka");
const Queue = matryoshka.queue.Queue;
const Slot = matryoshka.inner.Slot;
const std = @import("std");
```
