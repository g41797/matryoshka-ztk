# Just a demo outer — not for production

## Description

Just a demo outer — not for production.

## Source

```zig
inner: Inner = .{},
ticks: u32 = 0,

pub const TimerHelper = matryoshka.helper.OuterHelper(Self);

pub fn init(self: *Self, alloc: std.mem.Allocator, io: std.Io) !void {
    _ = .{ alloc, io };
    self.ticks = 0;
}

pub fn finish(self: *Self, alloc: std.mem.Allocator, io: std.Io) void {
    _ = .{ self, alloc, io };
}

const Self = @This();
const Inner = matryoshka.inner.Inner;
const matryoshka = @import("matryoshka");
const std = @import("std");
```
