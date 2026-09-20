//! Just a demo outer — not for production.
inner: Inner = .{},
value: f64 = 0.0,

pub const SensorHelper = matryoshka.helper.OuterHelper(Self);

pub fn init(self: *Self, alloc: std.mem.Allocator, io: std.Io) !void {
    _ = .{ alloc, io };
    self.value = 0.0;
}

pub fn finish(self: *Self, alloc: std.mem.Allocator, io: std.Io) void {
    _ = .{ self, alloc, io };
}

const Self = @This();
const Inner = matryoshka.inner.Inner;
const matryoshka = @import("matryoshka");
const std = @import("std");
