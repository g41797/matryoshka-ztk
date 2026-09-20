// SPDX-FileCopyrightText: Copyright (c) 2026 g41797
// SPDX-License-Identifier: MIT

//! The border pair: a Slot and a std list, one outer at a time.
//!
//! - takeFromSlot empties the Slot and gives the bare inner.
//! - The inner's std node goes onto a plain std.SinglyLinkedList.
//! - ofNode turns a popped node back into the inner.
//! - fillSlot puts a bare inner into an empty Slot.
//!
//! A std list is a border, not a second home. While an outer sits on it the
//! toolkit does not know about it. std's popFirst leaves the node's link
//! set, so the link must be cleared before fillSlot, which refuses an inner
//! that still looks linked.
//!
//!
//! ```
//!  slot ── takeFromSlot ──► *Inner
//!       │ list.prepend(&inner.node)
//!       ▼
//!  std.SinglyLinkedList
//!       │ list.popFirst + clear link + ofNode
//!       ▼
//!  *Inner ── fillSlot ──► slot
//! ```
//!

pub fn border_pair(allocator: std.mem.Allocator, io: std.Io) !void {
    var slot: Slot = null;
    defer items.destroySlot(&slot, allocator, io);

    try items.Event.EventHelper.create(allocator, io, &slot);
    items.Event.EventHelper.mustFromSlot(&slot).code = 98;

    // Out of the Slot, onto the std list.
    var list: std.SinglyLinkedList = .{};
    const bare: *Inner = matryoshka.inner.takeFromSlot(&slot);
    list.prepend(&bare.node);
    try helpers.expect(error.BorderPairFailed, slot == null, "slot should be empty after take");

    // Back from the std list. popFirst leaves the link pointing into the
    // list it left, so the crossing clears it first.
    const node = list.popFirst() orelse return error.EmptyList;
    node.next = null;
    const back: *Inner = matryoshka.inner.ofNode(node);

    matryoshka.inner.fillSlot(&slot, back);
    const ev = items.Event.EventHelper.mustFromSlot(&slot);
    try helpers.expect(error.BorderPairFailed, ev.code == 98, "wrong event code");
}

const items = @import("../items/items.zig");
const helpers = @import("../helpers/helpers.zig");
const matryoshka = @import("matryoshka");
const Inner = matryoshka.inner.Inner;
const Slot = matryoshka.inner.Slot;
const std = @import("std");
