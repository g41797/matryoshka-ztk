// SPDX-FileCopyrightText: Copyright (c) 2026 g41797
// SPDX-License-Identifier: MIT

//! Layer 1 — the helper, and the border.
//!
//! Scenarios 210 to 219, and 253.

const MSG = m.helper.OuterHelper(o.Msg);
const CHUNK = m.helper.OuterHelper(o.Chunk);
const BUF = m.helper.OuterHelper(o.Buf);
const BAD = m.helper.OuterHelper(o.BadInit);
const MBOX = m.helper.OuterHelper(o.FakeMbox);

test "210 — an outer declares init and finish" {
    // The requirement is a compile error at the create and release sites, so
    // what is checked here is that the declarations are there and typed as
    // the helper calls them.
    try expect(@hasDecl(o.Msg, "init"));
    try expect(@hasDecl(o.Msg, "finish"));
    try expect(@hasDecl(o.Buf, "init"));
    try expect(@hasDecl(o.Buf, "finish"));
}

test "211 — create runs the outer's init" {
    const alloc = std.testing.allocator;

    var slot: m.inner.Slot = null;
    try BUF.create(alloc, std.testing.io, &slot);
    defer BUF.destroy(alloc, std.testing.io, &slot);

    const buf = BUF.fromSlot(&slot).?;
    try expect(buf.bytes.len == o.Buf.size);
}

test "212 — a failing init frees the outer and passes the failure on" {
    const alloc = std.testing.allocator;

    var slot: m.inner.Slot = null;
    const failed = BAD.create(alloc, std.testing.io, &slot);

    try std.testing.expectError(o.BadInit.Failed.InitRefused, failed);
    try expect(slot == null);

    // The allocator checks the rest: the testing allocator fails the test if
    // the outer was not freed again.
}

test "213 — destroy runs the outer's finish before freeing" {
    const alloc = std.testing.allocator;

    var slot: m.inner.Slot = null;
    try BUF.create(alloc, std.testing.io, &slot);

    BUF.destroy(alloc, std.testing.io, &slot);
    try expect(slot == null);

    // What `finish` freed is what the testing allocator would report.
}

test "214 — destroy on an empty Slot does nothing" {
    const alloc = std.testing.allocator;

    var slot: m.inner.Slot = null;
    MSG.destroy(alloc, std.testing.io, &slot);

    try expect(slot == null);

    // So one defer covers the path where the outer was never created.
    var early: m.inner.Slot = null;
    defer MSG.destroy(alloc, std.testing.io, &early);
}

test "215 — create and destroy, repeatedly" {
    const alloc = std.testing.allocator;

    var slot: m.inner.Slot = null;
    var round: usize = 0;

    while (round < 16) : (round += 1) {
        try MSG.create(alloc, std.testing.io, &slot);
        try expect(slot != null);

        MSG.destroy(alloc, std.testing.io, &slot);
        try expect(slot == null);
    }
}

test "216 — a created outer is an ordinary outer" {
    const alloc = std.testing.allocator;

    var slot: m.inner.Slot = null;
    try MSG.create(alloc, std.testing.io, &slot);

    var q: m.queue.Queue = .{};
    q.appendFromSlot(&slot);

    try expect(q.len() == 1);

    slot = q.popFirst();
    const msg = MSG.fromSlot(&slot).?;

    // Nothing marks it as having been made by the helper.
    try expect(msg.hdr.id == MSG.ID);

    MSG.destroy(alloc, std.testing.io, &slot);
}

test "217 — the panicking take answers on a match" {
    const alloc = std.testing.allocator;

    var slot: m.inner.Slot = null;
    try MSG.create(alloc, std.testing.io, &slot);

    const msg = MSG.mustMoveFromSlot(&slot);
    try expect(slot == null);

    // The wrong-type and empty-Slot halves panic. They are scenarios 301 and
    // 303, and they run outside the test binary.
    var back: m.inner.Slot = MSG.toInner(msg);
    MSG.destroy(alloc, std.testing.io, &back);
}

test "218 — the border pair, out and back" {
    var msg: o.Msg = .{ .seq = 8 };
    MSG.stamp(&msg);

    var slot: m.inner.Slot = MSG.toInner(&msg);

    const item = m.inner.takeFromSlot(&slot);

    try expect(slot == null);
    try expect(!m.inner.isLinked(item));
    try expect(MSG.fromInner(item) != null);

    m.inner.fillSlot(&slot, item);

    try expect(slot.? == item);
    try expect(MSG.fromSlot(&slot).? == &msg);
}

test "219 — the border pair round trip through a std list" {
    var a: o.Msg = .{ .seq = 1 };
    var b: o.Msg = .{ .seq = 2 };
    MSG.stamp(&a);
    MSG.stamp(&b);

    var slot: m.inner.Slot = MSG.toInner(&a);
    var list: std.SinglyLinkedList = .{};

    // Out of the toolkit, one item at a time, into a container of the
    // caller's own.
    list.prepend(&m.inner.takeFromSlot(&slot).node);

    slot = MSG.toInner(&b);
    list.prepend(&m.inner.takeFromSlot(&slot).node);

    try expect(slot == null);
    try expect(list.len() == 2);

    // Back again. std leaves its link set, so the caller clears it — which
    // is the line the toolkit's own queue does not make anyone write.
    var seen: usize = 0;
    while (list.popFirst()) |node| : (seen += 1) {
        node.next = null;

        const item = m.inner.ofNode(node);
        m.inner.fillSlot(&slot, item);

        const msg = MSG.moveFromSlot(&slot).?;
        try expect(msg.seq == 2 - seen);
    }

    try expect(seen == 2);
}

test "253 — a container declares no create and no destroy" {
    // FakeMbox has neither hook, and it is still an outer: it has an id and
    // the crossings work. Asking for create or destroy does not compile, and
    // that is scenarios 308 and 309.
    var fake: o.FakeMbox = .{};
    MBOX.stamp(&fake);

    try expect(!@hasDecl(o.FakeMbox, "init"));
    try expect(!@hasDecl(o.FakeMbox, "finish"));

    try expect(MBOX.fromInner(MBOX.toInner(&fake)).? == &fake);
    try expect(CHUNK.fromInner(MBOX.toInner(&fake)) == null);
}

const expect = std.testing.expect;
const m = @import("matryoshka");
const o = @import("outers.zig");
const std = @import("std");
