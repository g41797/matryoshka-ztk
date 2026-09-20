# next — STATUS

The current state of the rewritten toolkit. This tree, not the old one.

## Which tree am I in

Two trees live in this repo, and a session works in exactly one.

- The **old tree** is the repo root: `src/`, `tests/`, `examples/`, `design/`.
  Its state is `design/STATUS.md`. It is frozen — see **The old tree is  
  frozen** below.
- The **new tree** is `design/secondary/lang/port/3tk-to-ztk/next/`. Its state
  is this file. Its code is the `ztk/` folder next to it.

A session that was told to work on the rewrite reads this file and the staging  
plan, and nothing at the repo root except `design/rules-050.md`.

## Start here — every session

1. Read this file in full.
2. Read [next-staging-plan-018.md](next-staging-plan-018.md) for the stage the
   owner names. Not before they name it.
3. Read Part 0 of `../../../../rules-050.md`. It governs both trees.
4. The rulings this tree implements are in
   [../3tk-to-ztk-007.md](../3tk-to-ztk-007.md), section **BKP 2 — the
   rulings**. They are not reopened by writing code.

**No stage starts because a document says it is next.** The owner names it.

## Why this tree exists

The backport ruled a new model: identity is a pointer to a per-type descriptor,  
the intrusive node is singly linked with an exact link test, `create` runs the  
item's own `init`, and the words are Outer and Inner.

Those rulings were first arranged as nine apply groups against the old tree.  
That arrangement was dropped on 2026-09-20, the owner's call. The reasons, in  
full, are in [../3tk-to-ztk-007.md](../3tk-to-ztk-007.md) under **The direction  
change**. In short:

- Three of the groups each rewrote the same file and then re-read the same
  ~300 call sites. The same work, three times.
- Each group left the toolkit in a state nobody wants to keep, and every gate
  run on it verified a design that will never ship.
- The tests module imports the examples module, so a stage could not split into
  implementation and examples the way the rules require.

So the model is written once, as a whole, in a tree of its own. Two of the nine  
groups — the rename of the documents and the rename of the code — stop existing,  
because new code carries the new words from its first line.

## The old tree is frozen

No edits to `src/`, `tests/`, `examples/`, `stories/` or `kitchen/` at the repo  
root while this tree is written. A copy you keep editing rots; a copy you never  
touch is a reference.

- Reading it is encouraged. It is the source of the behaviour being kept.
- Copying a file in is the normal way to start one. `internal/cond_timeout.zig`,
  the `std.Io` surface, the futures and the `Result` types come across as they  
  are — the backport ruled them unchanged.
- `design/` at the repo root keeps describing the old tree until this one
  replaces it. It is not kept true against two models at once.
- The old tree is deleted in one step when this one overtakes it. Owner's
  action, not a session's.

## Where the files are

| what | where |
|---|---|
| this file | `next/next-status.md` |
| the stage menu | `next/next-staging-plan-018.md` |
| the narrative | `next/next-log.md` |
| superseded versions of the three above | `next/backup/` |
| the code | `next/ztk/` — `build.zig`, `src/`, `tests/`, `negative/`, `kitchen/` |
| the test scenarios | `next/ztk/design/` — task1 for Layers 1-3, task2 for Layer 4 |
| the rulings being implemented | `next/../3tk-to-ztk-007.md` |
| the old tree's rules, which govern both | `design/rules-050.md` |

The `ztk/` folder is a whole Zig project root. It is what gets copied up to the  
repo root when it overtakes the old tree, so it holds no path that points  
outside itself.

## The gates

Run from `next/ztk/`. Redirect to a log file and read the log, not the shell.

1. `bash kitchen/build_and_test_debug.sh` — build plus the Debug test.
2. `bash kitchen/build_and_test_all.sh` — all four optimization modes.
3. `bash kitchen/build_cross_debug.sh` — x86_64-macos, aarch64-macos,
   x86_64-windows.
4. `bash kitchen/tools/check_next_docs.sh` — this tree's documents and code.
5. `zig fmt --check src tests build.zig negative`.
6. `zig build negative`, in each of the four optimization modes — what the
   toolkit refuses.

