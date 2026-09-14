# 3tk — staging plan 038

Written 2026-09-14.

**Provenance.** Follows `037`, which is spent: `3TK-77` closed on 2026-09-14.
Earlier plans are named, not linked — `backup/` is transient.
**Only `3TK-50` remains from any earlier plan, and it waits on the owner.**

State is in [3tk-status.md](3tk-status.md). Narrative is in
[3tk-log.md](3tk-log.md). **The rules are
[matryoshka-3tk/design/3tk-rules-007.md](https://github.com/g41797/matryoshka-3tk/blob/main/design/3tk-rules-007.md)**;
this plan cites them and does not re-argue them.

---

## Why this plan exists

**`matryoshka-3tk/design/3tk-limited-send-001.md` proposes an optional
per-`typeid` queue limit on `Mailbox.send`.** `limit == 0` (the default) keeps
the existing unbounded behavior byte-for-byte; `limit > 0` scans the queue
under the mailbox lock and fails with a new fault if that many items of the
same `typeid` are already queued. `send_oob` is untouched by design.

## What was measured on 2026-09-14, before any of this was ruled

- **The proposal's signature is pseudocode, not C3.** `usize` is not this
  codebase's type; every length here is `usz` (`InnerQueue.len` returns
  `usz`). The real signature is
  `fn void? Mailbox.send(&mbox, Slot* slot, usz limit = 0)`.
- **There is no `error{...}` set anywhere in `src/`.** Every failure in this
  toolkit is one shared `faultdef` in `mtk.c3:56` —
  `CLOSED, TIMEOUT, NOT_AVAILABLE, NOT_CREATED, EMPTY, WOKEN,
  UNKNOWN_IDENTITY` — imported and reused by every module. The proposal's
  "add a new error type" is really "add one member to that shared list."
- **No exhaustive switch or pattern-match over the fault set exists**, in
  `src/`, `test/`, `negative/` or `examples/`. Grepped for `switch`/`case`
  alongside every current fault name: no hits. Adding a member is a pure
  addition with no ripple to find.
- **The typeid read is already a public, one-line call.** `Inner.outer_tid()`
  (`inner.c3:110`) is part 1, not white box. `InnerQueue.iter()` /
  `.next()` (`queue.c3:66-71`) already yield `Inner*`. The scan needs no new
  accessor and no reach into an `::internal` module.
- **`Mailbox` is `typedef Mailbox = void;`** (`mailbox.c3:37`) — a plain
  opaque pointer, not an interface or vtable. The signature change has
  exactly one definition to edit and no second call site.
- **`Mailbox.send`'s doc block** (`mailbox.c3:120-133`) is a `<* *>` block
  the doc loop counts sentences in. A `@param limit` / an added `@return?`
  line moves the descriptor count away from `3TK-77`'s 463 — expected here,
  since code is changing, unlike a rename stage.
- **40 existing call sites of `.send(` across `test/`, `negative/` and
  `examples/`** all call it with one argument, so `limit == 0` by default
  and none of the 40 need touching.

## Proposed rulings

- **R-1 — the signature is `fn void? Mailbox.send(&mbox, Slot* slot, usz
  limit = 0)`.** `usize` in the proposal is corrected to `usz` in the stage,
  not asked about.
- **R-2 — the new fault joins the shared `faultdef` in `mtk.c3`**, not a
  local `error{}` set. Name: `LIMIT`, matching the shape of `CLOSED` /
  `TIMEOUT` / etc. (short, shouted, no `_REACHED` suffix — consistent with
  its five neighbors).
- **R-3 — the scan reads `Inner.outer_tid()` while walking the target
  queue with the existing iterator.** No new accessor, no internal reach.
- **R-4 — the check and the insert happen inside the lock `send_at` already
  holds**, per the proposal's own concurrency note. No new lock, no second
  acquisition.
- **R-5 — `limit == 0` keeps the current fast path untouched: no scan, no
  new branch cost.** The scan only runs when `limit > 0`.
- **R-6 — `send_oob` is not touched.** No `limit` parameter, no scan, no
  change to its signature or body.
