# Refused put

## Description

Refused put.

- A pool keeps outers of the ids it was made with, and no others.
- Put into a closed pool is silent: the Slot keeps the outer, and the
  caller releases it.

- Put of an unknown id is error.UnknownIdentity, and the Slot is untouched.
  The same answer in every build.

## Diagram

```
 pl (Event only) ◄── pl.put (Sensor) ──► error.UnknownIdentity
      │ pl.close
      ▼
 pl.put (Event) ──► silent, Slot still full ──► caller releases
```

## Source

```zig
pub fn refused_put(allocator: std.mem.Allocator, io: std.Io) !void {
    var ctx: hooks.AlwaysCreateHooks = .{ .alloc = allocator, .io = io };
    const ids = [_]OuterId{items.Event.EventHelper.ID};

    var pl_slot: Slot = null;
    try matryoshka.pool.new(allocator, io, &ids, ctx.poolHooks(), &pl_slot);
    const pl: *Pool = Pool.moveFromSlot(&pl_slot).?;
    defer pl.destroy();

    {
        var sensor: Slot = null;
        defer items.destroySlot(&sensor, allocator, io);
        try items.Sensor.SensorHelper.create(allocator, io, &sensor);

        const refused = pl.put(&sensor);
        try helpers.expect(error.RefusedPutFailed, refused == error.UnknownIdentity, "expected UnknownIdentity");
        try helpers.expect(error.RefusedPutFailed, sensor != null, "refused put took the outer");
    }

    var slot: Slot = null;
    defer items.destroySlot(&slot, allocator, io);
    try items.Event.EventHelper.create(allocator, io, &slot);

    pl.close();

    try pl.put(&slot);
    try helpers.expect(error.RefusedPutFailed, slot != null, "put into a closed pool took the outer");
}

const items = @import("../items/items.zig");
const hooks = @import("../hooks/hooks.zig");
const helpers = @import("../helpers/helpers.zig");
const matryoshka = @import("matryoshka");
const std = @import("std");
const OuterId = matryoshka.inner.OuterId;
const Pool = matryoshka.Pool;
const Slot = matryoshka.inner.Slot;
```
