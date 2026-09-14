# 3tk — staging plan 037

Written 2026-09-14.

**Provenance.** Follows `036`, which is spent: `3TK-75` and `3TK-76` both closed  
on 2026-09-10. Earlier plans are named, not linked — `backup/` is transient.  
**Only `3TK-50` remains from any earlier plan, and it waits on the owner.**

State is in [3tk-status.md](3tk-status.md). Narrative is in
[3tk-log.md](3tk-log.md). **The rules are
[matryoshka-3tk/design/3tk-rules-007.md](https://github.com/g41797/matryoshka-3tk/blob/main/design/3tk-rules-007.md)**;
this plan cites them and does not re-argue them.

---

## Why this plan exists

**This repo was renamed from `matryoshka-tk` to `matryoshka-ztk`, on the remote and locally.**  
Commits `d36a64a` and `4a78b21` did the rename everywhere except  
`design/secondary/lang/`. The owner has already replaced `-tk` with `-ztk` across  
`matryoshka-3tk/`, and Rule 12 of `007` already says `matryoshka-ztk`.  
**What is left: finish the rename under `lang/` and check the owner's edit.**

## What was measured on 2026-09-14, before any of this was ruled

- **`design/secondary/lang/`: 48 hits in 10 files.** 40 are the bare name. The
  rest are URLs: `github.com/g41797/matryoshka-tk/...` and  
  `g41797.github.io/matryoshka-tk/`.
  - Live: `c3/3tk-status.md` 3, `c3/3tk-staging-plan-034.md` 2,
    `c3/3tk-sanitizer-notes-001.md` 1, `c3/ref/3tk-doc-loop-005.md` 1,  
    `c/ctk-proposal.md` 1, `odin/odin-to-zig-backport-001.md` 1.
  - Append-only: `c3/3tk-log.md` 16.
  - `backup/`: 22, in `3tk-example-rules-002.md` 12,
    `3tk-port-findings-004.md` 6 and `3tk-build-dist.md` 4.
- **No filename under `lang/` contains `matryoshka-tk`.**
- **`matryoshka-3tk/` has 0 hits for `matryoshka-tk`**, and every `-ztk` hit is
  `matryoshka-ztk…`. It still has relative links into this repo, for example  
  `../../matryoshka-ztk/design/secondary/lang/c3/3tk-log.md`, and **nobody has checked yet that they resolve.**
- **Outside `lang/`, 10 more files still say `matryoshka-tk`**, among them
  `design/context.md` and `design/secondary/context.md`. Some are historical  
  filenames such as `matryoshka-tk-implementation-plan-072.md`.
- **A stale `../matryoshka-tk/` directory still exists locally**, with its own
  `.git`, `design/`, `docs/` and `examples/`. A path that still says the old name  
  resolves there **silently** instead of failing.

## Proposed rulings

- **R-1 — live documents say `matryoshka-ztk`**: the bare name, the GitHub URLs
  and the Pages URL.
- **R-2 — `3tk-log.md` is not rewritten.** It is append-only (a standing fact);
  the 3TK-77 entry records the rename once.
- **R-3 — `backup/` is not touched.** It is transient.
- **R-4 — a rename does not version a document.** Replacing one name is the
  *"a sentence changed"* case, so Rule 14 does not apply and each file is edited in place.
- **R-5 — reported, not acted on:** the 10 files outside `lang/` and the stale
  `../matryoshka-tk/` directory. Both are the owner's.
- **R-6 — only the exact repo name changes.** `ztk` the port, `3tk`, `dtk`,
  `otk`, and filenames that record history such as  
  `matryoshka-tk-implementation-plan-072.md` are different tokens.

## The stage

| stage | what it does | model |
|---|---|---|
| **3TK-77** | **The rename.** Rewrite the live `lang/` hits to `matryoshka-ztk`, check the owner's `-ztk` edit in `matryoshka-3tk`, and prove that no figure moved. | **Sonnet 5** |

**Why Sonnet 5.** Rule 10: the deciding is done in R-1 … R-6, so the stage only  
applies them, and grep plus the unchanged figures tell it when it is wrong.

### Steps — 3TK-77

**1. Re-measure.** Grep the whole word `matryoshka-tk` under `lang/`, in every  
file type: `.md`, `.sh`, `.py`, `.json`, `.yml`, `.notes.txt`. Rule 13 applies: the  
measurement wins over the figures above.

**2. Rewrite the live hits** under R-1, R-4 and R-6.

**3. Check `matryoshka-3tk`.**
- Grep for over-renames: `-ztk` where no repo is meant, `ztkk`, `3ztk`, `-ztk-`.
- Resolve every relative or absolute path containing `matryoshka-ztk` on disk.
- Rule 12: diff the four ported scripts against this repo's copies. **`ROOT` must be the
  only difference.**
- Read the three `.yml` files, `docs.yml` included, for repo names and URLs.
  **"None needed" is written into the log** if nothing needs changing.

**4. Close.** `run-builds.sh`, `check-doc-loop.sh`, `move-module-docs.sh  
roundtrip`. **Every figure stays identical to `3TK-76`'s**: 123 checks, 146 tests  
in each of four builds, doc loop 11 blocks, 0 differing, 463 of 463. No code  
changes, so the sanitizers are not re-run.

**5. Log and status.** One log entry for 3TK-77. In the status, edited in place: the  
3TK-77 row, **and two stale spots found while writing this plan**. The *stages that have  
run* list stops at `3TK-75`, and the *measured numbers* note still names `3TK-75`  
as the last run.

## What this stage does not do

- It does not rewrite the log or `backup/` (R-2, R-3).
- It does not touch `design/` outside `lang/`, or `../matryoshka-tk/` (R-5).
- It does not change `.c3` sources.
- It does not renumber anything.

## How to start after a clear

```
Read design/secondary/lang/c3/3tk-status.md and design/secondary/lang/c3/3tk-staging-plan-037.md, then run 3TK-77.
```
