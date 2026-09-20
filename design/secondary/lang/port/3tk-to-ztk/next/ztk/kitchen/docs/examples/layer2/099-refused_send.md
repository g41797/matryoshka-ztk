# Refused send

## Description

Refused send.

- Close the mailbox, then try to send an Event.
- send answers error.Closed.
- The Slot still holds the outer: a refused send takes nothing.
- The caller releases it.

## Diagram

```
 mbx.close
      │
 alloc.create ──► slot ──mbx.send──► error.Closed
      │ slot still full
      ▼
 destroySlot
```

## Source

```zig
pub fn refused_send(allocator: std.mem.Allocator, io: std.Io) !void {
    var mbx_slot: Slot = null;
    try matryoshka.mbox.new(allocator, io, &mbx_slot);
    const mbx: *Mbox = Mbox.moveFromSlot(&mbx_slot).?;
    defer mbx.destroy();

    var none: matryoshka.queue.Queue = mbx.close();
    items.destroyQueue(&none, allocator, io);

    var slot: Slot = null;
    defer items.destroySlot(&slot, allocator, io);
    try items.Event.EventHelper.create(allocator, io, &slot);

    const refused = mbx.send(&slot);
    try helpers.expect(error.RefusedSendFailed, refused == error.Closed, "expected error.Closed");
    try helpers.expect(error.RefusedSendFailed, slot != null, "a refused send must leave the outer in the Slot");
    std.log.info("send refused, the Slot still holds the outer", .{});
}

const items = @import("../items/items.zig");
const helpers = @import("../helpers/helpers.zig");
const matryoshka = @import("matryoshka");
const std = @import("std");
const Mbox = matryoshka.Mbox;
const Slot = matryoshka.inner.Slot;
```
