# Sample hook, for demo purposes only

## Description

Sample hook, for demo purposes only.

## Source

```zig
alloc: std.mem.Allocator,
io: std.Io,

pub fn poolHooks(self: *Self) Pool.Hooks {
    return .{
        .ctx = self,
        .on_get = onGet,
        .on_put = onPut,
        .on_close = onClose,
    };
}

pub fn onGet(ptr: *anyopaque, want: OuterId, _: usize, slot: *Slot) void {
    const self: *Self = @ptrCast(@alignCast(ptr));

    // The pool hands over an id and an empty Slot. There is no outer to look
    // at, so the id is the only thing to dispatch on.
    items.createById(want, self.alloc, self.io, slot) catch return;
}

pub fn onPut(_: *anyopaque, _: usize, slot: *Slot, _: *Queue) void {
    items.resetOnPut(slot);
}

pub fn onClose(ptr: *anyopaque, remaining: Queue) void {
    const self: *Self = @ptrCast(@alignCast(ptr));
    var rest = remaining;
    items.destroyQueue(&rest, self.alloc, self.io);
}

const Self = @This();
const items = @import("../items/items.zig");
const matryoshka = @import("matryoshka");
const OuterId = matryoshka.inner.OuterId;
const Pool = matryoshka.Pool;
const Queue = matryoshka.queue.Queue;
const Slot = matryoshka.inner.Slot;
const std = @import("std");
```
