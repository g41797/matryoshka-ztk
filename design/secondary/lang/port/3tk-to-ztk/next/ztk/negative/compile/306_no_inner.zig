// SPDX-FileCopyrightText: Copyright (c) 2026 g41797
// SPDX-License-Identifier: MIT

//! 306 — an outer with no inner field does not compile.

const NoInner = struct {
    seq: u32 = 0,
};

comptime {
    _ = m.helper.OuterHelper(NoInner).ID;
}

const m = @import("matryoshka");