A stage is complete only when all six pass.

Gate 6 grew again at POOL: sixteen programs now, and 310, 311, 312 and 313
run in all four modes because `Mbox.destroy` aborts with `std.debug.panic` and not with
`check`. The gate's banned-word list met the std mutex's releasing
method for the first time here, and the exception is the owner's ruling of
2026-09-20 rather than a stage's own convenience — the banned word is the AI-ish verb, and the
std method name cannot be renamed, so the script skips that literal method
call the way it already excepts `@fieldParentPtr`. The word on its own in
prose is still a hit, which is why this paragraph does not spell it.

Gate 6 arrived with CORE. A Zig test cannot assert that a panic happened, and a
compile error cannot be reached from inside a test at all, so those scenarios
are programs under `negative/` rather than tests. `negative/README.md` says how
they are built and why a `check`-based case is left out of the two fast modes.

`kitchen/tools/check_next_docs.sh` exists because the old tree's  
`check_design.sh` prunes `design/secondary/lang` outright, so it cannot see  
anything here. The new gate checks dead cross-references, the banned-word list  
of `rules-050.md` Part 5, and one thing the old gate cannot: that the retired  
words do not reappear. A line that says what a retired word became carries the  
marker `retired-ok`.

The first three scripts are byte-for-byte copies of the old tree's. They root  
themselves from their own location, so nothing in them needed changing, and  
nothing in them reaches above `next/ztk/`.

## Rules

`design/rules-050.md` governs both trees. What is different here:

- No git, in either tree. Plain `git status` is the one exception.
- Show intent before code. The owner approves before code is written.
- **The three documents are handled three different ways. This is the rule most
  easily broken, and it was broken once already — see the log for 2026-09-20.**
  - `next-status.md` — updated **in place**. It is the stable entry point, the
    way `design/STATUS.md` is for the old tree.
  - `next-log.md` — **appended to**, newest at top. Never edited. A past entry
    names the document version current when it was written, and that name is the
    fact it records.
  - `next-staging-plan-NNN.md` — **versioned**. A stage that changes it writes
    the next number, moves the old one to `next/backup/` with a plain `mv`, and
    re-anchors every live reference in the same stage.
  - `check_next_docs.sh` check 4 fails when the plan's version falls behind the
    number of stages in the log. It cannot see an edit that keeps the number, so
    the rule still has to be followed, not merely passed.
- Every other document: never overwrite. New version with an incremented suffix,
  the superseded one to `next/backup/`, references re-anchored in the same stage.
- `next/backup/` is transient. The owner empties it. Never a source of truth.
- Examples came after the layers were tested, and the build's examples module
  entered at EXAMPLES for that reason.
- Stories are obsolete. This tree has none and gets none.
- **End every stage by saying, in the message itself: the model, whether to
  clear or compact, and the exact prompt to continue with.** Not a pointer to
  where the prompt is kept. After a clear there is no one left to follow the
  pointer, and the owner pays a round trip to ask for what the rule already
  required. 3tk rule 9 — *with the exact prompt to continue with* — and rule 10,
  and `design/STATUS.md:92`.
  - **Short means three lines: this file, the stage, the model.** Nothing else.
    The owner keeps the prompt in their own document and needs something to
    paste, not a briefing.
  - **It must not repeat what this file already says.** **Start here — every
    session** above is the reading list, and the prompt's job is to reach it. A
    prompt that carries its own copy of the reading list goes stale the way any
    copy does — the long one in the staging plan named the wrong plan version
    within a day of being written.
  - Say the model at the start of a stage too, with the reason, and say when a
    stage wants a weaker one. Taking the strongest model silently is the failure
    rule 10 exists for.
- Ask the owner questions as numbered plain text. No picker tool.
- Say "save", not the git word. Say "write a new version", not "cut".
- The embedded node is the inner. The embedding struct is the outer. Never the
  banned third word. <!-- retired-ok -->

## Participants

- Owner (g41797-human): design, decision-making
- Claude: implementation, tests

## Current state

**SURFACE is done, 2026-09-20.** The module root is short, the way the old tree's
is, and every file has a page of its own.

