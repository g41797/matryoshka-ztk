# next — session log

Append-only. Newest entries at top. Not read by default.

Read it when auditing history, when asking what was done about something, or  
when resolving a question about a past decision. Otherwise append and move on.

---

## 2026-09-20 — SURFACE

Owner named SURFACE and asked for step 1 first, as the charter in
`next-staging-plan-017.md` required. No code was written until every ruling was
in hand; the plan is now 018 and 017 is in `backup/`.

**Step 1, the comparison.** The `docs` step is byte-for-byte identical in the two
trees and both document the module rooted at `src/matryoshka.zig`, so the root
file was the whole difference. Eight differences were reported. The two that
mattered: the old root exports 6 names and the new one exported 23, all flat; and
all five of the new root's file imports were private, so five written `//!`
module headers — `inner`, `queue`, `helper`, `mbox`, `pool` — were unreachable by
autodoc, while in the old tree the same text is the body of three namespace
pages. Also reported: a `_doc_stub` the flat root forced, `internal_tests.zig`
shipping inside `sources.tar`, and six `//!` header links pointing at the frozen
mkdocs pages. The owner ruled the links wait for COMMENTS.

**The owner's questions drove the rest, and two of them changed the design.**

- *Why are so many functions open, when the user's access is the helper?*
  Counting calls through the module alias, with `examples/` read as the user's
  voice: `OuterInfo` 0 anywhere outside `src/`, `UNSTAMPED` 0, `isStamped` 0,
  `outerAddr` 0. They are called by `helper.zig` and `inner.zig`. The flat root
  published them because a flat root publishes whatever a file declares.
- *Do we need internal tests now?* No. All five properties are asserted through
  the pool's public surface, and scenario 289 was implemented twice in two
  binaries for a scenario the spec asks for once. `InnerStack` has one caller.
  The owner ruled it dropped.
- *Can visibility be restricted, or hidden in doc gen?* Autodoc has no hide
  attribute and renders exactly what a `pub` chain from the root reaches, so
  documented and reachable are one set. The owner then stated the need exactly —
  restrict the web, not the call — which led to a proposed second, curated docs
  root, and then to finding its limit: it may withhold names but never re-shape
  them, or the page lies about how to call. With `OuterInfo` moved under
  `internal/` it would have withheld an empty list, so the owner dropped it and
  ruled hiding is per file under `src/internal/`, the way `check.zig` already
  works.
- *What does flat `Queue` solve?* Nothing — 53 of its 136 sites are a
  file-local `const Queue = matryoshka.Queue;`, so the stutter appears once per
  file. The suggestion was withdrawn, and it also broke the line the owner had
  drawn: a flat name is for what application code keeps, which a drained queue
  is not.

**One correction owed and made.** This side twice told the owner the docs root
made the stored question free. It did not: hidden means outside the published
files, and `tests/` reaches the toolkit only through `@import("matryoshka")`, so
hidden also means untested. Said plainly before any code was written.

**Step 3, the code.** The root is five namespaces plus `VERSION`, `Mbox` and
`Pool`. `OuterInfo` moved to `src/internal/info.zig`, with `inner.zig` and
`helper.zig` path-importing it. `src/internal_tests.zig`, the five test blocks
and their fixtures in `internal/stack.zig`, and the `imod` and `src_tests` entries in `build.zig`
are gone. 690 call sites were rewritten by one scripted pass over `tests/`,
`examples/`, `negative/`, `build.zig` and `ztk/design/`; it missed the single
`@import("matryoshka").Slot` form, which the first gate caught and which was
fixed by hand — the pass matched the module alias only.

202 tests became 197: 196 pass and 1 skips, in all four modes. Six gates green.
`zig build docs` confirms `sources.tar` no longer carries a test root.

**The stored question was ruled the same day.** The owner ruled `UNSTAMPED`,
`isStamped` and `outerAddr` off the site. `UNSTAMPED` went to `internal/info.zig`,
the two functions to a new `internal/stamp.zig`, whose import is named `stamping`
in `helper.zig` because `stamp` is already the helper's own method — the first
build caught the clash as an ambiguous reference.

**The seven-test estimate was wrong, and reading the sites showed why.** Seven was
a count of call sites, not of tests. Only scenario 202 lost its subject, since the
crossing back from a bare `*Inner` *was* `outerAddr`; it is retired in
`task1-tests-003.md` with the ruling named, and the behaviour stays covered
through `slotToAny` and scenario 321. 203 and 204 were reworded and keep their
claims — the typed read answers null for an unstamped inner, and a field is
readable through a pointer whose type is not nameable, so the zero offset is read
off the inner's own id. Three more assertions were dropped as redundant beside
`isEmpty` and `fromInner`. 196 tests: 195 pass, 1 skips. Verified with a throwaway
module that `m.inner.isStamped` no longer resolves while `m.inner.Slot` does.

**A third ruling, after the owner read the pages.** The generated split looked
strange: types on one page, the functions that take them on another. The cause
was one thing — the four border functions were on the `helper` page while `Slot`,
`Inner` and `AnyOuter` were all on `inner`'s, so a reader at `Slot` had no way to
move anything into or out of it. `slotToAny` and `anyToSlot` became methods on
`AnyOuter`, which already had `set`, `reset` and `isEmpty`; `takeFromSlot` and
`fillSlot` moved beside `Slot`, which is an optional and cannot carry methods;
`helper.zig` is `OuterHelper` alone, which its header always claimed. `mbox` and
`pool` were already a type plus its `new` plus its result reader, and that is why
the asymmetry showed at all. `queue` stays a one-type page: `Queue` has a dozen
methods, and folding it into `inner` would rebuild the grab-bag this stage took
apart. Autodoc still splits every page into Types and Functions on its own, which
no source change touches — what the sources decide is which page a name is on.

`outerAddr` fell out of use in the same move, because `AnyOuter.moveFromSlot`
computes the address itself rather than import `internal/stamp.zig` and make an
`inner` to `stamp` to `inner` cycle. It was removed as post-stage cleanup, so
`internal/stamp.zig` is `isStamped` alone, with two callers. 29 call sites
changed, and the examples catalog under `kitchen/docs/examples/` was regenerated
because it carried the old spelling. Still 196 tests.

