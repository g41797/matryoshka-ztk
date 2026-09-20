// SPDX-FileCopyrightText: Copyright (c) 2026 g41797
// SPDX-License-Identifier: MIT

//! 307 — an outer with two inner fields does not compile.

const TwoInners = struct {
    first: m.inner.Inner = .{},
    second: m.inner.Inner = .{},
};

comptime {
    _ = m.helper.OuterHelper(TwoInners).ID;
}

const m = @import("matryoshka");