- The root is five `pub` namespaces — `inner`, `queue`, `helper`, `mbox`,
  `pool` — plus `VERSION`, `Mbox` and `Pool` flat. Nothing that lives in a
  namespace is re-exported flat, so a caller writes `inner.Slot`, `mbox.new`,
  `pool.getWaitResult`, and the two entries called `new` are gone by structure.
- **The five `//!` module headers are published for the first time.** All five of
  the root's file imports were private, so autodoc could not reach them, and the
  23 flat names sat on one page with no per-module page at all.
- **The id is opaque: `OuterId = ?*const anyopaque`, and null is unstamped.**
  Nothing about identity is on the site: `OuterInfo` and the one function that
  reads it, `infoOf`, are in `src/internal/info.zig`, named by no published
  declaration. `isStamped` and `outerAddr` are gone as names — the first is
  `item.id != null` at its two call sites, the second was absorbed by
  `AnyOuter.moveFromSlot`.
- **`UNSTAMPED` does not exist any more, and that is the point.** It was a real
  `OuterInfo` in read-only memory, named `<unstamped>`, existing only because a
  `*const T` cannot be 0. An optional pointer can be, so the sentinel is gone,
  the zero value of an `Inner` is unstamped, and zeroed memory —
  `std.mem.zeroes`, a `@splat` of `.{}` — is a valid unstamped outer. `@sizeOf`
  is unchanged: an optional pointer is pointer-sized, so `Inner` is still 16
  bytes.
- **A missed check now faults instead of lying.** Where a build compiles the
  checks out, a null id faults at `infoOf`; before, the sentinel's zero offset
  made the crossing return the inner's own address — a plausible pointer that
  corrupts later. In the safe modes nothing changed: the border check fires
  first, with its own message.
- **The cost was two scenarios.** **202 retired** — the crossing back from a bare
  `*Inner` *was* `outerAddr`, and `AnyOuter.moveFromSlot` computes the same
  address with scenario 321 checking it. **204 retired** — it measured the
  sentinel's zero offset and the near miss, neither of which exists now. 201 and
  203 keep their claims, read the way a caller reads them.
- **Every function is on the page of the type it acts on.** The four border
  functions were on `helper`'s page while `Slot`, `Inner` and `AnyOuter` were on
  `inner`'s. `slotToAny` and `anyToSlot` are now `AnyOuter.moveFromSlot` and
  `AnyOuter.moveToSlot`; `takeFromSlot` and `fillSlot` sit beside `Slot` in
  `inner.zig`; `helper.zig` is `OuterHelper` alone. `mbox` and `pool` already had
  this shape — a type, its `new`, its result reader — which is what made the
  asymmetry visible. `queue` stays a one-type page on purpose. `outerAddr` fell
  out of use in the move and is gone, and `internal/stamp.zig` went with the
  opaque id: `isStamped` is `item.id != null`, spelled at its two call sites.
- **Autodoc groups each page into Types, Functions and Values by itself.** The
  sources decide which page a name is on, and nothing more.
- **Moving a file under `src/internal/` is not enough by itself, and the preview
  proved it.** Autodoc has no hide attribute; it renders what a `pub` chain from
  the root reaches, and **a type named by a published declaration is reached
  through that declaration's own type**. `OuterInfo` sat in `internal/` and still
  appeared, because `pub const OuterId = *const OuterInfo` named it. So a name is
  off the site only when no published declaration names it — which is what the
  opaque id achieves. A curated second docs root was designed and rejected; the
  reasons, and the one constraint to carry forward, are in
  `../3tk-to-ztk-007.md`.
- **The second test root is gone**, with the five test blocks in
  `internal/stack.zig` and the `imod` entries in `build.zig`. Every property they asserted is
  asserted through the pool, which is `InnerStack`'s only caller; scenario 289
  was implemented twice and is asked for once. `src/` is nine toolkit files and
  `sources.tar` no longer ships a test root.
- Roughly 720 call sites rewritten across three rulings. 202 tests became
  **195: 194 pass and 1 skips**, in all four modes. Six gates green.