**A fourth ruling, from the preview: the id is opaque.** The owner looked at the
generated page and found `OuterInfo` still on it. The cause corrects what this
side had claimed twice: moving a file under `internal/` hides it from the
navigation and from user code, but **a type named by a published declaration is
reached through that declaration's own type** — `pub const OuterId = *const
OuterInfo` put it straight back on the page.

The owner asked why not `usize` or `*const anyopaque` with a cast, and then made
the observation that decided the shape: a Zig `*const T` cannot be 0, but a
`usize` can, and unstamped is 0. `UNSTAMPED` existed *only* because an unstamped
id needed something real to point at — a fake `OuterInfo` in read-only memory
named `<unstamped>`. An **optional** pointer can be 0, so the sentinel is not
hidden but deleted. `OuterId` is `?*const anyopaque` and unstamped is `null`.

Four candidates were probed rather than argued, in all four modes. `usize`: hides
as much, but this API traffics in `usize` — `countOf` returns one, `sendLimited`
takes a limit — so `countOf(n)` with a count would compile and ask about an
identity that is a number. `?*const anyopaque`: rejects the integer, accepts
another pointer. `?*const Identity`, an `opaque {}` handle: rejects every wrong
argument, at the cost of one empty type on the page. The owner chose `anyopaque`,
and the measurement that supports it is that no example and no negative program
constructs an id or reads a field off one — every id comes from the toolkit.

Measured and kept: zeroed memory is now a valid unstamped outer; `@sizeOf(Inner)`
is still 16, since an optional pointer is pointer-sized; distinct types keep
distinct ids, including two of identical shape and offset; and a missed check
faults at `infoOf` instead of returning the inner's own address, which the
sentinel's zero offset used to make it do. My earlier claim that `usize` would
"read through a wild pointer" was also wrong and withdrawn — `@ptrFromInt` is
checked in the safe modes, and the probe showed *cast causes pointer to be null*
and *incorrect alignment*.

Scenarios 202 and 204 retired; 201 and 203 reworded to what a caller can read.
The plan to move 204 into `negative/` was dropped on inspection: program 321
already asserts the refusal it guarded, and the near-miss property it measured no
longer exists. `internal/stamp.zig` went away too — `isStamped` is
`item.id != null` at its two call sites. 195 tests: 194 pass, 1 skips.

**Documents.** `3tk-to-ztk-007.md` written with the new section **The module
surface**, 006 moved to `3tk-to-ztk/backup/`, and every live reference
re-anchored in this stage — `next-status.md`, the plan, and four documents under
`ztk/design/`. `task1-tests-003.md` written for the retirement of 202, with 002
moved to `backup/` and its two live references re-anchored; its header also
carries the version number now, which 001 and 002 both got wrong. The log is left alone, because a past entry names the version that
was current when it was written. `next-status.md` was updated in place. The
stored question is written in 007's **Open questions** and pointed at from
`next-status.md`, so repeating it does not depend on this entry being read.

Post-stage cleanup: `outerAddr` removed as dead, the root's `_doc_stub` went away with the flat list that
needed it, and `internal/stack.zig` lost the test-only `Item`, `ITEM` and
`stamped` fixtures along with its test blocks. Nothing else was found.

---

## 2026-09-20 — LANDING

Owner named LANDING. Two edits to `ztk/kitchen/docs/index.md`: the `<a href="manifesto/">`
wrapper around the logo is gone, and `target="_blank" rel="noopener"` is gone from the
Lines Of Code badge. Nothing else touched. Gate 4 checked after the edit.

---

## 2026-09-20 — SITE

Owner named SITE. Plan 015 is written, 014 is in `backup/`, and the three live
references to it are re-anchored (status, and the two creation documents).

Copied from the frozen root into `ztk/kitchen/`: `mkdocs.yml`, `docs/index.md`,
`docs/favicon.ico`, `docs/assets/`, `docs/stylesheets/`, `hooks/count_lines.py`,
and nine tools. `count_readme_loc.sh` came from 3tk's `scripts/`. Two edits:
the navigation is `Home: index.md` only, and `count_readme_loc.sh` resolves
`../../README.md`, one level deeper than in 3tk. The 148 markdown pages were not
copied.

Checked: every script roots itself from its own location and none reaches above
`ztk/`. `count_src_loc.sh` prints 881; `count_readme_loc.sh` on a blank-and-rule
test file prints 2, as expected. Gate 4 exits 0. Gates 1 to 3, 5 and 6 were not
re-run: `src/`, `tests/`, `build.zig` and `negative/` did not change.

## 2026-09-20 — the documentation rulings, part two

Same day, same session. The owner read plan 014 and corrected its shape.

**The correction.** Writing the README is itself work with stages, decisions and
open questions, so **it deserves its own document**. The plan carries a short
description and a reference, and nothing more. The charter text written into 014
earlier that day was the wrong place for it. The model is 3tk's own
`3tk-readme-creation-003.md` — 753 lines, at its third version, holding what is
decided, what is open as a debt table, the reader, the required order, the tone
reference, why two drafts were rejected, a measured inventory of the source, the
sources and their standing, a module mapping table, and a changelog.

**What that document taught, beyond its shape.** Its mapping table exists so the
README's surviving wording becomes the module doc comments — *"its second reader
is a later plan."* So the README document and the doc-comment document are not
independent, and they are written in that order. The parameter list the owner
asked for is not a separate audit file; it is a section, the way 3tk's
**measured inventory** is.

**Written.**

- `ztk/design/readme-creation-001.md`. Ten rulings, five open questions, two
  debts, the reader, the required order, the tone reference, the measured
  inventory of `ztk/src/` with line numbers, **a 27-row parameter list** of 3tk
  facts needing a ztk answer, the sources and their standing, the module mapping
  table, and 3tk's 34 rulings listed as candidates rather than imported.
- `ztk/design/comments-creation-001.md`. Five rulings, three open questions, the
  four failures `rules-050.md` Part 4 exists to prevent, the work list from the
  mapping table, and the order.
- Plan 014's README and COMMENTS sections cut to a description and a link.
- `count_readme_loc.sh` added to SITE's copy list, from 3tk's `scripts/` rather
  than the frozen root — the old tree has no counterpart. Its default target
  needs one tweak, noted in the charter.

**What the measurement found.** `ztk/src/` is 2,385 lines across ten files. The
parameter list's five classes are SWAP, FIND, BUILD, RULE, NUMBER, and the
counts are 18 SWAP, 2 FIND, 2 BUILD, 4 RULE, 1 NUMBER. Three findings worth
naming:

- **ztk has one module where 3tk has six**, and one line of the 3tk README says
  six.
- **There is no list of eight faults.** Zig error sets are per call, and two
  union with `Io.Cancelable`, which 3tk has no equivalent of.
- **`P-27` is not a translation.** The futures, the two `Result` unions and
  cancellation are things ztk has and 3tk does not, and the required order has
  no step for them. A round must not smuggle them in as a feature bullet.

**Two debts the README will hit.** No minimal channel-to-mailbox example for
step 2, and no step-1 example that reads as a story — `021-define_type.zig` is
63 lines of assertions.

**Gate 4 caught four dead references in the new documents**, all of them names
of files in the other repository or files that do not exist yet. Reworded rather
than excepted. One wrong cross-reference of my own — `O-27` for `P-27` — found
by re-reading.

**Not done:** no README text, no doc comment, no copied file, no change to
`src/`.

---

## 2026-09-20 — the documentation rulings

No code, no prose, no copied files. A session was started on DOCS, read its
charter and the whole public surface, and was stopped by the owner before it
wrote anything. What came out of the stop is a set of rulings, and those are
now in `3tk-to-ztk-006.md`. 005 is in `backup/`.

**Why it was stopped.** The session presented its intent for DOCS and the owner
answered that the new tree is not obliged to follow what the old ztk did before
the port to 3tk. The session had been treating the inherited arrangement — the
examples layout, the numbering, the seven `examples-*` steps, the api reference
as a book of seven parts — as settled. It is not. That is now written down in
006 as **The new tree is not bound by the old arrangement**.

**The first mistake, recorded because it is the kind that repeats.** The
session wrote the rulings into its own memory rather than into a document. The
owner corrected it: this material belongs in the subject document, which every
stage reads first. A memory is invisible to the next session after a clear.

**What the owner ruled**, in the order it arrived:

- Everything stays under `next/ztk/`. Backporting to the root is its own stage.
- A file that deserves versioning gets a new number when it changes. `README.md`
  is the exception — a README cannot carry a suffix, so it is updated in place.
- The project publishes three things: the README, the landing page, and the Zig
  documentation generated from the sources.
- ztk's deployment matches 3tk's, with one exception: 3tk has no mkdocs part and
  so no landing page, and ztk keeps one.
- The landing page gets two edits. The picture stops being a link. The Lines Of
  Code badge opens in the same tab.
- The old mkdocs pages are frozen, still generated, not visible. Only what the
  landing page needs is copied in — **option 2**, chosen over exempting the
  path in the gate.
- The api reference book is **dropped**. The per-module part of each generated
  page takes over what mkdocs carried.
- The README is its own stage and the most important one. It starts as the 3tk
  README with only the facts that are wrong for Zig rewritten.
- The doc comment rules already exist: `rules-050.md` Part 4.

**The measurement behind option 2.** Copying `kitchen/docs/` into the new tree
would have put roughly 1,100 hits through `check_next_docs.sh` checks 2 and 3:
`Item` 498, the retired node word 485, the retired handle word 79, `lifecycle`
21, the retired tag word 11. The gate that defends the new vocabulary would have
stopped being readable. The owner chose to copy only the landing page's own
material and leave the 148 pages in the frozen root.

**Three stale names found inside 005**, by reading it rather than by a report.
Its **Where it lives** table and its continue prompt both named
`next-staging-plan-004.md`, and its stage table named it a third time. The live
plan was 013. The prompt also still offered `SPEC | CORE`. This is the
copy-goes-stale failure the status file already warns about, found in the
document that warns about it. 006 replaces all three with the rule — the
highest-numbered plan present — and points at the three-line prompt in the plan
instead of carrying its own copy.

**On who writes what.** The owner said plainly that this side usually writes
awful, non-human text, and asked how to use it anyway. The answer recorded in
006: the owner or another model drafts, and this side supplies material before a
draft and checks and cuts after one. The 3tk README was drafted by ChatGPT and
improved here, and that division is the evidence. Constraints that can be
checked were written down in place of instructions about quality.

**What changed on disk.**

- `3tk-to-ztk-006.md` written, 005 moved to `backup/`.
- `next-staging-plan-014.md` written, 013 moved to `backup/`. DOCS is marked
  replaced and five charters are added: SITE, LANDING, PREVIEW, README,
  COMMENTS, plus WORKFLOW at PROMOTE.
- `next-status.md` updated in place: **Next** is SITE, and **Reported, not
  actioned** grew by six references to 005 in the frozen root.
- Four live files re-anchored from 005 to 006: this tree's status and plan, and
  `ztk/design/task1-tests-002.md` and `task2-tests-002.md`.

**Not done:** no file copied from `kitchen/`, no landing page edit, no README
text, no doc comment, no change to `src/`. Gate 4 was run; the other five were
not, because no code changed.

---

## 2026-09-20 — BRIDGE

The bridge example is written. Plan 012 became 013 and 012 is in `backup/`.
Model: Sonnet 5.

- The stage opened with five small examples in the charter. The owner
  redirected it: the README needs working code above all, in the shape of a
  server — handlers on an `Io.Queue` of a union, workers on a shared mailbox,
  replies as `AnyOuter`. The first plan was not built.
- `examples/bridge/104-server_handler_and_workers.zig`, `Greeting.zig`,
  `bridge.zig`; `tests/examples_bridge.zig`; an `examples-bridge` step. The
  wrapper was first left out of `matryoshka_tests.zig`, so gates 1 and 2 did
  not run it; found and fixed before closing.
- The README is DOCS' work, by ruling. `ztk/README.md` stores the bridge
  context.
- 202 tests, 201 pass and 1 skips. Six gates green.

## 2026-09-20 — FUTURES

`Pool.Result`, `getWaitResult` and `Pool.getWaitFuture` are written, on the
shape of `receiveResult`. Plan 011 became 012 and 011 is in `backup/`;
task2-tests 001 became 002 and 001 is in `backup/`. Model: Sonnet 5.

- Owner's ruling: fix the unknown-identity finding. The `check(false, ...)` in
  `get`, `getWait`, `put` and `countOf` is removed, so the error return is the
  answer in every build, as PL7 says. Test 285 and example 101 lost their
  safe-build skip.
- `Pool.Result` has an `unknown_identity` variant, which `Mbox.Result` has no
  counterpart for.
- Six tests in `tests/layer4_pool_futures.zig`; ten examples ported (028, 031,
  046, 047, 048, 050, 056, 058, 060, 061) by a forked agent, and the gates
  re-run here. 201 tests, 200 pass and 1 skips. Six gates green.

## 2026-09-20 — FUTURES added before BRIDGE

Owner's ruling. The ten examples waiting for the pool's futures had no stage.
FUTURES holds them and the futures. Plan 010 became 011 and 010 is in
`backup/`. BRIDGE keeps `AnyOuter` alone in the queue as its main path and
carries the tagged-union example as a secondary one, on the advice of 3tk's
README (step 2 of "How to start"; the union is a workaround it names). No code.

## 2026-09-20 — ANY

`AnyOuter`, `slotToAny`, `anyToSlot` and `fromAny` are written, as ruled. Plan
009 became 010 and 009 is in `backup/`; task1-tests 001 became 002 and 001 is in
`backup/`. Model: Sonnet 5.

- `AnyOuter` is in `inner.zig`: `ptr`, `id`, `isEmpty`, `set`, `reset`. Empty is
  one state, the default and what `reset` writes.
- The free functions return nothing and are type-blind. They use `outerAddr` and
  the offset in the id. `fromAny` is the typed read and returns null on an empty
  value or another type.
- No `must` twin, as the charter names none.
- Six tests, 320 to 325, in `tests/layer1_any.zig`, and three negative programs,
  320 to 322. 185 tests, 183 pass and 2 skip in Debug. Six gates green.

## 2026-09-20 — before DOCS: ANY and BRIDGE

Owner's ruling after reading 3tk's README: co-existence with the I/O side is
part of the process, and ztk had no bridge examples beyond 098. Two stages were
added, ANY and BRIDGE, and DOCS moved after them. Plan 008 became 009, and 008
is in `backup/`.

The three rulings on `AnyOuter` are in the plan under **ANY**: the free-function
pair, the fields `ptr` and `id`, and `ptr` pointing at the outer. The use the
owner named is an `Io.Queue` of a tagged union where `AnyOuter` is one variant.
No code was written.

## 2026-09-20 — EXAMPLES

The examples module is written. Plan 007 became 008 and 007 is in `backup/`.
Run unattended on the owner's word, with six forks: layer 1, layer 2, layer 3,
and layer 4 in three parts.

**What the foundation was.** Four demo outers, two hook sets, `IdTable`, the
build's `examples` module and one step per group, written before the forks so
the groups did not collide.

**Result.** 69 example files, 64 example tests, 179 tests in all. Six gates
green. `src/` untouched.

**Findings.** `Pool.put` panics on an unknown identity in a safe build rather
than returning the error PL7 rules. Ten examples wait for the pool's futures.
`std` `popFirst` leaves the link set. A wrapper on `global_single_threaded`
cannot use `io.concurrent`.

## 2026-09-20 — POOL

The pool is written and the tree has all three layers. Plan 006 became 007 and
006 is in `backup/`.

**What was read before anything was written.** `3tk/src/pool.c3` end to end,
the POOL charter, the nineteen answers, both trees' layer-1 and layer-2 code,
and the task1 scenarios 63 to 88 and 280 to 291. The charter's line numbers
were checked rather than taken.

**Three questions went to the owner, and all three changed the code.**

1. **`countOf` refuses an unknown identity.** 3tk answers 0 (`pool.c3:387`)
   and PL7 had only reached `get`, `getWait` and `put`. The owner ruled the
   error return. It is the one query with no other way to tell an unknown
   identity from an empty store.
2. **The futures wait for task2** — and, the owner added, they belong in the
   container's own file, near its end, never in the module header. That is
   where `mbox.zig` already keeps `receiveResult`, so the rule was being
   followed before it was stated.
3. **The containers declare `init` and `finish`, privately.** This one is
   worth the space, because the session's first answer was wrong and the
   measurement is what settled it.

**The private hooks, measured in three steps.** The session claimed a doc
paragraph was enough, and said — wrongly — that `Mbox` does not use the
helper. It does: every crossing on `Mbox` forwards into `OuterHelper(Mbox)`,
and the only two calls it never makes are `create` and `destroy`. The owner
asked the question that mattered: can a user's own file name `m.Mbox` as the
outer of its own helper? It can — `matryoshka.zig` exports `OuterHelper` and
`Mbox` both. So:

- **Today, it does not compile.** A probe file with
  `const MBX = m.OuterHelper(m.Mbox); MBX.create(...)` fails at
  `helper.zig:194` with the message naming the missing `init`.
- **With two public empty inlines it compiles, and the result is broken.**
  The same probe against a scratchpad copy built clean, ran `create`, and
  died on the first real call: `General protection exception` inside
  `std.Io.futexWaitUncancelable`, three frames from the mistake, because
  `_io` was never set.
- **With the two declarations private it does not compile again**, with the
  original message. `@hasDecl` cannot see a private declaration from another
  file, so the refusal is exactly what it was.

The owner's call was private, and it is the one that keeps both things: a
declaration a reader meets at the bottom of the type, and the compiler still
refusing the misuse. The old mechanism — answer 10's lazy analysis — is
replaced without its promise being weakened.

**What the stage wrote.** `src/internal/stack.zig` and its five tests first,
then `src/pool.zig`, then `tests/hooks.zig`, `tests/layer3_pool.zig` and
`tests/layer3_threads.zig`, then the negative programs. `matryoshka.zig`
exports `Pool` and `newPool`; `queue.zig` was not touched, and neither was any
other layer-1 file.

**A second test root, because the first could not reach the stack.**
`InnerStack` is internal, so the `tests/` tree — which meets the toolkit
through `@import("matryoshka")` — cannot name it at all. Test blocks inside
`src/internal/stack.zig` were not collected either: measured, `zig test` over
the module root reported **0 tests**, because a file two imports deep from a
test root contributes none. So `src/internal_tests.zig` is a root of its own
that imports the internal file, and `build.zig`'s `test` step runs both roots.
The kitchen scripts did not change, since they call `zig build test`.

**The close-on-put path, written as 3tk writes it** (`pool.c3:305-333`). `put`
takes the outer out of the caller's Slot before the hook runs, so the Slot is
empty on every path out. If the pool closed while the hook ran, the call
builds its own queue — the outer it took, then everything in `extra` — unlocks,
hands it to `on_close`, and drops `_active` only after relocking. Scenario 282
holds it under a flag the test controls rather than under a timing window: the
hook sits inside the pool until the test says otherwise, so the close is
guaranteed to land in the middle of it. The count it checks is 3, and losing
any one of them would show.

**Scenario 286 is two negative programs, not one.** A duplicate identity and
an empty set are both `check`s at creation, and a program can only die once.
They are `286_duplicate_identity.zig` and `286_empty_identities.zig`, Debug
and ReleaseSafe only. 311 and 313 run in all four modes, because
`Pool.destroy` aborts with `std.debug.panic`. 313 does not rest on an
ordering: its hook spins on a flag the program never sets.

**Scenario 285 skips in the safe modes**, the way 251 does. PL7 asks for the
error return *and* the safe-mode check, and in a safe build the check aborts
first, so the error return can only be observed where the check is compiled
out. Both halves are real; the test reaches the half a test can reach. The
suite now skips two in the safe modes and one in the fast two.

**Gates.** All six. Debug and all four optimization modes: 115 tests, 113 pass
and 2 skip in the safe modes, 114 pass and 1 skips in the fast two. Cross
builds for the three targets, `zig fmt --check`, `check_next_docs.sh` at exit
0, and `zig build negative` green in each of the four modes with sixteen
programs.

**One wrong turn inside the stage.** `std.Thread.Mutex` is gone in 0.16, and
the hook recorder was written with one. It became an `Io.Mutex` taken with the
`Io` the fixture already holds — which is what the rest of the tree does
anyway.

**Post-stage cleanup.** The module header's line saying the pool is not here
yet was removed. Nothing else was found obsolete: the counter, the `destroy`
guard and the query shape were copied from `mbox.zig` unchanged rather than
re-invented, which is what MBOX designed them for.

---

## 2026-09-20 — ENV

`init` and `finish` take the `Io` beside the allocator. Plan 005 became 006 and
005 is in `backup/`. No behaviour changed and no scenario was added.

**What changed.** `create(alloc, io, slot)`, `destroy(alloc, io, slot)`,
`newMbox(alloc, io, slot)`, and the two hooks. The `create` doc comment carries
the language note and the MUST on an `Io` kept in a field. Ten test outers,
the test helpers, four test files and the negative programs follow.

**Two things the charter did not list.** `std.testing.io` is a compile error
outside a test, so the running negative programs (302) build a `Threaded`, and
the compile-only ones (308, 309) pass `undefined`, since the code never runs.
The three thread bodies in `layer2_threads.zig` use `std.testing.io` because
the fixture is not in their scope.

**Gates.** Debug and all four modes: 80 pass, 1 skip. Cross builds, `zig fmt`,
`check_next_docs.sh` and `zig build negative` in four modes all pass. The first
negative run failed on 308 and 309 because `build.zig` still expected the old
message; it was updated.

**Post-stage cleanup.** Nothing obsolete found.

---

### 2026-09-20 — POOL, the design session

Deliberately `###`, for the reason the MBOX addendum below gives: check 4 of
`check_next_docs.sh` counts `## <date> — <name>` as a completed stage, and no
stage completed here. POOL was named and POOL did not run. **Plan 005 was
written, 004 moved to `backup/`.** No code, no gate run but the documents one.

