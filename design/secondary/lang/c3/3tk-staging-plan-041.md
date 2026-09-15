# 3tk — staging plan 041

Written 2026-09-15.

**Provenance.** Follows `040`, which is spent: `3TK-80` closed on 2026-09-15.
Earlier plans are named, not linked — `backup/` is transient.
**Only `3TK-50` remains from any earlier plan, and it waits on the owner.**

State is in [3tk-status.md](3tk-status.md). Narrative is in
[3tk-log.md](3tk-log.md). **The rules are
[matryoshka-3tk/design/3tk-rules-007.md](https://github.com/g41797/matryoshka-3tk/blob/main/design/3tk-rules-007.md)
and [design/rules-049.md](../../../rules-049.md) Parts 4-6**;
this plan cites them and does not re-argue them.

**Git is disabled for every stage of this plan.** No git command runs, and
nothing is committed.

---

## Why this plan exists

**After `3TK-80` closed, the owner had the comments in `src/*.c3` rewritten
by Gemini, in a human-readable style.** Every file changed: `helper.c3`,
`inner.c3`, `mailbox.c3`, `mtk.c3`, `pool.c3`, `queue.c3`. Module doc blocks
are shorter. Fault descriptions are reworded. Reasoning comments in the
release bodies are gone.

**The owner keeps this text.** It can be worked with: edited, added to,
improved. It is not thrown away and rewritten again.

**Example generation was removed from the CI yml.** The comments in
`examples/*.c3` have the same AI shape the old `src/` comments had. They are
brought to the `src/` style.

**Gemini did not have the owner's rules** on prose, staccato style and
bullets. Where the new `src/` text breaks those rules, the rules win.

## What was measured before any of this was ruled

- **`check-doc-loop.sh` against the new `src/`**, 2026-09-15:
  - module blocks: 11 differing, 4 labelled blocks carried by the wrong
    number of files;
  - descriptors: 137 sentences, 2 found, 135 missing — `helper.c3` 34/2,
    `inner.c3` 25/0, `mailbox.c3` 21/0, `mtk.c3` 17/0, `pool.c3` 28/0,
    `queue.c3` 12/0;
  - banned words: 5 hits, all in `src/`, none in `3tk-reference-012.md` —
    `helper.c3:9` (`lifecycle`), `pool.c3:5,352,357,380` (`object`,
    `drain`).
- **`3tk-reference-012.md` mirrors the old text.** Nearly every descriptor
  sentence in it is now missing from source.
- **The 3TK-80 figures in status and log are stale** for the doc loop. The
  build, test and `run-builds.sh` figures were not re-measured.
- **`examples/` holds 64 `.c3` files.** Each carries a `<* *>` module block
  of a sentence plus bullets; a few also carry `//` comments
  (`023-infrastructure_wrapper.c3`, `010-no_raw_allocator_call.c3`,
  `061-a_composite_outer_gives_back_its_parts.c3`, `outers.c3`,
  `018-dispatch_identity_first.c3`).

## Proposed rulings

- **R-1 — the owner's new `src/` comments are the baseline.** A stage edits
  them in place. It does not rewrite them from scratch.
- **R-2 — the reference follows source.** `3tk-reference-012.md` is re-synced
  to the new `src/` text, module blocks and mirrored narrative both.
- **R-3 — where the new `src/` text breaks rules-007 or rules-049 Parts 4-6,
  the rule wins.** That covers the 5 banned-word hits and any prose, staccato
  or bullet violations. The fix is the smallest edit that keeps the owner's
  wording. Each fix is listed in the log entry.
- **R-4 — example comments take the voice and wording of `src/`,** with the
  same R-3 exception.
- **R-5 — the exemplar comes before the sweep** (rules-007 §11). `3TK-82`
  rewrites one example, stops, and the owner confirms it.
- **R-6 — git is disabled.**

## The stages

| stage | what it does | model |
|---|---|---|
| **3TK-81** | **Reference sync.** Fix the rule breaks in `src/` (R-3); re-sync `3tk-reference-012.md` to `src/` (R-2); refresh the stale figures. | **Sonnet 5** |
| **3TK-82** | **Example comments in `src/` style.** One exemplar, owner confirms, then the sweep over `examples/*.c3`. | **Opus 5** |

**Why Sonnet 5 for 3TK-81.** Rule 10: the text is settled by the owner, and
the doc loop says when the sync is wrong. The R-3 fixes are small and each is
reported.

**Why Opus 5 for 3TK-82.** Rule 10: the style is not written down. It has to
be read out of `src/` and reconciled with the rules. That is deciding, and the
exemplar binds the sweep.

### Steps — 3TK-81

**1. Read the new `src/*.c3`** in full. Do not edit wording yet.

**2. Fix the rule breaks (R-3).** The 5 banned-word hits first. Then prose,
staccato and bullet violations against rules-049 Parts 4-6. Smallest edit that
keeps the owner's wording. List each one.

**3. Re-sync `3tk-reference-012.md`.** Module blocks, descriptor sentences,
and every narrative passage that quotes the old text.

**4. Verify.** `c3c build`, `c3c test`, `check-doc-loop.sh` (0 differing
blocks, all descriptors found, 0 banned hits), `run-builds.sh`.

**5. Log and status.** One log entry for `3TK-81`, with the R-3 edit list.
Status: the row, the measured figures, and *How to start after a clear*
pointing at `3TK-82`.

### Steps — 3TK-82

**1. Read `src/*.c3` comments and write down the style** as a short list in
the log entry: sentence shape, words used, what is said and what is left out.
Where it breaks the rules, note the rule that wins.

**2. Exemplar.** Rewrite the comments of one example —
`001-empty_slot.c3` — in that style. **Stop and show it to the owner.**

**3. Sweep**, after the owner confirms: every `examples/*.c3`, `<* *>` blocks
and `//` comments. Comments only — no code, no identifiers, no filenames.

**4. Verify.** `c3c build`, `c3c test`, `check-doc-loop.sh`,
`run-builds.sh`.

**5. Log and status.** One log entry for `3TK-82`. Status: the row, the
figures, and *No stage is queued*.

## What these stages do not do

- No git.
- They do not rewrite the owner's `src/` comments beyond the R-3 fixes.
- They do not restore example generation in the CI yml.
- They do not change code, identifiers or filenames.
- They do not copy anything to `matryoshka-3tk` — that is the owner's step,
  as always.

## How to start after a clear

**3TK-81 — Sonnet 5:**

```
Read design/secondary/lang/c3/3tk-status.md and
design/secondary/lang/c3/3tk-staging-plan-041.md.
Read matryoshka-3tk/design/3tk-rules-007.md and design/rules-049.md Parts 4-6.
Git is disabled. Run 3TK-81.
```

**3TK-82 — Opus 5:**

```
Read design/secondary/lang/c3/3tk-status.md and
design/secondary/lang/c3/3tk-staging-plan-041.md.
Read matryoshka-3tk/design/3tk-rules-007.md and design/rules-049.md Parts 4-6.
Git is disabled. Run 3TK-82.
```