**LANDING is done, 2026-09-20.** The logo in `ztk/kitchen/docs/index.md` is no longer a
link, and the badge opens `apidocs/` in the same tab. Nothing else changed. Gate 4
is clean; the others were not re-run, since `src/`, `tests/`, `build.zig` and
`negative/` did not change.

**SITE is done, 2026-09-20.** The site material is in `ztk/kitchen/`: `mkdocs.yml`
with a navigation of the landing page alone, `docs/` (the landing page, assets,
stylesheets, favicons), `hooks/count_lines.py`, and ten site tools including
`count_readme_loc.sh`, whose default target is now the `ztk/` README. Every
copied script was read and stays inside `ztk/`. `src/` and the frozen root were
not touched. The site was not built; that is PREVIEW. Gate 4 is clean.

**BRIDGE is done, 2026-09-20.** One example for the README, in
`examples/bridge/`: a handler waits on an `Io.Queue(Msg)` (request from the io
side, reply as `AnyOuter`, stop), takes greetings from a pool, sends them to a
shared mailbox, and workers answer back through the queue. "Hello,
Matryoshka!" goes in, "Hello, Io" comes out. The build has seven `examples-*`
steps. 202 tests: 201 pass and 1 skips. `src/` was not changed. Six gates
green. `ztk/README.md` holds the bridge context; the README proper is DOCS.

**FUTURES is done, 2026-09-20.** `Pool.Result`, `getWaitResult` and
`Pool.getWaitFuture` are written, with six tests and the ten waiting examples.
An unknown identity is `error.UnknownIdentity` in every build now: the safe-build
checks in `get`, `getWait`, `put` and `countOf` are gone. 201 tests: 200 pass
and 1 skips. Six gates green.

**ANY is done, 2026-09-20.** `AnyOuter` lives in `inner.zig`. `slotToAny` and
`anyToSlot` are free functions in `helper.zig`, type-blind and returning nothing;
`fromAny` is the per-type typed read. Six tests, three negative programs
(`negative/` now holds nineteen). Six gates green.

**EXAMPLES is done, 2026-09-20.** The examples module is in the build, with 69
files and six `examples-*` steps. 179 tests: 177 pass and 2 skip in the safe
modes, 178 and 1 in the fast two. Six gates green. `src/` was not changed.
Dropped, deferred and new examples are listed in the plan under **EXAMPLES —
done**.

**POOL is done, 2026-09-20.** The pool is written, with its own rulings, and
the tree has all three layers.

- `src/` is nine files: the seven from MBOX, plus `pool.zig` and
  `internal/stack.zig`.
- The store is an `InnerStack` per identity, and the buckets are a plain array
  scanned linearly. `in_pool` is the stack's own `len`, so there is no second
  count to keep true. Reuse is last in, first out because a stack is.
- The queue keeps its place at the border: `close` empties every bucket into
  one and the close hook takes it by value.
- `on_get` is reached only when nothing is stored, so its Slot is always
  empty. `on_put` takes `extra` as an out-parameter. No hook takes an `io`.
- A close while the put hook runs loses nothing: the outer that call took and
  everything the hook added go to `on_close`, which is why that hook may be
  called more than once and twice at the same time. `_active` is held across
  that second call, so a `destroy` racing it aborts.
- `get`, `getWait`, `put` and `countOf` all refuse an unknown identity with
  `error.UnknownIdentity`, in every build. A closed pool stays silent on
  `put`, with the caller's Slot untouched.
- **`Mbox` and `Pool` declare `init` and `finish`, and both are private.**
  `@hasDecl` cannot see a private declaration from `helper.zig`, so
  `OuterHelper(Mbox).create` in a user's file still does not compile — the
  declaration is there to be read, and the refusal is unchanged. Both halves
  were measured before the edit.
- `src/internal_tests.zig` is a second test root, for the tests inside `src/`.
  An internal type is not reachable from the module root, and a file two
  imports deep from a test root contributes no test blocks. `zig build test`
  runs both roots; the kitchen scripts did not change.
- 115 tests. In the safe modes 113 pass and 2 skip; in the fast two, 114 pass
  and 1 skips. `negative/` holds sixteen programs. Six gates green.

