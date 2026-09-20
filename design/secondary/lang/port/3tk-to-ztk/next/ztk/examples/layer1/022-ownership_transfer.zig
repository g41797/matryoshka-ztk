// SPDX-FileCopyrightText: Copyright (c) 2026 g41797
// SPDX-License-Identifier: MIT

//! Outer transfer via Slot.
//!
//! - Create an Event, place it in a Slot.
//! - Take it out with moveFromSlot, append it to a queue.
//! - Pop the outer back out of the queue, assign it to a Slot.
//! - Verify the recovered data, then release it.
//!
//! moveFromSlot checks the id and empties the Slot in one step.\
//! fromSlot would leave the Slot full — that is the difference.
//!
//!
//! ```
//!  create ──► slot (non-null)
//!       │ moveFromSlot + queue.append
//!       ▼
//!  queue (holds outer)
//!       │ queue.popFirst + slot=inner
//!       ▼
//!  slot (holds outer again)
//!       │ destroySlot
//!       ▼
//!  released
//! ```
//!

pub fn outer_transfer_via_slot(allocator: std.mem.Allocator, io: std.Io) !void {
    var slot: Slot = null;
    defer items.Event.EventHelper.destroy(allocator, io, &slot);
    try items.Event.EventHelper.create(allocator, io, &slot);
    const ev: *items.Event = items.Event.EventHelper.mustFromSlot(&slot);
    ev.code = 42;
    try helpers.expect(error.OuterTransferFailed, slot != null, "slot should be non-null after create");

    // Transfer to the queue — moveFromSlot checks the id and empties the slot.
    var queue: Queue = .{};
    const moved: *items.Event = items.Event.EventHelper.moveFromSlot(&slot) orelse return error.WrongId;
    queue.append(items.Event.EventHelper.toInner(moved));
    try helpers.expect(error.OuterTransferFailed, slot == null, "slot should be null after transfer");

    // Recover from the queue — assign back to slot.
    slot = queue.popFirst() orelse return error.EmptyQueue;
    try helpers.expect(error.OuterTransferFailed, slot != null, "slot should be non-null after recovery");

    const recovered: *items.Event = items.Event.EventHelper.mustFromSlot(&slot);
    try helpers.expect(error.OuterTransferFailed, recovered.code == 42, "wrong event code");

    items.destroySlot(&slot, allocator, io);
    try helpers.expect(error.OuterTransferFailed, slot == null, "slot should be null after destroy");
    // defer runs as no-op
}

const items = @import("../items/items.zig");
const helpers = @import("../helpers/helpers.zig");
const matryoshka = @import("matryoshka");
const Queue = matryoshka.queue.Queue;
const Slot = matryoshka.inner.Slot;
const std = @import("std");
