# 3tk — staging plan 042

Written 2026-09-15.

**Provenance.** Follows `041`, which is spent: `3TK-82` closed on 2026-09-15.
**Only `3TK-50` remains from any earlier plan, and it waits on the owner.**

State is in [3tk-status.md](3tk-status.md). Narrative is in
[3tk-log.md](3tk-log.md). **The rules are
[matryoshka-3tk/design/3tk-rules-007.md](https://github.com/g41797/matryoshka-3tk/blob/main/design/3tk-rules-007.md),
[matryoshka-3tk/design/3tk-example-rules-007.md](https://github.com/g41797/matryoshka-3tk/blob/main/design/3tk-example-rules-007.md)
(`006` when this plan was written; `3TK-83` versioned it)
and [design/rules-049.md](../../../rules-049.md) Parts 4-6.**

**Git is disabled for every stage of this plan.**

---

## Why this plan exists

**The owner read `shc::a_slot_and_transfer`'s page and found three problems.**
The other module pages have the same ones.

- **Catalog numbers mean nothing to the reader.** *"catalog entries 1 through 4"*.
  The reader of the docs site has never seen the catalog.
- **Text about the catalog, not about the module.** *"Entry 2 ... has no file"*,
  *"The catalog lists the cleanup idioms under this section"*,
  *"This module holds no code of its own."*
- **A list item names a file, not a module.** `001-empty_slot.c3` does not link.
  `shc::a_slot_and_transfer::empty_slot` is what the reader can follow.

## What was measured

All 64 files under `examples/` were read on 2026-09-15.

- **11 group files** (`a_` … `k_`) carry all three problems.
  - Every one opens with *"…, catalog entries N through M."*
  - 9 of 11 have *"Entry N … has no code of its own"* lines.
  - All 11 end with *"This module holds no code of its own."*
  - All 11 list children as `NNN-name.c3`.
- **`shc.c3`** explains `NNN-name.c3` and *"its row in the pattern catalog"*,
  and ends with *"This module holds no code of its own."*
- **`k_new_in_3tk.c3`** says *"no entry … in the port 3tk came from"*.
  That is porting history, not a fact a C3 user can use.
  It also says *"Entry 62 … has no code"*, while `062-send_with_limit.c3` exists.
- **Three module names differ from their filename leaf.** A list must use the module name.
  - `061-…` is `shc::k_new_in_3tk::composite_outer_gives_back`.
  - `058-…` is `shc::k_new_in_3tk::identity_costs_nothing`.
  - `062-send_with_limit.c3` is `shc::f_mailbox::send_with_limit`, not in `k_`.
- **The 50 leaf examples** name no catalog entry. Two cite a number:
  `045` says *"from `018`"*.
- **`3tk-example-rules-006.md`** says a backticked token with `::` auto-links
  if it resolves. Measured for declarations on 2026-08-31. **Not measured for a
  module path.**

## Proposed rulings

- **R-1 — a module page describes the module, for a reader of the docs site.**
  No catalog, entry numbers, file numbers, or port history.
- **R-2 — a group page is a short intro, then one bullet per example.**
  - The bullet names the module path in backticks, then a short hook.
  - Example: `` `shc::a_slot_and_transfer::empty_slot` — a `Slot` starts empty. ``
- **R-3 — rules without code are stated as facts about the subject, or dropped.**
  - *"A `Slot` is never overwritten."* is a fact a reader can use. It stays, as a sentence.
  - *"Entry 2 has no file"* goes.
- **R-4 — *"This module holds no code of its own."* goes.** The page shows that.
- **R-5 — leaf examples refer to another example by module path**, never by number.
- **R-6 — the exemplar comes before the sweep** (rules-007 Rule 11).
  `a_slot_and_transfer.c3` first; owner confirms.
- **R-7 — `3tk-example-rules-006.md` is not changed.** The numbering stays in
  filenames and in the catalog. Only the source comments stop citing it.
  **If the owner wants the rules to forbid catalog references in comments**,
  that is `007`, written in the same stage.
- **R-8 — no code, no identifiers, no filenames change.** `k_new_in_3tk`
  keeps its name. Its description changes.

## The stage

| stage | what it does | model |
|---|---|---|
| **3TK-83** | **Module pages for the reader.** Probe the link; exemplar; sweep the 12 group files and the leaf cross-references. | **Opus 5** |

**Why Opus 5.** Rule 10: the group descriptions need new wording, with no
source to copy it from, and the exemplar binds the other ten.

### Steps — 3TK-83

**1. Probe the link.** Run `preview-docs.sh`. Put one backticked module path in
`a_slot_and_transfer.c3`. Check the generated page links it.
- If it links: backticked module paths, per R-2.
- If it does not: backticked module paths anyway, and say so in the log.
  Do not hunt for a workaround.

**2. Exemplar.** Rewrite `a_slot_and_transfer.c3` per R-1 … R-4.
**Stop and show it to the owner.**

**3. Sweep**, after the owner confirms.
- The other 10 group files.
- `shc.c3`: drop `NNN` and catalog text; list the groups by module path.
- Leaf cross-references by number (`045`).
- Re-check `outers.c3` and `helpers.c3` against R-1.

**4. Verify.** `c3c build`, `c3c test`, `check-doc-loop.sh`, `run-builds.sh`,
and code-unchanged by comparing each file with comments stripped.

**5. Log and status.** One log entry. Status: the row, and *No stage is queued*.

## What this stage does not do

- No git.
- No change to `src/`, code, identifiers or filenames.
- No change to `3tk-patterns-004.md` or its numbering.
- No copy to `matryoshka-3tk` — the owner's step.

## Open for the owner before the stage runs

- **R-3:** keep code-less rules as facts on the group page, or drop them all?
- **R-7:** should `3tk-example-rules-006.md` gain a rule against catalog
  references in comments?
- **`k_new_in_3tk`:** its subject is *"new compared to ztk"*. The description
  can only say what the examples show. The group name itself stays (R-8).

## How to start after a clear

**3TK-83 — Opus 5:**

```
Read design/secondary/lang/c3/3tk-status.md and
design/secondary/lang/c3/3tk-staging-plan-042.md.
Read matryoshka-3tk/design/3tk-rules-007.md,
matryoshka-3tk/design/3tk-example-rules-007.md
and design/rules-049.md Parts 4-6.
Git is disabled. Run 3TK-83.
```