**ENV is done, 2026-09-20.** `init` and `finish` take `(alloc, io)`, and so do
`create` and `destroy`. `newMbox` is `newMbox(alloc, io, slot)`, so the toolkit
carries one order, std's.

- `helper.zig` — the two calls, the two `@compileError` messages, and a note on
  `create`: why ztk passes both where 3tk passes an allocator alone, and the
  MUST that an outer keeping the `Io` does not outlive its runtime.
- `mbox.zig` — argument order of `new`. `build.zig` — the expected messages of
  negative 308 and 309.
- Tests: `outers.zig` hooks and helpers take an `io`. Layer 1 uses
  `std.testing.io`; layer 2 uses the fixture's own. Negative programs that run
  make a `Threaded`; the two that must not compile pass `undefined`.
- Still 81 tests, 80 pass and 1 skips. Six gates green.

**MBOX is done, 2026-09-20.** The mailbox is written, with its own rulings,
and the tree has two of its three layers.

- `src/` is seven files: the five from CORE, plus `mbox.zig` and
  `internal/cond_timeout.zig` (copied byte-for-byte from the old tree — it
  imports `std` and names no toolkit type).
- `close()` and `receiveAll()` hand a `Queue` back by value. Two queues inside,
  out-of-band first, so `oob_count`, `oob_last` and `insertAfter` are gone and
  the order MB10 promised is kept by structure.
- Every public call counts itself in `_active`. `destroy` is a method, uses the
  stored allocator, and aborts in **every** build unless closed and quiet. That
  is `std.debug.panic`, not `check`: freeing a container another context is
  inside is not a contract a fast build may assume away.
- `isClosed`, `isIdle` and `len` are public. `isIdle` is the readable form of
  `destroy`'s precondition, and takes the mutex — never called from inside a
  call on the same mailbox.
- `sendLimited` is the second send form. `Queue.countOfId` feeds it: a walk
  that stays inside the queue and stops at the limit. Not an iterator.
- The slot-releasing `destroy` is dropped. Question 11 is closed, so **no
  question is open**.
- 81 tests. 80 pass and 1 skips in the safe modes. `negative/` holds twelve
  programs; 310 and 312 run in all four modes.

**CORE is done, 2026-09-20.** The model is written, whole, and the tree has
toolkit code for the first time.

- `src/` is five files: `internal/check.zig` (copied from the old tree),
  `inner.zig`, `queue.zig`, `helper.zig`, `matryoshka.zig`.
- An outer's id is `OuterId`, the address of its one `OuterInfo`, which holds
  the type's name and the offset of its inner field. `OuterInfo` is `const`, so
  it lives in read-only memory.
- The inner embeds `std.SinglyLinkedList.Node`, owner's ruling. `@sizeOf(Inner)`
  is 16 either way, measured in all four modes, and an outer may go onto a plain
  `std.SinglyLinkedList`.
- The chain type is `Queue` — append at the tail, pop at the head. The tail
  points at itself, so the link test is exact and sees a chain of one. Length is
  a stored count.
- The helper finds the inner field by type. Its name is free; zero or two is a
  compile error naming the type. `create` runs the outer's own `init` and frees
  the outer again if it fails; `destroy` runs `finish` first.
- 43 tests. 42 pass and 1 skips in the safe modes — scenario 251 runs only where
  the check is compiled out.
- `negative/` holds ten programs: four that must not compile, six that must die.

**The std list is a border, not a second home.** Per-item crossing only, through
`takeFromSlot` and `fillSlot`. Two facts behind that, both measured:

- Our chain's last link points at itself and std's is null. One field cannot
  hold both, so an outer on a std list is out of the toolkit's hands while it is
  there.
- `std.SinglyLinkedList.popFirst` hands back a node still pointing into the list
  it left. Every call of ours hands items back with the link clear, and
  `fillSlot` refuses one that is not.

**No bulk input.** Every item enters through a Slot, one at a time. A queue only
ever comes *out* — from `Mbox.close`, `Mbox.receiveAll` and a pool's close hook.