**What happened.** The session read the sources before writing, as the CORE
charter's "checked before the stage" rule asks, and came back with three
findings. The owner ruled on all three.

**1. The pool's store is a stack.** The session had planned a `Queue.prepend`,
so a per-identity queue could be last in, first out — which is LS4's own
wording. The owner said the pool does not use a list, it uses an internal
stack, and asked for 3tk to be checked. It confirms:
`PoolBucket { typeid tag; InnerStack free; }` at `pool.c3:477`, `InnerStack` at
`:541`, declared in `mtk::pool::internal` and not public. The buckets are a
plain array walked by `bucket_for` at `:484`, and `in_pool` is `b.free.len()`,
so the old tree's two hash maps and its separate count all go. The stack uses
the same self-pointing last link as the queue, so the exact link test holds on
both.

The lesson worth keeping: LS4 asked for a comment explaining why the free list
is LIFO. The right answer was not a comment. It was a type whose name says it.

**2. `on_put` takes `extra` as an out-parameter.** `pool.c3:455`. The PL5 row
of the rulings document filed this as a language difference and marked it "no
change". It is not a language difference — Zig writes `extra: *Queue` as
readily as it returns `?Queue` — so the standing rule gives it to 3tk. Recorded
here because a row of that table was wrong, not merely unread.

