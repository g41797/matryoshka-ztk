# A greeting: a short text in a fixed buffer. Just a demo outer

## Description

A greeting: a short text in a fixed buffer. Just a demo outer.

The buffer is part of the outer, so filling it allocates nothing.

## Source

```zig
inner: Inner = .{},
text: Text = .{},

pub const GreetingHelper = matryoshka.helper.OuterHelper(Self);

/// A short text that is copied by value. It holds no pointer.
pub const Text = struct {
    buf: [32]u8 = undefined,
    len: usize = 0,

    pub fn of(s: []const u8) Text {
        var t: Text = .{};
        @memcpy(t.buf[0..s.len], s);
        t.len = s.len;
        return t;
    }

    pub fn slice(self: *const Text) []const u8 {
        return self.buf[0..self.len];
    }
};

pub fn init(self: *Self, alloc: std.mem.Allocator, io: std.Io) !void {
    _ = .{ alloc, io };
    self.text = .{};
}

pub fn finish(self: *Self, alloc: std.mem.Allocator, io: std.Io) void {
    _ = .{ self, alloc, io };
}

/// Releases every greeting on the queue, and leaves it empty.
pub fn destroyQueue(queue: *Queue, alloc: std.mem.Allocator, io: std.Io) void {
    while (queue.popFirst()) |item| {
        var slot: Slot = item;
        GreetingHelper.destroy(alloc, io, &slot);
    }
}

const Self = @This();
const Inner = matryoshka.inner.Inner;
const Queue = matryoshka.queue.Queue;
const Slot = matryoshka.inner.Slot;
const matryoshka = @import("matryoshka");
const std = @import("std");
```
