// SPDX-FileCopyrightText: Copyright (c) 2026 g41797
// SPDX-License-Identifier: MIT

//! 321 — moving an unstamped outer into an AnyOuter is refused.

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
    var msg: Msg = .{};

    var slot: m.inner.Slot = MSG.toInner(&msg);
    var any: m.inner.AnyOuter = .{};

    any.moveFromSlot(&slot);
}

const m = @import("matryoshka");
const std = @import("std");
