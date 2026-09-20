// SPDX-FileCopyrightText: Copyright (c) 2026 g41797
// SPDX-License-Identifier: MIT

//! The two small types everything else is written against.
//!
//! - `Inner` is the part you put inside your own struct.
//! - `Slot` is the place where one outer may be, or may not.
//! - The mailbox and the pool see an `*Inner` and nothing else.
//!
//! An outer's id is an opaque pointer, compared by address, so an id says what
//! a thing is and never which one it is. An unstamped outer's id is null, so a
//! zeroed inner is a valid unstamped inner.
//!
//! Examples:
//! https://g41797.github.io/matryoshka-ztk/examples/inner/
const _doc_stub = void;

/// An outer's id. Opaque: a caller passes it and compares it, and reads
/// nothing out of it.
///
/// Two outers of one type answer the same id. Two types answer two ids. The
/// helper's `ID` is where one comes from, and the toolkit is what reads it.
///
/// **Null is the id of an outer that was never stamped.** So the zero value of
/// an `Inner` is unstamped, and zeroed memory — `std.mem.zeroes`, a `@splat`
/// of `.{}` — is a valid unstamped outer rather than an accidental one.
pub const OuterId = ?*const anyopaque;

/// Embedded in every outer. Two fields, both for the toolkit.
///
/// The chain link is `node.next`:
///
/// - the next inner on the chain
/// - the inner itself when it is the last one on a chain
/// - null when the outer is on no chain
///
/// So the link test is exact, and it costs one compare. A chain of one is
/// seen, which a null-or-not test cannot do.
///
/// `id` is written once, by the helper's stamp, and never again.
///
/// The border with `std` — MUST:
///
/// - `node` is `std.SinglyLinkedList.Node`, so an outer may go onto a plain
///   `std.SinglyLinkedList`.
/// - It leaves this toolkit's `Queue` first. One item, one chain.
/// - The two chains disagree on the last link: ours points at itself, std's
///   is null. One field cannot hold both conventions at once.
/// - `std` does not clear the link it hands back. An item returning from a
///   std list arrives still pointing into it, and the crossing back refuses
///   it.
pub const Inner = struct {
    node: std.SinglyLinkedList.Node = .{},
    id: OuterId = null,
};

/// Where one outer may be, or may not.
///
/// Empty means the caller has nothing. Full means the caller has that outer.
/// A call that takes the outer leaves the Slot empty, with no line left for
/// the caller to write.
pub const Slot = ?*Inner;

/// One outer, type-erased, for a container the toolkit does not own.
///
/// - `ptr` is the address of the outer, not of its inner.
/// - `id` says what the outer is, and carries the offset to its inner.
/// - `ptr` is null exactly when `id` is null. Empty is that one state: the
///   default, and what `reset` writes back.
///
/// Read `ptr` and `id`, and write them only through `set` and `reset`.
///
/// MUST:
///
/// - An `AnyOuter` is moved, never copied. Two copies are two owners.
/// - A container closed while it still holds `AnyOuter` values leaks them, so
///   the caller drains it first.
/// - A raw cast of `ptr` loses alignment. Read it with `fromAny`.
pub const AnyOuter = struct {
    ptr: ?*anyopaque = null,
    id: OuterId = null,

    pub inline fn isEmpty(self: *const AnyOuter) bool {
        return self.ptr == null;
    }

    /// Fills an empty `AnyOuter`. Refuses a full one and a half-set pair.
    pub inline fn set(self: *AnyOuter, ptr: *anyopaque, id: OuterId) void {
        check(self.isEmpty(), "never overwrite a full AnyOuter");
        check(id != null, "an AnyOuter holds a stamped outer");
        self.* = .{ .ptr = ptr, .id = id };
    }

    pub inline fn reset(self: *AnyOuter) void {
        self.* = .{};
    }

    /// Moves the outer out of a Slot and into this empty `AnyOuter`, before a
    /// push into a queue the toolkit does not own.
    ///
    /// MUST: the Slot is full, the outer is stamped and unlinked, and this
    /// `AnyOuter` is empty. The Slot is empty afterwards.
    pub fn moveFromSlot(self: *AnyOuter, slot: *Slot) void {
        const item = slot.* orelse @panic("moveFromSlot: the Slot is empty");

        check(item.id != null, "the outer was never stamped: make it with create, or stamp it once");
        check(!isLinked(item), "an outer crosses the border unlinked");
        check(self.isEmpty(), "never overwrite a full AnyOuter");

        const bytes: [*]u8 = @ptrCast(item);
        self.set(@ptrCast(bytes - info.infoOf(item.id).inner_offset), item.id);
        slot.* = null;
    }

    /// Moves the outer out of this `AnyOuter` and into an empty Slot, after a
    /// pop from a queue the toolkit does not own.
    ///
    /// MUST: this `AnyOuter` is full, the Slot is empty, and the outer is
    /// stamped and unlinked. This `AnyOuter` is empty afterwards.
    pub fn moveToSlot(self: *AnyOuter, slot: *Slot) void {
        const ptr = self.ptr orelse @panic("moveToSlot: the AnyOuter is empty");

        check(slot.* == null, "never overwrite a full Slot");

        const bytes: [*]u8 = @ptrCast(ptr);
        const item: *Inner = @ptrCast(@alignCast(bytes + info.infoOf(self.id).inner_offset));

        check(item.id != null, "the outer was never stamped: make it with create, or stamp it once");
        check(!isLinked(item), "an outer crosses the border unlinked");

        slot.* = item;
        self.reset();
    }
};

/// Takes the bare inner out of a Slot, for a container of your own.
///
/// The way out of the toolkit — MUST:
///
/// - the outer is stamped
/// - it is unlinked as it crosses
/// - the Slot is cleared
///
/// It answers an `*Inner`, whatever type the outer is. The way back is
/// `fillSlot`.
pub fn takeFromSlot(slot: *Slot) *Inner {
    const item = slot.* orelse @panic("takeFromSlot: the Slot is empty");

    check(item.id != null, "the outer was never stamped: make it with create, or stamp it once");
    check(!isLinked(item), "an outer crosses the border unlinked");

    slot.* = null;
    return item;
}

/// Puts a bare inner back into an empty Slot.
///
/// The way back in — MUST:
///
/// - the outer is stamped
/// - it is unlinked as it crosses
/// - the Slot is empty
///
/// A `std.SinglyLinkedList` does not clear the link it hands back, so an item
/// coming straight from one is still pointing into it and is refused here.
pub fn fillSlot(slot: *Slot, item: *Inner) void {
    check(slot.* == null, "never overwrite a full Slot");
    check(item.id != null, "the outer was never stamped: make it with create, or stamp it once");
    check(!isLinked(item), "an outer crosses the border unlinked: a std list leaves its link set");

    slot.* = item;
}

/// True when the outer is on a chain.
///
/// Exact. The only item of a chain points at itself, so it reads as linked.
pub inline fn isLinked(inner: *const Inner) bool {
    return inner.node.next != null;
}

/// The inner holding this std node.
pub inline fn ofNode(node: *std.SinglyLinkedList.Node) *Inner {
    return @fieldParentPtr("node", node);
}

/// Clears the chain link.
///
/// Called for the caller by every removal. Nothing hands back a linked item.
pub inline fn unlink(inner: *Inner) void {
    inner.node.next = null;
}

const check = @import("internal/check.zig").check;
const info = @import("internal/info.zig");
const std = @import("std");