- **R-7 — one new test and one new example, per the owner's ask.** The test
  exercises `limit > 0` reached (send fails with `LIMIT`, Slot untouched)
  and per-`typeid` isolation (a full type-A limit does not block type B),
  matching the proposal's own worked example. The example shows the
  one-argument call under *Slot and transfer idioms* or wherever
  `3tk-example-rules-006.md`'s groups put a mailbox-send variant — the stage
  decides the group from the rules file, not from a guess here.
- **R-8 — the reference and the proposal itself get one sentence each.**
  `3tk-reference-011.md`'s mailbox section documents the parameter and the
  new fault; the proposal's own `## Status` line moves from `Proposal` to
  `Adopted, implemented by 3TK-78` — Rule 14 applies if that is more than a
  sentence, R-4 (rename-stage sense) does not, since this is a real
  decision, not a name change.

## The stage

| stage | what it does | model |
|---|---|---|
| **3TK-78** | **Limited send.** Implement `usz limit = 0` on `Mailbox.send`, the `LIMIT` fault, the scan under the existing lock, one test, one example, doc-loop pass. | **Sonnet 5** |

**Why Sonnet 5.** Rule 10: the deciding is done in R-1 … R-8 above and in the
already-measured proposal; the stage applies them and the doc loop plus
`run-builds.sh` tell it when it is wrong.

### Steps — 3TK-78

**1. Re-measure.** Confirm `mailbox.c3:120-145` and `mtk.c3:56` are unchanged
since this plan was written; re-grep for a switch/case over the fault names,
same as above. Rule 13 applies: the measurement wins over the figures here.

**2. `mtk.c3`.** Add `LIMIT` to the `faultdef` line. One line.

**3. `mailbox.c3`.**
- `Mailbox.send`'s signature gains `usz limit = 0` and its doc block gains
  the parameter and the new `@return?`.
- `_Mbox.send_at` gains the same parameter, threaded through from `send`
  (`send_oob` passes nothing new — R-6).
- Inside the existing lock, when `limit > 0`: walk the target queue with
  `InnerQueue.iter()`, count entries whose `Inner.outer_tid()` equals the
  inserting item's own, and return `LIMIT~` without enqueuing if the count
  is already at `limit`.

**4. Test.** One new test (or a new function in `t_mailbox.c3`, the stage
decides which fits its existing shape) covering: `limit` reached returns
`LIMIT` and leaves the Slot full; a second `typeid` at the same mailbox is
unaffected; `limit == 0` is unchanged (already covered by the 40 existing
call sites, so this is the one net-new assertion, not a re-test of the old
path).

**5. Example.** One new example under the group `3tk-example-rules-006.md`
names for a mailbox-send variant, showing `mbox.send(&slot, N)` the way
`3tk-limited-send-001.md`'s own `## Example` section shows it.

**6. Doc pass.** `check-doc-loop.sh`, `move-module-docs.sh roundtrip`,
`run-builds.sh`. **Figures will differ from `3TK-77`'s on purpose** — one
new check for `LIMIT`, one new test, at least one new descriptor sentence.
The stage records what changed and why, not a claim that nothing moved.

**7. Reference and proposal.** `3tk-reference-011.md`'s mailbox section
gets the parameter and the fault (R-8). `3tk-limited-send-001.md`'s status
line is updated in `matryoshka-3tk/design/` directly, since that is where
design documents are edited (R-8).

**8. Log and status.** One log entry for 3TK-78, with the new figures.
Status: the 3TK-77 → 3TK-78 row, the stages-that-have-run table, and the
measured-numbers note updated to the new checks/tests/descriptor counts.

## What this stage does not do

- It does not touch `send_oob` (R-6).
- It does not add a bounded mailbox, a capacity, backpressure, or blocking —
  the proposal's own `## Scope` list stands.
- It does not add a per-type counter or new mailbox data structure — the
  scan is the first implementation, per the proposal's `## Complexity`.
- It does not copy anything to `matryoshka-3tk`'s `src`/`test`/`negative`/
  `examples` — that is the owner's step, as always.

## How to start after a clear

```
Read design/secondary/lang/c3/3tk-status.md and design/secondary/lang/c3/3tk-staging-plan-038.md, then run 3TK-78.
```
