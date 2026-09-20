// SPDX-FileCopyrightText: Copyright (c) 2026 g41797
// SPDX-License-Identifier: MIT

//! Produce-consume with defer cleanup.
//!
//! - Append 5 Events to a queue (producer).
//! - Pop each, sum the codes (consumer).
//! - defer releases any outers remaining on error, before or after the loop.
//!
//!
//! ```
//!  create × 5 ──► queue (producer)
//!       │ queue.popFirst × 5
//!       ▼
//!  destroySlot per outer (consumer)
//! ```
//!

pub fn produce_consume_with_defer_cleanup(allocator: std.mem.Allocator, io: std.Io) !void {
    var queue: Queue = .{};

    defer items.destroyQueue(&queue, allocator, io);

    var i: i32 = 0;
    while (i < 5) : (i += 1) {
        var slot: Slot = null;
        try items.Event.EventHelper.create(allocator, io, &slot);
        items.Event.EventHelper.mustFromSlot(&slot).code = i;
        queue.appendFromSlot(&slot);
    }

    var sum: i32 = 0;
    while (queue.popFirst()) |item| {
        var slot: Slot = item;
        defer items.destroySlot(&slot, allocator, io);
        const ev: *items.Event = items.Event.EventHelper.fromInner(item) orelse return error.CastFailed;
        sum += ev.code;
    }

    try helpers.expect(error.ProduceConsumeFailed, sum == 0 + 1 + 2 + 3 + 4, "wrong sum");
}

const items = @import("../items/items.zig");
const helpers = @import("../helpers/helpers.zig");
const matryoshka = @import("matryoshka");
const Queue = matryoshka.queue.Queue;
const Slot = matryoshka.inner.Slot;
const std = @import("std");