**3. `init` and `finish` were passing half the environment.** The session's
first answer to the owner's question about `Io` was that an outer needing one
writes its own constructor, the way `Mbox` does. The owner rejected the
reasoning rather than the conclusion: `Mbox` and `Pool` are the toolkit's own
containers, they allocate themselves and declare no `init`, and they were never
going to call `create`. Generalizing from them describes only the two types the
question does not concern.

Starting from a user's outer instead gives a different answer. The item a pool
exists for is a connection or a stream, and in 0.16 those are behind `Io`. The
sharp end is not `init`, which a caller can work around by constructing by
hand; it is `finish`, which is called by `destroy`, by the close hook's release
loop, and by whatever a caller does with the queue `close` gives back — and
which receives an allocator and nothing else. So `create`/`destroy` were
unusable for exactly the items the next stage is about.

Two arguments the session made for deferring, both wrong, kept because they
were persuasive at the time:

- *It hands an `Io` to every outer that never uses one.* The toolkit already
  passes an allocator to outers that allocate nothing.
- *It can be added later, so waiting costs nothing.* The reverse of question
  3's deferred `finish` field. A new `OuterInfo` field touches the helper
  alone; `init`'s signature touches every outer anyone writes. That asymmetry
  argues for deciding while the tree has ten test outers and no users.

