# 3tk — staging plan 045

Written 2026-09-17.

**Provenance.** Follows `044`, which is spent: `3TK-90` closed `D-1` and `D-2`
on 2026-09-17. **Only `3TK-50` remains from any earlier plan, and it waits on
the owner.**

State is in [3tk-status.md](3tk-status.md). Narrative is in
[3tk-log.md](3tk-log.md). **The rules are
[matryoshka-3tk/design/3tk-rules-007.md](https://github.com/g41797/matryoshka-3tk/blob/main/design/3tk-rules-007.md)
and [design/rules-049.md](../../../rules-049.md) Parts 4-6.**

**Its input is
[3tk-readme-creation-003.md](https://github.com/g41797/matryoshka-3tk/blob/main/design/3tk-readme-creation-003.md)**:
*What is decided*, debt `D-3` in *What is open*, and *The module mapping
table*. **The finished `matryoshka-3tk/README.md` is the wording source.**
**`src/*.c3` is the only source of truth for any fact.**

**Git is disabled for every stage of this plan.**

---

## Why this plan exists

**Two tiers were ruled on 2026-09-16.**

- The README is the base.
- The deep dive is each module's own `<* *>` block.
    - Not a separate document.

**The README is finished. The module blocks are not written from it.**

- Today's blocks predate the README.
- Four of the six public ones are one to three lines.
    - `mtk`: one line.
    - `mtk::queue`: one line.
    - `mtk::pool`: two lines.
    - `mtk::mailbox`: three lines.
- Their voice is not the README's.
    - *"Core type erasure primitives"*.
    - *"System containers interact strictly with `Inner*` pointers"*.
- The mapping table lists what each block owes.
    - Nothing in `src/` carries it yet.

**One gap makes a module block the only place for some facts.**

- `c3c` 0.8.3 `docgen` drops every `faultdef` doc comment.
    - See *What is live now* in the status file.
    - Not fixed in `0.8.4` either.
- **This is no longer a reason to write anything.** `045-O-5` was ruled `c` on
  2026-09-18: the faults are documented at their declarations, and no block
  repeats them to work around a compiler gap.

## What the stages work against

**The eleven modules**, measured 2026-09-17 from
`design/secondary/lang/c3/3tk/src/`. Re-print before trusting a line.

| module | file:line | in the mapping table |
|---|---|---|
| `mtk` | `mtk.c3:7` | yes |
| `mtk::inner` | `inner.c3:11` | yes |
| `mtk::inner::internal` | `inner.c3:120` | no |
| `mtk::helper <Outer>` | `helper.c3:20` | yes |
| `mtk::mailbox` | `mailbox.c3:9` | yes |
| `mtk::mailbox::internal` | `mailbox.c3:279` | no |
| `mtk::pool` | `pool.c3:8` | yes |
| `mtk::pool::hooks` | `pool.c3:354` | no — but `mtk::pool`'s row owes *the three hooks* |
| `mtk::pool::internal` | `pool.c3:396` | no |
| `mtk::queue` | `queue.c3:7` | yes |
| `mtk::queue::internal` | `queue.c3:143` | no |

**The reference mirrors each block.**

- `3tk-reference-015.md` has one labelled block per module.
    - `<!-- 3tk:module X -->` … `<!-- /3tk:module -->`.
- `check-doc-loop.sh` diffs every module block against its labelled block.
- It also requires every descriptor line in `src/` to appear in the reference.
- So a new module block is written twice, byte for byte.

**The mapping table, row by row, as the stages read it.**

**Re-sourced by the README round, 2026-09-18.** The table lives in
[3tk-readme-creation-003.md](https://github.com/g41797/matryoshka-3tk/blob/main/design/3tk-readme-creation-003.md).
**Read it there. What follows is the short form.**

- `mtk`
    - source: *Matryoshka* — six modules, eight faults.
    - owed: the outcome set named, **not the eight listed** (`045-O-5`);
      `@check` and what safe mode means.
- `mtk::inner`
    - source: *The request carries its own link*; *The request carries its own
      type*; ***One struct, two addresses***; *The one struct you write*.
    - owed: `Inner`'s two fields and why `any` stays outside; the full `Slot`
      surface; `to` vs `as` vs `must`; the one-`Inner` check.
- `mtk::helper`
    - source: *One helper per type does the boring part*; *One struct, two
      addresses*; the `defer` sketches in *The slot — read this one twice, at
      least*.
    - owed: the two required methods and the empty body; `look`/`take`/
      `must_*`; `stamp`; `inner`, `linked`; **the `any` crossings** — `is`,
      `to_any`, `to_slot`, `look`/`take` on `any*`.
    - **The README no longer explains the crossings.** *If you already have a
      channel* is gone, so the whole subject is this block's.
- `mtk::mailbox`
    - source: *A queue that answers the hard questions*; *What the mailbox adds
      to a channel*, now a `###` under *How to start*.
    - owed: the fixed outcome set per call; `limit` and `send_oob`; what
      `close` gives back; a refused `send` leaves the slot full.
- `mtk::pool`
    - source: *Requests come from a pool*; *The rules of reuse are yours*.
    - owed: `GetMode`'s three policies; the three hooks; `in_pool` is a stale
      hint; `get_wait` never calls `on_get`.
- `mtk::queue`
    - source: *You do not have to use everything*; *How to start*, step 1.
    - owed: `iter`, `push_back`, `pop_front`, `take`, `append_queue`; where a
      reader meets it.
    - **Done.** `3TK-91`'s exemplar.

**All six are written. `3TK-92` closed the five on 2026-09-18**, and
`mtk::pool::hooks` with them. **`3TK-93` records it and closes `D-3`.**

**What the README round changed under the stages' feet, 2026-09-18.**

- **New sections.** *One struct, two addresses*, *Show cases*, *When to stop*.
- **Renamed.** *Only the address moves* → *The slot — read this one twice, at
  least*.
- **Gone.** *If you already have a channel*.
- **The voice a block copies** is the README as it stands now, not as `3TK-91`
  read it.

## What is decided

**Carried from `3tk-readme-creation-003.md`. Not reopened here.**

- **Two tiers.** The deep dive is the module's `<* *>` block.
- **Nothing is said in both tiers.**
- **No mermaid.** ASCII only.
- **Voice.** Staccato, `rules-049.md` Part 6. Part 5's banned list, the
  `fed` family included.
- **More humanity.** Plain English. No smart words.
- **Every claim is checked against `src/*.c3`.**
- **Tagged unions are not C3.** *An enum tag plus a union.*
- **The block names no source of its wording.**

**Carried from `3tk-rules-007.md`.**

- **Rule 2.** An `::internal` block has no prose beyond its marker and working
  directives.
- **Rule 4.** Every module carries a block. `mtk` is a landing page.
- **Rule 4.** `c3fmt` is not run on `src/`.
- **Rule 5.** `[[LOC]]` stays a token. No count is written into a block.
- **Rule 11.** One exemplar block first, checked, then the rest.
- **Rule 12.** Scripts are edited in both repos; the port is the `ROOT` line.
- **Rule 14.** The reference is versioned, not edited in place.

**Carried from `rules-049.md` Part 4.**

- **No `.md` reference inside a `.c3` comment.** The block stands alone.
- **An ASCII diagram in a doc comment is fenced**, if it is kept at all.

**Ruled by the owner, 2026-09-18, on `3TK-91`'s recommendations.**

- **`045-O-1` — b.** A block carries only what it owes.
    - The README's wording is its voice, not its text.
    - Nothing is said in both tiers.
- **`045-O-2` — a.** The module block orients and names.
    - The declaration keeps the detail.
    - **No declaration block is touched by `3TK-92`.**
    - What is owed and sits on no declaration goes in the module block.
- **`045-O-3` — a.** An ASCII diagram is allowed, fenced.
    - The probe proved it renders, and keeps its shape.
    - Not where the README already draws the same thing.
- **`045-O-4` — a.** `mtk::pool::hooks` is rewritten, as user surface.
    - The four `::internal` blocks stay as they are.
    - **Their missing `For internal usage.` marker stays flagged**, not fixed.
- **`045-O-5` — c**, a third option the stage's check produced.
    - **Nothing is written around the compiler.**
    - `mtk`'s block names the outcome set. It does not list the eight.
    - **Every fault is already documented at its own declaration** —
      `mtk.c3:23-61`, one `<* *>` block each, correct C3.
    - **Measured 2026-09-18, on the real `src/`:** `docgen` 0.8.3 emits all
      eight as `"kind":"fault"` with no `docs` field at all, so the site shows
      eight bare names. **The gap is the compiler's, and the source is right.**
    - **So a block that repeated them would be a second source of truth, kept
      in step by hand, and dead the day `c3c` is fixed.**

## What is open

**Nothing. `045-O-1`..`045-O-5` were ruled by the owner on 2026-09-18 and the
rulings are in *What is decided* above.**

- `045-O-1` — b. Only what the block owes.
- `045-O-2` — a. No declaration block is touched.
- `045-O-3` — a. Fenced diagrams allowed.
- `045-O-4` — a. `mtk::pool::hooks` rewritten; the four `::internal` left.
- `045-O-5` — c. The faults are documented where they are declared, and no
  block repeats them.

**`3TK-92` needs no further answer to start.**

## What `3TK-91` measured

**Ran 2026-09-17 on Opus 5. Recorded here. A later stage does not re-probe.**

### The renderer

- `c3c` 0.8.3 `docgen` copies the block text into `docs.html` as is.
- The page draws it with `formatDocText`, inside `docs.html`.
    - A line formatter. Not CommonMark.
- Probed in the scratchpad. The output was read off the real function, run in
  `node`.

| written | rendered |
|---|---|
| a blank line | a paragraph break |
| two lines with no blank line | one paragraph, with a line break between them. **Not joined** |
| `## Heading` | a real heading, `<h2>` |
| `- item` | one bullet line |
| a nested bullet, indented 4 spaces | **a flat bullet.** The indent is thrown away |
| a bullet that wraps onto a second line | **the second line becomes a stray paragraph** |
| `1. item` | plain text. **No numbered list** |
| inline code | inline code |
| `**bold**`, `*emph*` | bold, emphasis |
| a fenced block | kept. **An ASCII diagram keeps its shape** |
| a bare `push_back` or `Inner*`, not in backticks | **broken.** `_` and `*` turn into emphasis |

**What follows for every block.**

- One bullet, one line. No wrapping.
- No nested bullets. Use a heading, or a lead-in line, instead.
- No numbered lists.
- Every name in backticks.
- A diagram is possible, fenced.
- The module's whole block is also the hover tooltip on the overview page.

### `mtk::queue`, owed facts, with `file:line`

Lines as they are after the exemplar.


- `iter` — `queue.c3:70`. `InnerQueueIterator.next` changes nothing but its
  cursor, `queue.c3:75-80`.
- `push_back` — `queue.c3:87`. The guard, `queue.c3:177-179`:
    - a `null` inner
    - an inner already on a chain
    - an unstamped outer
- `push_back_slot` — `queue.c3:101`. Checks the slot is full; `take` empties it.
- `pop_front` — `queue.c3:111`. `null` when empty; `reset` clears the link,
  `inner.c3:198`.
- `take` — `queue.c3:132`. Returns the chain by value; this queue is empty.
- `append_queue` — `queue.c3:146`. Checks `null` and self; the other queue is
  empty afterwards.
- No lock — `struct InnerQueue`, `queue.c3:42-47`.
- All checks are `mtk::@check`, safe mode only — `mtk.c3:69`.
- Where a reader meets it:
    - `Mailbox.receive_all` — `mailbox.c3:173`
    - `Mailbox.close` — `mailbox.c3:221`
    - `PoolHooks.on_put`'s `extra` — `pool.c3:377`
    - `PoolHooks.on_close` — `pool.c3:384`
- **Nothing owed was missing from `src/`.**

### The exemplar

- `src/queue.c3`, the `mtk::queue` block. 31 lines.
- The labelled block in `3tk-reference-014.md`, edited in place.
- `check-doc-loop.sh queue.c3`: 0 differing, 36 of 36, 0 banned.
- `check-doc-loop.sh`, all files: 0 differing, 192 of 192, 0 banned.
- `c3c build` green. `c3c test`: 159 passed.
- Rendered and read.

**Seen and not fixed.** `mtk::queue::internal`'s block reads *The insert guard
shared by the intrusive containers. Not part of the public API.* — not Rule 2's
marker. The same for the other `::internal` blocks. `045-O-4`.

## The stages

| stage | what it does | model |
|---|---|---|
| **3TK-91** | **Probe, exemplar, questions.** Measure what `docgen` renders; write one exemplar block; put `045-O-1`..`045-O-5` to the owner. | **Opus 5** |
| **3TK-92** | **The public blocks.** The other five public modules, plus `hooks` if `045-O-4` says so; the reference to `015`. **Ran 2026-09-18 on Opus 5 and closed.** All five written, `hooks` rewritten, reference at `015`, `014` in `backup/`. `c3c test` 159; `run-builds.sh` 135/9, the same 9; doc loop 0 differing, 424 of 424, 0 banned. | **Opus 5** |
| **3TK-93** | **Close `D-3`.** Checks, banned-word scan, `3tk-readme-creation-003.md`, status. | **Sonnet 5** |

**Why Opus 5 for the first two.** Rule 10:

- `3TK-91` measures, writes the exemplar every later block copies, and frames
  the owner's rulings.
- `3TK-92` writes prose that is the published deep dive, and every sentence is
  a claim checked against `src/`.

**Why Sonnet 5 for the last.** It runs checks and records rulings already
made.

### Steps — 3TK-91

**1. Probe `docgen` on a module block.** In the scratchpad, not in `src/`.

- A copy of one module with a long block.
- What renders, read off the generated page:
    - a blank-line paragraph break
    - a bullet list, and a nested one
    - a fenced ASCII diagram
    - inline code
    - a heading line, such as `## Usual flow`
- **Record the result. A later stage does not re-probe.**

**2. Measure the owed facts, with `file:line`.**

- Every item in the mapping table's *owed* column.
- A fact not in `src/` is not written. It is reported.

**3. Write the exemplar.**

- **`mtk::queue` is the recommended exemplar.**
    - Smallest owed list.
    - One file, one page.
    - No generic parameter.
- The block in `src/queue.c3`.
- The labelled block in `3tk-reference-014.md`, byte for byte.
    - One block changed, so this stage edits in place.
    - `015` is `3TK-92`'s, when more than one block moves.
- `check-doc-loop.sh queue.c3`: clean.
- `c3c build`, `c3c test`: green.
- Render the page. Read it.

**4. Put `045-O-1`..`045-O-5` to the owner.** Options and a recommendation each.

**5. Show the exemplar and the questions. Stop.** `3TK-92` starts from the
answers, recorded in this plan's *What is decided*.

### Steps — 3TK-92

**Order: `mtk::inner`, `mtk::helper`, `mtk::mailbox`, `mtk::pool`, `mtk`.**

- `mtk` goes last. A landing page names what the others became.

**Per module.**

- Write the block from its README passages and its owed list.
- Check each claim against `src/`.
- Copy it to the labelled block.
- `check-doc-loop.sh <file>.c3`: clean before the next module.

**Then.**

- `mtk::pool::hooks`, if `045-O-4` says so.
- `3tk-reference-014.md` → `015` (Rule 14).
    - Header says what changed and who ruled it.
    - `014` to `backup/` with a plain `mv`.
    - Repoint `check-doc-loop.sh` and `move-module-docs.sh`.
    - Re-anchor every live link to `014`, in both repos, outside `backup/`
      and the log.
- `run-builds.sh`: 135 checks, the same 9 failures.
    - `pool.c3`'s module order is one of them. **Not fixed here.**
- `c3c build`, `c3c test`: green, 159.
- Render all six public pages. Read each.

### Steps — 3TK-93

- `check-doc-loop.sh`, all files: clean.
- Banned-word scan, run live.
    - `src/*.c3` comments and the reference.
    - Part 5's list, the AI-sh list, the `fed` family with `_` as a separator.
- **Every claim in a module block is greppable in `src/`.**
- No `.md` name inside any `.c3` comment.
- `3tk-readme-creation-003.md`:
    - `D-3` closed.
    - The mapping table's `helper` row: *once D-1 closes* removed.
    - One sentence changed per row, so edited in place with a changelog row.
- The status file: `D-3` closed; the next step named.
- The log: one entry per stage.

---

## Verification

- `c3c build`, `c3c test` — green, 159 tests.
- `run-builds.sh` — 135 checks, the same 9 failures.
- `check-doc-loop.sh` — clean. The descriptor count grows by the new lines.
- Banned-word scan, run live.
- The six public module pages rendered and read.

## What this plan does not do

- **No git**, at any stage.
- **No copy to `matryoshka-3tk/src/`** — the owner's step.
- **No README change.** The README is finished.
- **No code change.** Comments only.
    - Not `pool.c3`'s module order.
    - Not the 8 pre-existing `run-builds.sh` failures.
- **No `c3c` upgrade** to chase the `faultdef` gap.
- **No `c3fmt`.**
- **No uncommenting `docs.yml`'s `examples/` line.**

## How to start after a clear

**3TK-91 — Opus 5:**

```
Read design/secondary/lang/c3/3tk-status.md and
design/secondary/lang/c3/3tk-staging-plan-045.md.
Read matryoshka-3tk/design/3tk-readme-creation-003.md — "What is decided",
"What is open" and the mapping table.
Read matryoshka-3tk/README.md.
Read matryoshka-3tk/design/3tk-rules-007.md
and design/rules-049.md Parts 4-6.
Git is disabled. Run 3TK-91.
```

**3TK-92 — Opus 5:**

```
Read design/secondary/lang/c3/3tk-status.md and
design/secondary/lang/c3/3tk-staging-plan-045.md — "What is decided" first,
then "What 3TK-91 measured".
Read matryoshka-3tk/design/3tk-readme-creation-003.md — the mapping table.
Read matryoshka-3tk/README.md.
Read matryoshka-3tk/design/3tk-rules-007.md
and design/rules-049.md Parts 4-6.
Read src/queue.c3's module block — it is the exemplar.
mtk::helper owes the any crossings whole: the README no longer explains them.
Git is disabled. Run 3TK-92.
```

**3TK-93 — Sonnet 5:**

```
Read design/secondary/lang/c3/3tk-status.md and
design/secondary/lang/c3/3tk-staging-plan-045.md.
Read matryoshka-3tk/design/3tk-readme-creation-003.md — "What is open"
and the mapping table.
Read design/rules-049.md Parts 4-6.
Git is disabled. Run 3TK-93.
```
