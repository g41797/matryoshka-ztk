// SPDX-FileCopyrightText: Copyright (c) 2026 g41797
// SPDX-License-Identifier: MIT

//! 320 — moving an outer into a full AnyOuter is refused.

const Msg = struct {
    seq: u32 = 0,
    hdr: m.inner.Inner = .{},

    pub fn init(self: *Msg, alloc: std.mem.Allocator, io: std.Io) !void {
        _ = io;
        _ = alloc;
        self.seq = 0;
    }

    pub fn finish(self: *Msg, alloc: std.mem.Allocator, io: std.Io) void {
        _ = io;
        _ = self;
        _ = alloc;
    }
};

const MSG = m.helper.OuterHelper(Msg);

pub fn main() void {
    var first: Msg = .{};
    var second: Msg = .{};
    MSG.stamp(&first);
    MSG.stamp(&second);

    var a: m.inner.Slot = MSG.toInner(&first);
    var b: m.inner.Slot = MSG.toInner(&second);
    var any: m.inner.AnyOuter = .{};

    any.moveFromSlot(&a);
    any.moveFromSlot(&b);
}

const m = @import("matryoshka");
const std = @import("std");