**The order was measured, not recalled.** The owner asked which way round std
puts them. In `lib/std` of 0.16: allocator first 12 times, `Io` first 3. The
three are `process.currentPathAlloc(io, allocator)` and two neighbours, where
the `Io` is the subject of the call — a different shape, not a rival
convention. Every std `self` method taking both puts the allocator first, and
`std.Build.Cache.Directory.closeAndFree(self, gpa, io)` is this exact case. So
`(alloc, io)`, and `newMbox` flips from `(io, alloc, slot)` to `(alloc, io,
slot)` so one order holds across the toolkit.

**It became a stage of its own, ENV, before POOL.** The owner asked whether it
could be done during POOL, or before, or after. Before, for a reason this tree
already paid for once: POOL's hook fixtures are the code that creates and
releases items, so doing it afterwards means writing them against the old
signature and rewriting them — three apply groups rewriting one file is what
the direction change abandoned. During POOL would work but puts two unrelated
decisions in one stage's account. ENV is Sonnet 5: every decision is made and a
compiler plus six gates say when it is wrong.

**And one narrower ruling.** No hook takes an `io`. A hook's implementation
carries what it needs in its own `ctx`, which keeps 3tk's three signatures
exactly. The owner's words: it is not ztk's problem.

**Also decided, without discussion needed.** `put` is
`error{UnknownIdentity}!void` and stays silent on an already-closed pool —
PL7 goes past 3tk and stands as a ruling, while 3tk's silence on the closed
path was a choice made with a fault available two calls earlier, so the
standing rule keeps it. The get-mode enum names are unchanged.

**One idea put to the owner and declined:** an example of an outer that owns a
mailbox or a pool. Too much.

### 2026-09-20 — MBOX, addendum

Deliberately `###`, not `##`. Check 4 of `check_next_docs.sh` counts
`## <date> — <name>` as one completed stage, and this is not a stage — it is
MBOX still closing. Written as a heading of its own it made the plan look
stale at version 4 against five stages, which is the gate working.

**The gate exception is kept.** Owner's ruling, the same day, after MBOX
closed. The banned-word check in `check_next_docs.sh` keeps skipping the one
literal std method call it cannot ask the code to rename.

Recorded because the stage made the change on its own and flagged it as the
owner's to accept or reverse. It is now a ruling, not an unreviewed edit, and
a later stage does not get to undo it by reading the first entry alone.

**Plan 004 was edited in place to say so**, rather than versioned to 005. The
versioning rule is about a *stage* changing the plan and leaving the number
behind; this is the same stage adding the owner's ruling on its own change
before handing off. Stated here rather than left for the next session to
notice.

---

## 2026-09-20 — MBOX

**What it did.** Wrote the mailbox, with its own rulings, and the tests for it.
`src/` is seven files and 2 of them are copies. The tree now has two of its
three layers.

**The files.** `src/mbox.zig`, new. `src/internal/cond_timeout.zig`, copied
byte-for-byte from the old tree. `src/queue.zig` gained one function.
`tests/layer2_mbox.zig` and `tests/layer2_threads.zig`, new.
`negative/panic/310_destroy_open_mailbox.zig` and
`negative/panic/312_destroy_while_receiving.zig`, new.

**Four questions were put to the owner before any code, and the owner answered
all four, plus one they asked back.**

