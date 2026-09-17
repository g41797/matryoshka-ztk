# 3tk — staging plan 043

Written 2026-09-16.

**Spent, 2026-09-17.** `3TK-84`, `3TK-85`, `3TK-86` and four owner revisions ran;
the README is finished. What it left is in the subject document's *What is
open* and in [3tk-staging-plan-044.md](3tk-staging-plan-044.md).

**Provenance.** Follows `042`, which is spent: `3TK-83` closed on 2026-09-15.
**Only `3TK-50` remains from any earlier plan, and it waits on the owner.**

State is in [3tk-status.md](3tk-status.md). Narrative is in
[3tk-log.md](3tk-log.md). **The rules are
[matryoshka-3tk/design/3tk-rules-007.md](https://github.com/g41797/matryoshka-3tk/blob/main/design/3tk-rules-007.md)
and [design/rules-049.md](../../../rules-049.md) Parts 4-6.**

**The subject document of this plan is
[matryoshka-3tk/design/3tk-readme-creation-002.md](https://github.com/g41797/matryoshka-3tk/blob/main/design/3tk-readme-creation-002.md).**
It holds the detail. This plan holds the stages.

**Git is disabled for every stage of this plan.**

---

## Why this plan exists

**`matryoshka-3tk/README.md` has a logo and four badges and no content.**

Two drafts exist. **The owner rejected both.**

- The **first** is a tour of the toolkit from the inside out. Its headings are
  Matryoshka nouns. The reader meets `Inner` in paragraph two and is never told
  what problem it answers. **It states no problem at all.**
- The **second** puts the problem first and the terms last. That order is right.
  It is input, not a base to polish.

**The owner's words: no one needs `Inner` and `Outer`. Everyone needs solutions
to well-known problems of boring systems.**

**Both drafts are wrong about `src/`.** Six errors, measured 2026-09-16 and
written out in the subject document with their `file:line`.

## The reader

**The one [why-boring.md](../../../../kitchen/docs/addendums/why-boring.md)
describes.** He thinks in `Customer`, `Order`, `Invoice`, `Payment`. Sockets are
not his business. He wants to understand an architecture in a week, and to add a
feature in five years without rewriting how the system runs.

**He is not shopping for a framework.** A feature list tells him nothing.

## Two tiers

**The owner's shape, carried over from the odin version: a base document and a
deep dive.**

- **Base — the README.** 10,000 m. Not a design document. **Nobody reads more
  than a few hundred lines of a README.**
- **Deep dive — per module.** The detail that does not fit, split by subject.

**The deep dive is the module's `<* *>` doc block, not a separate document.**
`docs.yml` runs `docgen` over `src`, so each module already has a published
page, and **that page is the only version of this text a docs-site reader ever
sees.** A separate `.md` would be a second copy that drifts.

**The module blocks are a later plan.** This plan writes the README. The subject
document is the bridge: it is written so a later plan, with no memory of this
work, can write the six blocks from what it holds.

## The required order

**The owner's. The README follows it and does not reorder it.**

```text
   ordinary background process
              |
              v
   threads with responsibilities that must exchange work
              |
              v
   communication is the center  --------->  mailbox
              |
              v
   transfer must not allocate  ----------->  intrusive
              |
              v
   infrastructure must not know
   application types  -------------------->  type erasure
              |
              v
   some structs cannot be copied,
   so the object stays at its address
              |
              v
   where do objects come from  ----------->  pool
              |
              v
   reuse needs policy  ------------------->  hooks
              |
              v
   only then: the Matryoshka model, by name
```

**ASCII diagrams of real systems come before any Matryoshka term appears.**

## Voice and size

- No AI-sh words. No smart words. No advertising. No pathos.
- Staccato, `rules-049.md` Part 6. Part 5's banned list applies.
- **Not a feature list.** A description of systems built on Matryoshka: which
  problem, and how it is solved.
- **200 lines of prose aimed at, ~300 the ceiling. Diagram lines do not count.**
  Fenced blocks are outside the budget.
- **Nothing is said in both tiers.** A section that cannot earn its lines in the
  README is deep-dive material.

---

## The stages

| stage | what it does | model |
|---|---|---|
| **3TK-84** | **The subject document.** Measure `src/`, write `3tk-readme-creation-002.md`. No README prose. | **Opus 5** |
| **3TK-85** | **The problem half.** Everything before the first Matryoshka term. Stop and show the owner. | **Opus 5** |
| **3TK-86 …** | **The solution half, then revisions.** One stage per iteration. | **Opus 5** |

**Why Opus 5 throughout.** Rule 10: every stage writes prose with no source to
copy from, and that prose binds the later doc-comment plan. **None of it is a
mechanical sweep against a settled rule.**

### Steps — 3TK-84

**1. Measure `src/`.** All six files. Every fact carries its `file:line`.

**2. Write the subject document** in `matryoshka-3tk/design/`. It carries the
reader, the required order, the voice, the two tiers, the size budget, both
rejections with citations, the measured inventory, the sources and their
standing, *What is decided*, *What is open*, and the module mapping table.

**3. Put the two open questions to the owner, with something to choose from.**

**4. Show the document. Stop.** `3TK-85` starts from the answers.

### Steps — 3TK-85

**1. Read** the subject document's *decided* and *open* sections first.

**2. Write the problem half of `README.md`** — up to but not including the first
Matryoshka term.

**3. Stop and show the owner.** **The voice is ruled here**, before any solution
text exists. Rule 11's exemplar-before-sweep, applied to prose.

**4. Update** the subject document.

### Steps — 3TK-86 and after

One iteration per stage. Read the subject document, write or revise a part of
the README against the required order, update *decided* / *open* and the mapping
table, stop.

---

## Verification

**No `.c3` file changes in this plan**, so the code gates prove that, not the
work.

- `c3c build`, `c3c test` — green, 148 tests.
- `check-doc-loop.sh` — unchanged from its last measured state.
- `run-builds.sh` — 114 passed, 9 failed, **the same 9**.
- **Every factual claim in the README is greppable in `src/`.** The check is
  reading the cited line, not remembering it.
- Banned-word scan, run live at the moment of the claim.
- The README renders on GitHub: blank line before every list, no soft-break
  hazards.
- **The prose budget**, counted with fenced blocks excluded.

## What this plan does not do

- **No git**, at any stage.
- **No `.c3` change.** No code, no identifiers, no filenames.
- **No module doc comments.** Its own plan, once the README is agreed. It
  carries the `3tk-reference-013.md` re-sync and the `check-doc-loop.sh` budget
  with it.
- **No copy to `matryoshka-3tk/src/`** — the owner's step, and nothing here
  needs it.
- **No change to `3tk-patterns-004.md`, `3tk-example-rules-007.md` or the
  examples tree.**

## Open for the owner — all closed 2026-09-16

**The work is iterative, and a question is put when there is something measured
to answer it with.** `3TK-84` brought three and the owner closed all three the
same day. **Nothing is open. The detail is in the subject document, not here.**

- **Which system the README opens with** — handlers, a shared mailbox, workers,
  from the HTTP starter. The transcoder and the print server are out.
- **How much C3 the README shows** — **one block and one note**: the outer
  struct, and that the outer's address is found from the inner's.
- **Whether a second reader gets his own section** — **yes**, a closing section
  for the reader who already has his I/O, carrying a note on what the mailbox
  adds. **The README does not open on the channel.**

**Two rulings arrived after the plan was written and bind its later stages.**

- **The mailbox is not the price of entry.** `Inner` + `Outer` + `Pool`, and
  even `Inner` + `Outer` alone with the reader's own container, are supported
  shapes. Ten examples already use neither mailbox nor pool.
- **INTR 12 changed `Inner`** to two named fields on 2026-09-16. The README's
  one code block shows that shape.

## How to start after a clear

**3TK-85 — Opus 5:**

```
Read design/secondary/lang/c3/3tk-status.md and
design/secondary/lang/c3/3tk-staging-plan-043.md.
Read matryoshka-3tk/design/3tk-readme-creation-002.md — its
"What is decided" and "What is open" sections first.
Read matryoshka-3tk/design/3tk-rules-007.md
and design/rules-049.md Parts 4-6.
Git is disabled. Run 3TK-85.
```