**It comes out by value, not as an out-parameter.** MB9 ruled that returning a
value is natural in Zig; the out-parameter is 3tk's shape. A `Queue` value holds
no pointer into itself, so it survives being returned. Corrected here by MBOX —
this file said the opposite until 2026-09-20, and the sentence was CORE's own.

**A queue value is moved, never copied.** Two copies over one chain are two
owners of every outer on it.

**SPEC is done, 2026-09-20.** The test scenarios for this model are written:
`ztk/design/task1-tests-003.md`, 136 scenarios for the core, the mailbox and the
pool, and `ztk/design/task2-tests-002.md`, 25 for Layer 4 and cross-layer.

- Old numbers are kept, so a scenario traces back. New ones start at 200.
- Every ruling has at least one scenario. Thirteen old scenarios retired, each
  with the ruling that removed it named in a table.
- The negative set grew from three scenarios to seventeen, from 3tk's `negative/`
  tree of 29 programs. **Their mechanism is undecided** — see Next.
- No code. The five gates are green, unchanged.

**SETUP is done, 2026-09-20.** The tree exists and builds empty.

- `next/ztk/` is a Zig project root: `build.zig`, `build.zig.zon`,
  `src/matryoshka.zig`, `tests/matryoshka_tests.zig`, `kitchen/`.
- `src/matryoshka.zig` holds a module header and no toolkit code. One test
  asserts the module imports.
- All four optimization modes pass, 1/1. Cross-compile passes for the three
  targets. `zig fmt --check` is clean. `check_next_docs.sh` exits 0.
- The build has no examples module, no stories module and no core-surface step.
  It knows about `src/` and `tests/` only.

## Next

**README is next.** It is the most important stage in the plan, and SURFACE
cleared its way: the per-module pages it assumes now exist. The charter is in
[next-staging-plan-018.md](next-staging-plan-018.md), and the work is in
`ztk/design/readme-creation-001.md`. Opus 5.

**No question is open.** The one SURFACE stored was ruled the same day: the three
internals left the site. The ruling and what it cost are in
`../3tk-to-ztk-007.md` under **The module surface**, ruling 5.

**PREVIEW was where SURFACE came from.** The first local build showed the flat
root, and the stage that fixed it is done. The site has not been rebuilt and
looked at since; that is the next thing PREVIEW does when the owner names it.

**DOCS no longer exists.** The owner ruled on documentation on 2026-09-20,
before anything was written, and it became five stages: SITE, LANDING, PREVIEW,
README, COMMENTS. **The api reference book is dropped** — the per-module part of
each generated page is the reference now. The reasons are in
[../3tk-to-ztk-007.md](../3tk-to-ztk-007.md) under **The documentation
direction**.

What the project publishes, and nothing else: the **README**, the **landing
page**, and the **Zig documentation generated from the sources**. The old mkdocs
pages are frozen and unreachable — the landing page's picture stops being a link,
and that picture was the only way in.

**Each documentation stage with decisions has its own document**, and the plan
carries only a description and a link: `ztk/design/readme-creation-001.md` and
`ztk/design/comments-creation-001.md`. The README document holds the measured
inventory of `src/` and the 27-row list of 3tk facts needing a ztk answer; its
module mapping table is what the COMMENTS stage reads.

**The README is the most important stage here.** It is the entry to the project,
and with the picture un-linked there is almost nothing behind it. It starts as
the 3tk README with only the facts that are wrong for Zig rewritten. The owner or
another model drafts; this side supplies material before a draft and checks and
cuts after one.

**Reported, not actioned.** References in the frozen old tree that name
superseded versions. The owner repoints them, or leaves them until PROMOTE.

- Four name version 002 of the stage menu: `design/STATUS.md` at 12 and 345, the
  old tree's plan at 411 and 441.
- Six name the superseded subject document, now at
  `design/secondary/lang/port/3tk-to-ztk/backup/3tk-to-ztk-005.md`:
  `design/context.md` at 25, `design/STATUS.md` at 19 and 210, and
  `design/matryoshka-ztk-implementation-plan-080.md` at 7, 403 and 443.

## History

The narrative, by date, is [next-log.md](next-log.md). This file carries none.