- **`close` and `receiveAll` return a `Queue` by value.** The owner asked
  whether they could, which was the right question: MB9 had already ruled that
  returning a value is natural in Zig, and the out-parameter shape was 3tk's.
  Checked before answering that a `Queue` value holds no pointer into itself —
  the self-pointing last link points at the item's own node — so it survives
  being returned.
  - **This corrected `next-status.md`.** It said a queue comes out as an
    out-parameter and that calls accumulate into one queue. That sentence was
    CORE's own and was out of step with MB9. Fixed in place. Recorded here
    rather than fixed silently, which is the point of the file being append-only.
  - It also withdrew the stage's own first question, which had asked whether
    the out-parameter must be empty on entry. There is no such question once
    the value is returned.
- **`Queue.countOfId(id, stop_at)` was added to `queue.zig`**, a file CORE
  finished, so the owner approved it before it was written. MB5's limit counts
  the sender's own type among the queued outers, LS1 removed the iterator, and
  3tk iterates. The walk stays inside the queue and what a caller gets back is
  a number. It stops at the limit rather than counting the whole chain.
- **The slot-releasing `destroy` is dropped.** Question 11, open since BKP 2,
  closed here because this is where its callers landed.
- **`isIdle` is public, and the owner asked who uses it.** The honest answer
  was measured, not argued: in 3tk it has six call sites and all six are its
  own tests, while `is_closed` has real example callers. What keeps it public
  is that `destroy` aborts when its precondition is wrong, so without `isIdle`
  the only way to ask whether freeing is allowed is to try it and be right. It
  is documented against `destroy` for that reason, and not as a general query.
- **`cond_timeout.zig` — the owner asked why it should be changed.** It should
  not, and it was not. Checked rather than asserted: it imports `std` and names
  no toolkit type, so the vocabulary rename passes over it and it has nothing
  to re-point. One line was flagged and left — `condition_waitTimeout` is not
  camelCase, and MB11 was considered against it and declined, because the name
  mirrors the `Condition.waitTimeout` it stands in for and that is where it
  disappears when ziglang/zig#31278 lands.

**The counter.** `self._active += 1;` with `defer self._active -= 1;`, both
under the mutex, in every public call. `destroy` reads the pair under the mutex
and aborts unless closed and zero. It is `std.debug.panic` and not `check`,
which is what lets 310 and 312 run in all four modes: freeing a container
another context is still inside is not a contract a fast build may assume away.

**Two queues instead of an insert-after.** MB10. `oob_count`, `oob_last` and
`insertAfter` are all gone, and the order they maintained by bookkeeping is now
kept by structure — `_oob` is tried before `_regular` on the way out.

**Checks were broken deliberately, both ways, before they were trusted.**

- The out-of-band lane: reversed the two queues in `_dequeue`, and scenarios 35
  and 37 failed. Restored.
- The send limit, under-refusing: removed the count, and scenario 264 failed
  while 265 stayed green. Restored.
- The send limit, over-refusing: counted every type rather than the sender's
  own, and 264 failed again, on its other half. Restored.
- The docs gate: added a line of AI-ish prose and watched three words be
  caught, then removed it.

**312's ordering was measured, not assumed.** `close` wakes the receiver, so
the program rests on the main context reaching the mutex before the woken one
does. 200 runs in Debug, 200 aborts, none exited normally. The header says so,
and says that the program cannot pass by accident: if the abort does not happen
it exits with status 0 and the build reports the contract as not refused.

**Two things the stage had to fix rather than report.**

- **A stub that always answered true.** A helper written to say whether both
  receivers were inside the mailbox returned `true` unconditionally. It was
  deleted and scenario 266 was rewritten to repeat the wake until both
  receivers report done, which uses the scenario's own rule — *receivers that
  start waiting later are not affected* — instead of working around it. An
  atomic flag replaced a cross-context read of a plain field.
- **A gate change that silently passed everything.** The first version of the
  banned-word exception used an unescaped regular expression; grep errored on
  every word and the check reported clean. Caught by re-running it against a
  line of deliberately AI-ish prose, which it failed to catch. Fixed to a fixed
  string, and the re-run then caught three words.

**The gate's banned-word list met a std method name.** A mailbox cannot avoid
calling the std mutex's releasing method and cannot rename it, and the word is
on the list as an AI-ish verb. The script now skips that one literal method
call, the same kind of exception it already carries for `@fieldParentPtr`. The
word on its own in prose is still a hit — which it proved by catching it in
this stage's own first draft of the plan and the status file, both of which
were reworded rather than excepted.

**One word of the stage's own was renamed, not excepted:** a test helper and a
private method were both called after the banned word for emptying something.
They are `releaseAll` and `_takeAll` now.

**The gates.** All six, green. Four optimization modes 80/81 (1 skipped),
cross-compile for three targets, `zig fmt --check` clean,
`check_next_docs.sh` at exit 0, and `zig build negative` at exit 0 in all four
modes. The thread scenarios were run 15 times over for flakiness before they
were believed.

**The documents.** The plan is 004 and 003 is in `backup/`, with every live
reference re-anchored — including two in `3tk-to-ztk-005.md`, which is outside
this folder but is not the frozen old tree. `next-status.md` updated in place.
This entry appended.

**What is next.** POOL. Nothing blocks it and no question is open.

---

## 2026-09-20 — CORE

**What it did.** Wrote the model, whole: the check helper, the id and the inner,
the queue, the helper, and the module root. Plus the layer 1 tests and the
negative programs. `src/` is five files and 1 of them is a copy.

