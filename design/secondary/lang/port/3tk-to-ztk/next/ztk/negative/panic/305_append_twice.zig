// SPDX-FileCopyrightText: Copyright (c) 2026 g41797
// SPDX-License-Identifier: MIT

//! 305 — appending the same outer twice to one chain is refused.

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
    var other: Msg = .{ .seq = 1 };
    var msg: Msg = .{ .seq = 2 };
    MSG.stamp(&other);
    MSG.stamp(&msg);

    var q: m.queue.Queue = .{};
    q.append(MSG.toInner(&other));
    q.append(MSG.toInner(&msg));
    q.append(MSG.toInner(&msg));
}

const m = @import("matryoshka");
const std = @import("std");
