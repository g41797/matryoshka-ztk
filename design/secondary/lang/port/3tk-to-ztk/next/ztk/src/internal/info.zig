// SPDX-FileCopyrightText: Copyright (c) 2026 g41797
// SPDX-License-Identifier: MIT

//! What one outer type is, and how the toolkit reads it off an id.
//!
//! Internal, so it has no page and user code cannot name it. An id is
//! `inner.OuterId` — an opaque pointer a caller passes and compares — and this
//! is the only place that turns one back into the type's description.
//!
//! `helper.zig` builds one of these per outer type, `const`, so it lives in
//! read-only memory and its address is the identity. Nothing else builds one.
//!
//! There is no sentinel instance. An unstamped id is null, so the zero value of
//! an `Inner` is unstamped and no fake description has to exist to be pointed
//! at.

/// One outer type's description.
///
/// - `name` is the type's own name. It goes into panic text.
/// - `inner_offset` is where the `Inner` field sits in the outer.
pub const OuterInfo = struct {
    name: []const u8,
    inner_offset: usize,
};

/// The description an id points at.
///
/// MUST: the id is not null. Every caller checks that first — the checks live
/// at the toolkit's borders, where the message can say what the caller did
/// wrong. Where a build compiles those checks out, a null id faults here
/// instead of computing a plausible-looking address from nothing.
pub inline fn infoOf(id: ?*const anyopaque) *const OuterInfo {
    return @ptrCast(@alignCast(id.?));
}
