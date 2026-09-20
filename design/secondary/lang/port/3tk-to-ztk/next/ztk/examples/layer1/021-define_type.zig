// SPDX-FileCopyrightText: Copyright (c) 2026 g41797
// SPDX-License-Identifier: MIT

//! Define an outer type.
//!
//! - Message struct embeds an Inner field. Its name is free.
//! - OuterHelper(Message) gives the id, stamp, and toInner.
//! - stamp sets the id on a stack value, no heap.
//! - isIt checks the id.
//! - toInner reaches the embedded Inner — the way in.
//! - The inner carries the id and starts unlinked, ready to be placed.
//!
//! Coming back the other way is fromInner. It needs an inner whose type is
//! not known statically, so it is shown in 023-tag_dispatch.
//!
//!
//! ```
//!  stack: var msg: Message
//!       │
//!  MessageHelper.stamp ──► msg.hdr.id set (no alloc)
//!       │
//!  MessageHelper.toInner ──► *Inner (the way in)
//!       │
//!  inner carries the id, not linked yet
//!  (stack-allocated — no release needed)
//! ```
//!

pub fn define_an_outer_type(allocator: std.mem.Allocator, io: std.Io) !void {
    _ = .{ allocator, io };

    // A Message on the stack. No allocator involved.
    var msg: Message = .{ .text = "hello", .priority = 1 };
    MessageHelper.stamp(&msg);

    // The id identifies the type at runtime.
    try helpers.expect(error.DefineTypeFailed, MessageHelper.isIt(msg.hdr.id), "expected Message id");
    try helpers.expect(error.DefineTypeFailed, !items.Event.EventHelper.isIt(msg.hdr.id), "unexpected Event id");

    // toInner reaches the embedded Inner. Nothing else needs to know
    // the field is called hdr.
    const inner: *Inner = MessageHelper.toInner(&msg);

    // The inner travels with its id, so a holder can identify it later.
    try helpers.expect(error.DefineTypeFailed, MessageHelper.isIt(inner.id), "inner must carry the Message id");

    // A fresh outer sits on no chain yet.
    try helpers.expect(error.DefineTypeFailed, !matryoshka.inner.isLinked(inner), "new outer must be unlinked");
}

pub const Message = struct {
    hdr: Inner = .{},
    text: []const u8 = "",
    priority: u8 = 0,
};

pub const MessageHelper = matryoshka.helper.OuterHelper(Message);

const items = @import("../items/items.zig");
const helpers = @import("../helpers/helpers.zig");
const matryoshka = @import("matryoshka");
const Inner = matryoshka.inner.Inner;
const std = @import("std");
