// SPDX-FileCopyrightText: Copyright (c) 2026 g41797
// SPDX-License-Identifier: MIT

//! One helper per outer type. It does the boring part.
//!
//! One line makes it: `const MSG = OuterHelper(Msg);`
//!
//! There is nothing to instantiate and nothing to keep.
//!
//! The helper finds the `Inner` field by type, so its name is yours to
//! choose. Zero such fields, or two, is a compile error naming the type.
//!
//! Two methods your outer declares, where the helper creates or releases it:
//!
//! - `pub fn init(self: *Outer, alloc: std.mem.Allocator, io: std.Io) !void`
//! - `pub fn finish(self: *Outer, alloc: std.mem.Allocator, io: std.Io) void`
//!
//! An empty body is fine. It says there is nothing to do, and an outer that
//! uses neither the allocator nor the `Io` says so with `_ = alloc;`. A container that
//! allocates itself never calls `create`, so it declares neither.
//!
//! Examples:
//! https://g41797.github.io/matryoshka-ztk/examples/helper/
const _doc_stub = void;

/// Generates the runtime type support for `Outer`.
///
/// What it gives you:
///
/// - the type's id, and the test against it
/// - the crossing from an `*Inner` or a `Slot` back to your pointer
/// - the crossing the other way
/// - create and destroy, which run your own `init` and `finish`
pub fn OuterHelper(comptime Outer: type) type {
    const field = innerFieldName(Outer);

    return struct {
        const desc: OuterInfo = .{
            .name = @typeName(Outer),
            .inner_offset = @offsetOf(Outer, field),
        };

        /// This type's id.
        ///
        /// One description per type, `const`, so its address is the identity.
        pub const ID: OuterId = &desc;

        /// True when the id is this type's.
        pub inline fn isIt(id: OuterId) bool {
            return id == ID;
        }

        /// Writes the id into an outer you allocated yourself.
        ///
        /// Runs once per outer, before it is used anywhere. `create` does it
        /// for you.
        pub inline fn stamp(self: *Outer) void {
            @field(self, field) = .{ .node = .{}, .id = ID };
        }

        /// The inner embedded in your outer.
        ///
        /// Cannot fail — the type is known at compile time.
        pub inline fn toInner(self: *Outer) *Inner {
            return &@field(self, field);
        }

        /// Your pointer, from a bare inner.
        ///
        /// Null when the inner belongs to another type. Reads the inner and
        /// changes nothing.
        pub inline fn fromInner(item: *Inner) ?*Outer {
            if (item.id != ID) return null;
            return @fieldParentPtr(field, item);
        }

        /// Your pointer, from a bare inner. Panics on another type.
        ///
        /// Panics in every optimization mode, and the message names the type
        /// asked for and the type that was there.
        pub inline fn mustFromInner(item: *Inner) *Outer {
            return fromInner(item) orelse wrongType("mustFromInner", item.id);
        }

        /// Your pointer, from the Slot holding it.
        ///
        /// Null when the Slot is empty or holds another type. Leaves the Slot
        /// full.
        pub inline fn fromSlot(slot: *const Slot) ?*Outer {
            const item = slot.* orelse return null;
            return fromInner(item);
        }

        /// Your pointer, from the Slot holding it. Panics on an empty Slot or
        /// another type.
        pub inline fn mustFromSlot(slot: *const Slot) *Outer {
            const item = slot.* orelse
                @panic("mustFromSlot: the Slot is empty");
            return fromInner(item) orelse wrongType("mustFromSlot", item.id);
        }

        /// Takes your outer out of the Slot.
        ///
        /// Null when the Slot is empty or holds another type, and then the
        /// Slot is untouched. On success the Slot is empty.
        ///
        /// Refuses an outer still on a chain. Take it off first.
        pub inline fn moveFromSlot(slot: *Slot) ?*Outer {
            const item = slot.* orelse return null;
            const out = fromInner(item) orelse return null;

            check(!inner.isLinked(item), "an outer crosses the border unlinked");
            slot.* = null;

            return out;
        }

        /// Takes your outer out of the Slot. Panics on an empty Slot or
        /// another type.
        ///
        /// The form for a caller who knows what is there and does not want to
        /// write the unwrap.
        pub inline fn mustMoveFromSlot(slot: *Slot) *Outer {
            const item = slot.* orelse
                @panic("mustMoveFromSlot: the Slot is empty");
            const out = fromInner(item) orelse wrongType("mustMoveFromSlot", item.id);

            check(!inner.isLinked(item), "an outer crosses the border unlinked");
            slot.* = null;

            return out;
        }

        /// Your pointer, from an `AnyOuter`.
        ///
        /// Null when it is empty or holds another type. Leaves it untouched.
        pub inline fn fromAny(any: *const AnyOuter) ?*Outer {
            if (any.id != ID) return null;
            return @ptrCast(@alignCast(any.ptr.?));
        }

        /// True when the outer is on a chain.
        pub inline fn isLinked(self: *Outer) bool {
            return inner.isLinked(toInner(self));
        }

        /// Allocates your outer, runs its `init`, stamps it, and fills the
        /// Slot.
        ///
        /// Frees the outer again when `init` fails, and passes the failure
        /// on. The Slot stays empty then.
        ///
        /// Refuses a Slot that is not empty on entry.
        ///
        /// Your `init` gets the allocator and the `Io`, and the toolkit keeps
        /// neither. ztk passes both where 3tk passes an allocator alone,
        /// because Zig 0.16 moved file, net, time and concurrency behind
        /// `Io`, and an outer that owns a connection cannot release it
        /// without one. An outer that keeps the `Io` in a field MUST NOT
        /// outlive the runtime that produced it.
        pub fn create(allocator: std.mem.Allocator, io: Io, slot: *Slot) !void {
            comptime requireHooks();
            check(slot.* == null, "an acquisition needs an empty Slot on entry");

            const item: *Outer = try allocator.create(Outer);
            errdefer allocator.destroy(item);

            try item.init(allocator, io);
            stamp(item);

            slot.* = toInner(item);
        }

        /// Runs your outer's `finish`, empties the Slot, and frees the outer.
        ///
        /// Does nothing on an empty Slot, so one `defer` covers every path
        /// out, including the path where the outer was never created.
        ///
        /// Refuses an outer still on a chain.
        pub fn destroy(allocator: std.mem.Allocator, io: Io, slot: *Slot) void {
            comptime requireHooks();

            const item = slot.* orelse return;
            check(!inner.isLinked(item), "an outer crosses the border unlinked");

            const out = mustFromInner(item);
            slot.* = null;

            out.finish(allocator, io);
            allocator.destroy(out);
        }

        fn wrongType(comptime call: []const u8, found: OuterId) noreturn {
            std.debug.panic(
                call ++ ": asked for {s}, found {s}",
                .{ @typeName(Outer), if (found == null) "<unstamped>" else info.infoOf(found).name },
            );
        }

        fn requireHooks() void {
            if (!@hasDecl(Outer, "init"))
                @compileError(@typeName(Outer) ++
                    ": an outer the helper creates declares `pub fn init(self: *" ++
                    @typeName(Outer) ++ ", alloc: std.mem.Allocator, io: std.Io) !void` — an empty body is fine");

            if (!@hasDecl(Outer, "finish"))
                @compileError(@typeName(Outer) ++
                    ": an outer the helper releases declares `pub fn finish(self: *" ++
                    @typeName(Outer) ++ ", alloc: std.mem.Allocator, io: std.Io) void` — an empty body is fine");
        }
    };
}

/// The name of the one `Inner` field of `Outer`.
///
/// Zero is a compile error. Two is a compile error. Both name the type.
fn innerFieldName(comptime Outer: type) []const u8 {
    comptime {
        var found: []const u8 = "";
        var seen: usize = 0;

        for (@typeInfo(Outer).@"struct".fields) |f| {
            if (f.type == Inner) {
                found = f.name;
                seen += 1;
            }
        }

        if (seen == 0)
            @compileError(@typeName(Outer) ++
                ": no Inner field, so it cannot be a Matryoshka outer");

        if (seen > 1)
            @compileError(@typeName(Outer) ++
                ": more than one Inner field, and exactly one is allowed");

        return found;
    }
}

const check = @import("internal/check.zig").check;
const inner = @import("inner.zig");
const AnyOuter = inner.AnyOuter;
const Inner = inner.Inner;
const OuterId = inner.OuterId;
const info = @import("internal/info.zig");
const OuterInfo = info.OuterInfo;
const Slot = inner.Slot;
const std = @import("std");
const Io = std.Io;
