// SPDX-FileCopyrightText: Copyright (c) 2026 g41797
// SPDX-License-Identifier: MIT

//! A last in, first out chain of outers. The pool's store.
//!
//! The link is the `node` field of each outer's inner, so a stack allocates
//! nothing and locks nothing. It is the same chain the queue uses and the
//! same insert guard, with the other end open.
//!
//! **Why the pool stores on a stack.** The outer that came back most
//! recently is the one handed out next, so a writer that went stale while
//! nothing was happening meets its next owner at once rather than after
//! every other item has been through. A queue would hand out the oldest
//! item, and a broken one could sit at the tail for as long as the pool
//! stays busy.
//!
//! Internal. Reachable from `pool.zig` and from nowhere else — it is not
//! re-exported by `matryoshka.zig`, and no public call takes one or hands
//! one back. The pool's border with a caller is a `Queue`: a close empties
//! every bucket into one.
const _doc_stub = void;

/// A chain of outers, held by their inners, with the last one in on top.
///
/// The top item points at itself, exactly as the last item of a queue does,
/// so `isLinked` is as exact here as it is there and an item on a stack of
/// one still reads as linked.
///
/// What it refuses, where runtime safety is on:
///
/// - an outer that was never stamped
/// - an outer already on a chain, including a chain of one
pub const InnerStack = struct {
    /// True when the stack holds no items.
    pub inline fn isEmpty(self: *const InnerStack) bool {
        return self._count == 0;
    }

    /// Number of items. A stored count, so O(1).
    ///
    /// This is the pool's `in_pool`: the count is read off the store itself,
    /// and there is no second one to keep true.
    pub inline fn len(self: *const InnerStack) usize {
        return self._count;
    }

    /// Puts the outer on top.
    pub fn push(self: *InnerStack, item: *Inner) void {
        self._guardInsert(item);

        item.node.next = if (self._top) |top| &top.node else &item.node;

        self._top = item;
        self._count += 1;
    }

    /// Takes the top outer off, or null when the stack is empty.
    ///
    /// The item comes back with a clear link. The caller repairs nothing.
    pub fn pop(self: *InnerStack) ?*Inner {
        const item = self._top orelse return null;

        const next = item.node.next.?;
        self._top = if (next == &item.node) null else inner.ofNode(next);

        self._count -= 1;
        inner.unlink(item);

        return item;
    }

    /// The insert guard, the same one the queue states.
    inline fn _guardInsert(self: *const InnerStack, item: *Inner) void {
        _ = self;
        check(item.id != null, "the outer was never stamped: make it with create, or stamp it once");
        check(!inner.isLinked(item), "the outer is already on a chain");
    }

    _top: ?*Inner = null,
    _count: usize = 0,
};

const check = @import("check.zig").check;
const inner = @import("../inner.zig");
const Inner = inner.Inner;