**The files.** `src/internal/check.zig` (copied byte-for-byte from the old tree,
BKP 4's product), `src/inner.zig`, `src/queue.zig`, `src/helper.zig`,
`src/matryoshka.zig`.

**Five questions were put to the owner before any code, and four were answered.**

- **The inner embeds `std.SinglyLinkedList.Node`.** IT1 and IT5 disagreed — IT1
  said the std node, IT5 wrote the field out by hand. The owner confirmed IT1,
  and the reason is measured: `@sizeOf(Inner)` is 16 either way, and the std node
  lets an outer go onto a plain `std.SinglyLinkedList`. Measured in all four
  modes before it was decided.
- **The chain type is `Queue`, not `Chain` or `List`.** The functionality decides
  it: append at the tail, pop at the head, first in first out. "Chain" names the
  linkage and stays the prose word. It also lands on 3tk's own `InnerQueue`.
- **The std list is a border, not a second home.** Per-item crossing only, through
  HP6's `takeFromSlot` and `fillSlot`. Bulk conversion stays removed — LS1 and
  LS3 took `moveFromList` and `moveToList`, and scenario 102 is retired.
- **The MUST doc comments.** The facts a caller gets wrong silently are stated on
  the declaration, not only in a document. The convention is recorded in this
  tree; `rules-050.md` gets its own version at DOCS, so CORE did not touch the
  old tree.
- Open question 6 — whether the slot-releasing form of `destroy` survives — is
  still open. Its callers are not in CORE.

**Two facts established by measuring, not by reasoning.**

- **A std list and this queue disagree on the last link.** Ours points at itself,
  std's is null, and one field cannot hold both. Measured: with three outers on a
  `std.SinglyLinkedList`, the exact link test reads true, true, **false** — the
  last one. So an outer on a std list is out of the toolkit's hands while it is
  there, and the doc comment on `Inner` says so.
- **`std` does not clear the link it hands back.** `SinglyLinkedList.popFirst`
  returns a node whose `next` still points into the list it just left. The doubly
  linked one at least clears `prev`; the singly linked one clears nothing. So
  `fillSlot` refuses an item arriving with a link still set, and names std as the
  likely source. Every call of ours hands items back with the link clear.

**`no_create_destroy` is gone, and nothing replaces it.** The old tree returned
two different struct bodies from the helper, 180 duplicated lines, so that a
container could opt out of `create` and `destroy`. It is not needed: Zig analyses
a generic struct's declarations lazily, so a type that never calls `create` never
reaches the requirement for `init`. `FakeMbox` in the tests is the evidence — no
hooks, and it still has an id and every crossing. Asking it for `create` does not
compile, which is scenarios 308 and 309.

**The negative mechanism, which SPEC left open and the owner handed back.** Two
halves, because the two kinds of refusal cannot share one:

- `negative/compile/` — four programs that must fail to compile, checked against
  the message by the build system. Scenarios 306 to 309.
- `negative/panic/` — six programs that must die. The build runs each and checks
  it aborted. Scenarios 300 to 305.
- Both under a new build step, `zig build negative`. A `check`-based case is
  built in Debug and ReleaseSafe only, because the check is compiled out of the
  other two and the program is then correct to survive. Scenario 301 is a
  `@panic`, not a `check`, so it is built and run in all four — and it passes in
  all four, which is the case the old tree had undefined behaviour in.

**Scenario 315, measured.** The check message is absent from the ReleaseFast and
ReleaseSmall binaries: a stripped probe is 4840 bytes there against 288824 in
ReleaseSafe, and the message string is not in it. The first measurement said the
opposite, and the first measurement was wrong — `-O` after `-M` on the
`build-exe` command line does not reach the module, so all four probes were
Debug. It was re-done through a build script. A measurement that is easy to take
wrongly is worth saying twice.

**Post-stage cleanup.** Done before the gates were re-run. What it removed: the
helper's duplicated second struct body, which never got written; the old tree's
`reset`, `iterator`, `popLast`, `remove`, `first`, `last`, `prepend`,
`insertBefore`, `insertAfter`, `prependFromSlot`, `moveFromList` and
`moveToList`, none of which were written either, per LS1. What it kept: nothing
was extracted to a shared source, because the insert guard is the only repeated
shape and it is four lines in one file.

**The gates.** All five green, and the sixth is new. 43 tests, 42 passing and 1
skipped in the safe modes — scenario 251 runs only where the check is compiled
out. Four optimization modes, three cross targets, `zig fmt --check` clean,
`check_next_docs.sh` at exit 0, and `zig build negative` passing in all four
modes.

**What CORE did not do.** It did not touch the old tree. It did not reopen a
ruling. It did not start MBOX.

---

## 2026-09-20 — SPEC

**What it did.** Wrote the test scenarios for this model. No code.

- `ztk/design/task1-tests-001.md` — 136 scenarios: the core, the mailbox, the
  pool, the negative set, the check helper, the version.
- `ztk/design/task2-tests-001.md` — 25 scenarios: Layer 4 and cross-layer.

**Where they came from.** `design/task1-tests-008.md` and
`design/task2-tests-004.md` in the old tree, read against the rulings. Also
3tk's `test/` and `negative/` trees, which were read for what the old ztk list
has no scenario for.

**Tracing.** A surviving scenario keeps its old number, including where the
model changed under it — so 9 is still the Slot scenario and 49 is still the
linked-send refusal. New scenarios start at 200. Nothing is renumbered and no
number is reused. Each scenario names its origin: an old number, a ruling id, or
the 3tk test whose evidence it is.

**Coverage, checked rather than claimed.** Every ruling id that reaches Layers 1
to 4 appears in at least one scenario: IT1, IT3, IT4, IT5, LS1, LS2, LS4, HP1,
HP3, HP6, TK2, TK3, MB2 to MB5, MB12, PL1 to PL8, Z2, Z5. The std rows — MB6 to
MB9, PL10, TK1 — are carried by the scenarios that already tested them, because
those rows were ruled unchanged.

**Thirteen old scenarios retired**, each with the ruling that removed it named in
a table: the two-level cast chain and the blind link test (IT1), the repair call
and six list operations (LS1), the std-list crossings (LS3), the batch put (PL6),
and the recycling get hook (PL2). A scenario that vanishes without a reason is
how a behaviour is lost, so none does.

**Two old scenarios changed owner rather than retiring.** Out-of-band ordering is
kept by two queues now instead of an insert-after, and link repair is the chain's
job rather than the caller's. Both keep their numbers, because the promise to the
caller did not change.

**The negative set is the biggest growth: three scenarios became seventeen.**
3tk keeps 29 such programs in `negative/`, each expected to abort or to fail to
compile, and the old ztk list had scenarios 15 to 17. What they cover now:
unstamped outers refused at every crossing, the wrong-type panic, a full Slot, a
linked outer, the four compile-time refusals, and destroy refused on an open or
busy container.

**And the question they raise, which SPEC did not answer and should not have.**
Zig has no standard way to assert a panic inside a test, and a compile-error case
needs a build step of its own. The old tree carries this as Open Item 11,
unresolved. The list says plainly that the mechanism is undecided and that the
stage writing them asks the owner first. It also records what they cost: `check`
is compiled out where runtime safety is off, so most of these are Debug and
ReleaseSafe scenarios only — except the wrong-type panic, which must hold in all
four modes, because that is the case where the old tree had undefined behaviour.

**Five design questions were answered before this stage, and recorded in the
staging plan.** There is no handle type — 3tk has none either, checked in its
sources. The type is `OuterId` and the struct is `OuterInfo`, not `Identity`,
because "identity" is already the role word in this toolkit and already split
into class and instance. `Info` rather than `Desc` or `Meta` from Zig's own
usage: 19 type declarations in std end in `Info`, one in `Desc`, none in `Meta`.
And none of `finish`, `magic` or `size` is a field, so `OuterInfo` has two.

**Post-stage cleanup.** One banned word caught by the gate in a section heading
and reworded. The scenario lists were then re-read end to end for scenarios that
name a call the rulings removed; none remained.

**Verification.** Gate at exit 0. Build unchanged and re-run anyway: four modes
1/1, `zig fmt --check` clean.

**What is not done.** No code. The negative mechanism is unanswered. Examples are
not in scope until the layers are tested.

**Model.** Opus 5. It decided what is tested, and everything downstream is
measured against it.

**Next.** CORE, Opus 5, after a clear. It has one question to put to the owner
before its negative tests, and nothing blocking its code.

### Records repaired, within SPEC

Not a stage of its own — this is SPEC, continued after the owner asked why the
staging plan was still at 001.

**What happened.** SPEC changed the staging plan four times and edited 001 in
place each time, against the rule that a document is never overwritten. The owner
noticed, and the question was the right one: why had the version number never
moved. Nothing else had noticed, because nothing was watching that number.

**What was lost.** The text SETUP wrote is gone. There is no git here and the
edits were in place, so `backup/next-staging-plan-001.md` holds the post-SPEC
text, not the SETUP text. The copy in `backup/` is therefore a near-duplicate of
002 and is labelled as such in 002's header. Writing it without saying so would
have implied a history that was never kept. The old tree has the same failure on
record once, where plan -069 was deleted against the rule and was unrecoverable.

**What was repaired.**

- `next-staging-plan-002.md` written, carrying the current content, its header
  naming what SPEC changed and stating the gap plainly.
- 001 moved to `backup/` with a plain `mv`.
- References re-anchored in `next-status.md`, the CORE prompt inside 002 itself,
  `3tk-to-ztk-005.md`, `design/STATUS.md` and the old tree's plan -080.
  `next-log.md` was deliberately not re-anchored: the SETUP entry names 001
  because 001 is what SETUP created.
- `next-status.md` now states the three handling rules separately — in place,
  append-only, versioned — instead of one sentence that covered all three and was
  read as covering none.

**The gate gained a fourth check.** The plan's version must be at least the
number of stages the log records. Greater is fine, since a stage may write more
than one version; less means a stage changed the plan without versioning it.
Negative-tested both ways before being trusted, per the rule that a check never
seen to fail has not been tested: with the tree as it stands it reports version 2
against 2 stages and passes, and with 002 renamed back to 001 it reports the
stale plan and fails.

**What the check cannot do, said plainly.** It sees the version number, not the
edit. A stage that edits the current plan in place and leaves the number alone
still passes, until the next stage closes and the count moves ahead. It narrows
the window; it does not close it. The rule still has to be followed.

**Also fixed while here.** `next-log.md` is now out of the dead-reference check,
for the reason `check_design.sh` leaves `STATUS-LOG.md` out of its own: a past
entry legitimately names a document that has since moved. It would have failed on
the SETUP entry's mention of 001 the moment 001 went to `backup/`.

**Verification.** Gate at exit 0, all four checks. No code changed.

**Model.** Opus 5, continuing the SPEC session.

---

## 2026-09-20 — SETUP

**What it did.** Created the tree for the rewritten toolkit and verified it  
builds empty.

**Why the tree exists.** The backport's nine apply groups were dropped, the  
owner's call, the same day. Three of them each rewrote `src/polynode.zig` and  
then re-read the same call sites — measured at ~70 sites for the identity change  
alone, and ~300 across the three. Each group also left the toolkit in a state  
nobody wanted to keep: after the identity group it would have had descriptor  
identity on a doubly-linked std node with a blind link test and a `create` that  
could not run user code, which is a fourth design rather than a step toward the  
third. And `build.zig:53` has the tests module import the examples module, so the  
implementation half of a stage could not be green on its own — the split the  
rules require was impossible. The owner named the cause plainly: splitting was  
the wrong decision.

**The arrangement.** The owner chose the same shape the C3 work already uses: a  
whole project root kept under `design/secondary/lang/`, edited in place, copied  
out when it is ready. Position: `design/secondary/lang/port/3tk-to-ztk/next/`,  
under the backport that produced it. Its own status, plan and log, so  
`design/STATUS.md` keeps describing the old tree until the switch.

**What was created.**

- `next/ztk/build.zig` — module, static library, test step, docs step. No
  examples module, no stories module, no core-surface step. The examples module  
  is absent deliberately: its presence in the old build is what made the tests  
  depend on the examples.
- `next/ztk/build.zig.zon` — the same package name and fingerprint as the old
  tree's. The two are separate builds and never share a dependency graph.
- `next/ztk/src/matryoshka.zig` — a module header and no toolkit code.
- `next/ztk/tests/matryoshka_tests.zig` — one test, asserting the module
  imports.
- `next/ztk/kitchen/build_and_test_debug.sh`, `build_and_test_all.sh`,
  `build_cross_debug.sh` — copies of the old tree's. They root themselves from  
  their own location, so the copies needed no edit at all, and nothing in them  
  reaches above `next/ztk/`.
- `next/ztk/kitchen/tools/check_next_docs.sh` — new. Three checks: dead
  cross-references in both syntaxes, retired vocabulary, and the banned-word  
  list of `rules-050.md` Part 5.
- `next/next-status.md`, `next/next-staging-plan-001.md`, `next/next-log.md`,
  `next/backup/`.

**Why a new gate was needed.** `kitchen/tools/check_design.sh` line 103 prunes  
`design/secondary/lang` outright, and line 115 excludes `secondary/` from the  
word checks. That is correct for the frozen C3 material and wrong for a tree  
being written: every file here would have been invisible to it. Checked, not  
assumed. The new gate also does one thing the old one cannot — the old gate  
defends the old words, and this one refuses them. A line that says what a retired  
word became carries the marker `retired-ok`, the same escape `check_design.sh`  
gives a changelog row.

**Two facts checked rather than assumed.**

- `.gitignore` already covers a nested build: `**/.zig-cache/` and
  `**/.zig-out/`.
- No kitchen script runs `zig fmt` across the whole repo, so neither tree's
  formatting gate reaches into the other.

**One asymmetry against the C3 case, recorded because it is a hazard.** For C3  
the destination is a different repository, so a mistaken path cannot damage the  
source. Here the destination is this repository. So the new tree's scripts root  
themselves and never reach above `next/ztk/`, and the old tree is frozen rather  
than merged.

**Verification.** All from `next/ztk/`, output to `zig-out/*.log`, logs read.

- `build_and_test_debug.sh` — exit 0. Build 3/3, test 1/1.
- `build_and_test_all.sh` — exit 0. Four optimization modes, 1/1 each.
- `build_cross_debug.sh` — exit 0. x86_64-macos, aarch64-macos, x86_64-windows.
- `zig fmt --check src tests build.zig` — exit 0.
- `check_next_docs.sh` — exit 0.

**Post-stage cleanup.** Two defects found in the new gate by re-reading it, both  
fixed before the stage closed. The dead-reference check reported through a pipe,  
so its hits ran in a subshell and the counter did not see them — the script would  
have exited 0 with dead links on the page. It now reads from a process  
substitution. And the retired-vocabulary check had no way for a document to say  
what a word became, which would have made the status file unable to state its own  
vocabulary rule; that is the `retired-ok` marker. The document gate was then  
run against the three documents it governs.

**Banned-word scan.** Run as part of `check_next_docs.sh` over every `.md` and  
`.zig` in the tree, not only changed files.

**What is not done, and is not hidden.** The tree contains no toolkit code. The  
test scenarios are not written. The old tree is untouched and still the only  
working toolkit.

**Model.** Opus 5. It was a deciding stage: the arrangement, the gate and the  
stage menu all bind what comes later.

**Next.** SPEC or CORE, the owner's choice. Opus 5 for either. Clear first —  
this session carried the whole backport survey and the old tree's identity code,  
and neither is needed again.
