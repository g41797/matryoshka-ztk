// SPDX-FileCopyrightText: Copyright (c) 2026 g41797
// SPDX-License-Identifier: MIT

//! Layer 1 — the type-erased carrier.
//!
//! Scenarios 320 to 325.

const MSG = m.helper.OuterHelper(o.Msg);
const CHUNK = m.helper.OuterHelper(o.Chunk);

test "320 — a fresh AnyOuter is empty, and reset empties it again" {
    var any: m.inner.AnyOuter = .{};
    try expect(any.isEmpty());

    var msg: o.Msg = .{};
    MSG.stamp(&msg);
    any.set(&msg, MSG.ID);
    try expect(!any.isEmpty());

    any.reset();
    try expect(any.isEmpty());
}

test "321 — moveFromSlot holds the outer's address, and the Slot is empty" {
    var msg: o.Msg = .{ .seq = 7 };
    MSG.stamp(&msg);

    var slot: m.inner.Slot = MSG.toInner(&msg);
    var any: m.inner.AnyOuter = .{};

    any.moveFromSlot(&slot);

    try expect(slot == null);
    try expect(any.ptr.? == @as(*anyopaque, &msg));
    try expect(any.id == MSG.ID);
}

test "322 — moveToSlot returns the same outer, and the AnyOuter is empty" {
    var msg: o.Msg = .{ .seq = 9 };
    MSG.stamp(&msg);

    var slot: m.inner.Slot = MSG.toInner(&msg);
    var any: m.inner.AnyOuter = .{};
    any.moveFromSlot(&slot);

    any.moveToSlot(&slot);

    try expect(any.isEmpty());
    try expect(MSG.fromSlot(&slot).? == &msg);
}

test "323 — fromAny answers null for an empty AnyOuter and a wrong type" {
    var msg: o.Msg = .{};
    MSG.stamp(&msg);

    var any: m.inner.AnyOuter = .{};
    try expect(MSG.fromAny(&any) == null);

    var slot: m.inner.Slot = MSG.toInner(&msg);
    any.moveFromSlot(&slot);

    try expect(CHUNK.fromAny(&any) == null);
    try expect(MSG.fromAny(&any).? == &msg);
    try expect(!any.isEmpty());
}

test "324 — an inner at a nonzero and a zero offset both round-trip" {
    var chunk: o.Chunk = .{};
    CHUNK.stamp(&chunk);

    var slot: m.inner.Slot = CHUNK.toInner(&chunk);
    var any: m.inner.AnyOuter = .{};
    any.moveFromSlot(&slot);
    try expect(CHUNK.fromAny(&any).? == &chunk);

    any.moveToSlot(&slot);
    try expect(CHUNK.fromSlot(&slot).? == &chunk);
}

test "325 — an AnyOuter travels through a std queue" {
    const Item = union(enum) { outer: m.inner.AnyOuter, quit };

    var buf: [2]Item = undefined;
    var q: std.Io.Queue(Item) = .init(&buf);
    const io = std.testing.io;

    var msg: o.Msg = .{ .seq = 42 };
    MSG.stamp(&msg);

    var slot: m.inner.Slot = MSG.toInner(&msg);
    var any: m.inner.AnyOuter = .{};
    any.moveFromSlot(&slot);

    try q.putOne(io, .{ .outer = any });
    any.reset();

    const got = try q.getOne(io);
    var back: m.inner.AnyOuter = got.outer;

    try expect(MSG.fromAny(&back).?.seq == 42);
    back.moveToSlot(&slot);
    try expect(MSG.fromSlot(&slot).? == &msg);
}

const expect = std.testing.expect;
const m = @import("matryoshka");
const o = @import("outers.zig");
const std = @import("std");
