# 3tk — staging plan 040

Written 2026-09-15.

**Provenance.** Follows `039`, which is spent: `3TK-79` closed on 2026-09-15.
Earlier plans are named, not linked — `backup/` is transient.
**Only `3TK-50` remains from any earlier plan, and it waits on the owner.**

State is in [3tk-status.md](3tk-status.md). Narrative is in
[3tk-log.md](3tk-log.md). **The rules are
[matryoshka-3tk/design/3tk-rules-007.md](https://github.com/g41797/matryoshka-3tk/blob/main/design/3tk-rules-007.md)**;
this plan cites them and does not re-argue them.

---

## Why this plan exists

**`3TK-79` fixed the register of `src/*.c3`'s comments; three follow-on
requests, made the same day, went further and are written up here as one
stage rather than three.** All three are prose- and naming-quality work,
the same kind `3TK-79` did, so they are one stage rather than a fresh plan
each:

1. **Two more words read as jargon, not plain English, and the owner
   named them by example.** `parked` (a thread blocked on a wait) and
   `quiet` (closed, with no call still running) are both metaphors where
   `3TK-79`'s own standard — state the fact, not a word for it — asks for
   plain language instead.
2. **`quiet` was not only a word choice — it was also a public API
   name.** `Mailbox.is_quiet()` / `Pool.is_quiet()` needed a real rename,
   not a prose rewrite, to stop using the word.
3. **Two declaration shapes in `src/*.c3` had never received per-item doc
   comments**: `mtk.c3`'s combined `faultdef` line, and `pool.c3`'s
   `GetMode` enum. The owner asked for the same one-doc-block-per-item
   shape on both, matching the `PERMISSION_DENIED` example from the C3
   manual.

## What was measured before any of this was ruled

- **`parked` and `quiet` were not previously banned**, in either
  `design/rules-049.md` Part 5 (source of truth for 3tk's banned-word
  scan, per `check-doc-loop.sh`'s own comment) or the script's `BANNED`
  copy.
- **`grep -n "\bparked\b"` across every `.c3` file in the 3tk tree**
  found 5 files beyond `src/`: `test/t_mailbox.c3`, `test/t_pool.c3`, and
  three `negative/*.c3` files, in identifier names (`parked_receiver`,
  `parked_getter`, a `struct Parked`) as well as prose. None called
  `is_quiet()` from `negative/`, which meant the rename's call-site
  surface was exactly `src/` (2 declarations) plus `test/t_mailbox.c3`
  and `test/t_pool.c3` (7 lines total) — confirmed by
  `grep -rn "is_quiet"`.
- **`3tk-reference-012.md` mirrors `quiet` well beyond the labelled
  module blocks** — the mailbox/pool `release`/`is_quiet`/`close` API
  prose, the `PoolHooks` doc, and a dedicated "closed is not quiet"
  narrative section with its own `OPEN -> CLOSED -> QUIET -> FREED`
  diagram. All had to be found and re-synced, not just the parts the doc
  loop's module-block check watches.
- **`c3c docgen`'s JSON never carries a `docs` field for a `"kind":
  "fault"` entry**, confirmed by an isolated two-line repro outside this
  repo (a file with only `PERMISSION_DENIED`, the manual's own example).
  `enum` members do get a `docs` field the same run. This is a `docgen`
  gap, not a mistake in how the doc comments are written, and not fixed
  in `0.8.4` per its own changelog (checked 2026-09-15).
- **`faultdef` has no brace-block form.** The language spec's grammar is
  `"faultdef" CONST_IDENT ("," CONST_IDENT)* attributes? ";"` — flat, no
  `{ }`. A doc comment per fault therefore means one `faultdef NAME;` per
  fault, not a block syntax the way `enum` offers one.

## Proposed rulings

- **R-1 — `parked` and `quiet` join Part 5 of `rules-049.md`, ztk's
  banned-word list**, which `check-doc-loop.sh`'s own comment names as
  3tk's source of truth for this scan. `check-doc-loop.sh`'s `BANNED`
  list is a copy of it and gets the same two words. `rules-049.md` was
  edited in place for this, not versioned to `-050.md` — a two-line
  addition to an existing list is not the kind of change Part 0's
  document-versioning gate exists for, and the file's own Part 10
  provenance history is unaffected either way; flagged to the owner as a
  live tension with that file's own hard gate, not silently resolved.
- **R-2 — `is_quiet` is renamed to `is_idle`, on both `Mailbox` and
  `Pool`.** Chosen over `can_release`, `is_release_ready` and
  `has_no_active_calls` by the owner directly: plain, literal, no
  metaphor, and keeps the codebase's existing `is_X` boolean-predicate
  shape (`is_closed`, `is_empty`, `is_full`, `is_linked`).
- **R-3 — every occurrence of `parked` and `quiet` in `src/*.c3` is
  replaced with the plain fact**, not a synonym. "A closed mailbox can
  still have calls running on it," not "a closed mailbox is not calm."
  Test and negative identifiers that used `parked` (`parked_receiver` →
  `waiting_receiver`, `parked_getter` → `waiting_getter`, `struct
  Parked` → `struct Waiting`) are renamed too, since leaving the banned
  word in an identifier the rename touches anyway would be inconsistent
  with R-1.
- **R-4 — the negative test filename `release_not_quiet_pool.c3` is left
  as it is.** Renaming a file ripples into `run-builds.sh`'s test-name
  arrays and its printed output; flagged to the owner rather than done
  on this stage's own judgment.
- **R-5 — `3tk-reference-012.md` is re-synced in the same stage**,
  R-4-of-`039`-style: every mirrored sentence the rename or the word
  ban touched, including the standalone "closed is not quiet" narrative
  section and its ASCII diagram, not only the labelled module blocks.
- **R-6 — `mtk.c3`'s `faultdef` line becomes eight separate `faultdef`
  declarations, each with its own doc comment.** The line's own former
  doc block ("3tk faults, returned via `void?`. Only `UNKNOWN_IDENTITY`
  causes abort in safe build.") becomes a plain `//` comment ahead of
  the first one — it cannot stay a `<* *>` block with nothing directly
  under it, which is not valid attachment.
- **R-7 — `pool.c3`'s `GetMode` enum gets the same one-doc-block-per-item
  treatment**, and `Pool.get`'s own doc block — which restated the three
  modes in its own words — is reworded to match, so the two don't drift
  apart.
- **R-8 — the `docgen` gap for `faultdef` is reported in
  `3tk-status.md`, not chased.** No stage upgrades `c3c` or rewrites the
  new doc comments looking for a shape `docgen` will render; the
  comments are correct C3 and correct for a source reader regardless of
  what the generated site currently shows.

## The stage

| stage | what it does | model |
|---|---|---|
| **3TK-80** | **Word bans, an API rename, and per-item doc comments.** Ban `parked`/`quiet`; rename `is_quiet` to `is_idle` everywhere it is called; rewrite every remaining `parked`/`quiet` occurrence in `src/*.c3`, `test/*.c3` and `negative/*.c3`; split `mtk.c3`'s `faultdef` and document `pool.c3`'s `GetMode` per item; re-sync `3tk-reference-012.md`; record the `docgen` gap. | **Sonnet 5** |

**Why Sonnet 5.** Rule 10: the deciding was done live with the owner —
which words to ban, which rename to take, which files to touch — and
what is left is applying it: a grep-guided sweep with the doc loop and
`run-builds.sh` as the check.

### Steps — 3TK-80

**1. Ban `parked` and `quiet`.** Add both to `rules-049.md` Part 5 and
`check-doc-loop.sh`'s `BANNED` list.

**2. Rewrite `parked`/`quiet` in `src/*.c3`.** Every doc block, `//`
comment, and `always_assert` message; the `Mailbox.is_quiet` /
`Pool.is_quiet` function declarations rename to `is_idle`.

**3. Update call sites.** `test/t_mailbox.c3`, `test/t_pool.c3`:
`.is_quiet(` → `.is_idle(`, test names and assert messages reworded.
`negative/*.c3`: prose and the `parked`-named identifiers reworded/
renamed; filenames untouched (R-4).

**4. Re-sync `3tk-reference-012.md`.** Every mirrored sentence the
rename or the ban touched, module blocks and narrative prose both.

**5. Split `mtk.c3`'s `faultdef`.** Eight declarations, each with a doc
comment stating the fault's plain meaning, sourced from the `@return?`
directives already on the functions that raise each one.

**6. Document `pool.c3`'s `GetMode`.** One doc comment per enum value;
reword `Pool.get`'s own doc block to match.

**7. Verify.** `c3c build`, `c3c test` (148 tests), `check-doc-loop.sh`
(module blocks, per-file descriptors, banned words), `run-builds.sh`.

**8. Record the `docgen` gap** in `3tk-status.md` (R-8), with the
isolated repro and the `0.8.4` changelog check.

**9. Log and status.** One log entry for `3TK-80`. Status: the
`3TK-79` → `3TK-80` row and the measured-numbers note.

## What this stage does not do

- It does not rename `negative/release_not_quiet_pool.c3` (R-4).
- It does not upgrade `c3c` or otherwise chase the `faultdef` `docgen`
  gap (R-8).
- It does not version `rules-049.md` to a new number (R-1) — flagged as
  a live tension with that file's own hard gate, not resolved here.
- It does not copy anything to `matryoshka-3tk`'s `src`/`test`/
  `negative`/`examples` — that is the owner's step, as always.

## How to start after a clear

```
Read design/secondary/lang/c3/3tk-status.md and
design/secondary/lang/c3/3tk-staging-plan-040.md, then run 3TK-80.
```
