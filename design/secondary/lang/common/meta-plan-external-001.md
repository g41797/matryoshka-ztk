Yes. At this stage I would make the document a **meta-plan**, not a comparison document.

It should tell Claude Code **how to reduce a large amount of existing Matryoshka material into a reliable comparison**, without prematurely deciding what should be ported from 3tk to ztk.


# Plan for ZTK / 3TK Alignment

## Purpose

ztk and 3tk are both working Matryoshka implementations.

3tk started from ztk, but it is no longer just a C3 port.

During its development, 3tk introduced:

- changed concepts
- changed APIs
- simplified interfaces
- new helpers
- different implementation choices
- ideas that may be useful for ztk
- ideas that are specific to C3

The final goal is to update ztk where the 3tk development produced improvements that should also exist in the Zig version.

Do not start that update yet.

The first task is to understand what actually changed and why.

This document defines the process for doing that.

---

# Phase 0 — Establish the baselines

Before comparing anything, identify the current state of both projects.

For each project record:

- repository path
- current branch
- current commit
- implementation status
- test status
- examples
- public API
- important design documents
- specification documents
- known unfinished work

Treat the current implementations as snapshots.

Do not modify either project during this phase.

The purpose is to make the later comparison reproducible.

---

# Phase 1 — Build the Matryoshka map

Do not read all documents linearly.

There is too much material.

First build a map of the system.

Identify the main concepts shared by the projects.

At minimum investigate:

- Inner / PolyNode
- Outer item
- type identification
- intrusive linking
- ItemHandle
- Slot
- Mailbox
- Pool
- Pool hooks
- allocation
- release
- close
- synchronization
- communication
- application-side usage
- infrastructure-side usage
- helpers
- managed allocation
- manual allocation
- error handling
- lifetime rules
- thread rules

This is a map, not a specification.

Do not try to resolve differences yet.

---

# Phase 2 — Find the authoritative sources

There are many Matryoshka documents.

Do not treat all documents as equally authoritative.

For each important concept determine:

1. current implementation
2. current specification
3. current design discussion
4. older documents
5. examples

Prefer sources in approximately this order:

1. current code and tests
2. current specification
3. current API documentation
4. current examples
5. recent design documents
6. historical discussions

Historical documents are useful for understanding why something changed.

They are not automatically evidence that the current design is still valid.

Record conflicting information instead of silently choosing one source.

---

# Phase 3 — Extract the 3tk changes

Now investigate 3tk as a development history.

For every significant difference from the original ztk design ask:

> Why does 3tk look this way?

Possible answers include:

- C3 language requirement
- C3 limitation
- C3 idiom
- implementation convenience
- API simplification
- bug discovered during development
- lifetime problem discovered
- concurrency problem discovered
- better abstraction
- better application ergonomics
- deliberate Matryoshka design change
- experiment
- unresolved choice

Do not assume that a change made in 3tk should be copied to ztk.

The purpose is to recover the reasoning.

---

# Phase 4 — Create a difference inventory

Create one compact inventory of significant differences.

Use this classification:

| Difference | ZTK | 3TK | Reason | Classification |
|---|---|---|---|---|
| ... | ... | ... | ... | ... |

Classification should be one of:

- `LANGUAGE`
- `3TK IMPROVEMENT`
- `3TK EXPERIMENT`
- `ZTК-SPECIFIC`
- `COMMON MODEL CHANGE`
- `UNCLEAR`

Do not use this table to decide the final ztk API.

It is only an inventory.

Focus on meaningful differences.

Do not record cosmetic differences or obvious C3/Zig syntax differences.

---

# Phase 5 — Separate language differences from design differences

This is one of the most important steps.

For every 3tk change ask:

> If C3 did not exist, would this change still make sense?

If no:

- classify it as `LANGUAGE`
- normally do not port it to ztk

If yes:

- investigate it as a possible Matryoshka design improvement

Examples of things that may be language-specific:

- C3 type syntax
- C3 generic syntax
- C3 module rules
- C3 `typeid`
- C3 nullable-pointer behavior
- C3 macro mechanisms

Examples of things that may represent real Matryoshka design changes:

- Slot semantics
- close semantics
- Pool lifecycle
- Mailbox API
- handle movement
- hook behavior
- lifetime rules
- synchronization rules
- application/infrastructure separation

Do not decide solely from the names.

Check the actual behavior.

---

# Phase 6 — Identify the common Matryoshka model

After the difference inventory, describe the model that appears to be common to both projects.

This should answer questions such as:

- What is an Inner?
- What is an Outer?
- What is a Slot?
- What does a handle represent?
- Who can hold a handle?
- What does sending do to a Slot?
- Who controls allocation?
- Who controls release?
- What does Pool provide?
- What does Mailbox provide?
- What does close mean?
- What does "closed and quiet" mean?
- What guarantees exist between threads?
- Which rules belong to Matryoshka itself?
- Which rules belong only to a particular implementation?

This is the most important result of the investigation.

It should describe the model independently of Zig and C3 where possible.

---

# Phase 7 — Review 3tk improvements against that model

Now ask:

> Which 3tk changes improve the common Matryoshka model?

For each candidate record:

- current ztk behavior
- current 3tk behavior
- problem with ztk behavior, if any
- benefit of 3tk behavior
- whether the difference is language-independent
- compatibility impact
- implementation impact
- documentation impact
- test impact

Do not yet implement the change.

Some differences may turn out to be improvements.

Some may turn out to be unnecessary for Zig.

Some may reveal that the common model itself needs clarification.

---

# Phase 8 — Identify unresolved questions

Create a separate list of questions that cannot be answered from the current material.

Examples:

- Is this API difference intentional?
- Was this change made because of C3?
- Is this behavior part of the common model?
- Is this old ztk behavior still wanted?
- Is the 3tk behavior an experiment?
- Does changing ztk break existing application code?
- Does the 3tk design expose a better lifetime rule?
- Are the two projects actually describing the same abstraction?

Do not fill gaps with assumptions.

These questions become the input for the next design discussion.

---

# Phase 9 — Produce the actual alignment proposal

Only after the previous phases create enough evidence, produce:

## ZTK changes proposed from 3TK

For every proposed change:

- current ztk
- proposed ztk
- reason
- source in 3tk
- compatibility impact
- required tests
- required documentation changes

Also create:

## 3TK changes NOT applicable to ZTK

Explain briefly why each is:

- language-specific
- implementation-specific
- experimental
- unnecessary in Zig

Also create:

## Common model changes

These are changes that should probably be reflected in the language-neutral Matryoshka documentation/specification before changing either implementation.

---

# Phase 10 — Update ztk

Only now modify ztk.

Do changes in small groups.

For each group:

1. update implementation
2. update tests
3. update examples
4. update API documentation
5. update relevant Matryoshka specification
6. run the complete ztk test suite
7. review the resulting API against 3tk

Do not blindly make ztk identical to 3tk.

The target is:

> Same Matryoshka model where appropriate, idiomatic implementation in each language.

---

# Important rules for the investigation

## Do not start from the documents

The repository contains too much historical material.

Start from:

- current code
- current tests
- current public APIs

Then use documents to explain them.

## Do not make 3tk the authority

3tk contains newer ideas, but "newer" does not automatically mean "correct for ztk".

The investigation must determine what is:

- a real Matryoshka improvement
- a C3-specific solution
- an experiment
- an accidental difference

## Do not make ztk the authority either

Some old ztk decisions may have been improved during 3tk development.

Be willing to change the common model if the evidence supports it.

## Do not optimize for identical APIs

Zig and C3 should remain idiomatic.

The goal is conceptual alignment, not textual API equality.

## Do not rewrite documentation during discovery

First understand the differences.

Then decide what the common model is.

Then update documentation.

## Preserve historical reasoning

When an old document explains why a design exists, keep that information available.

Do not let historical documents override current implementation behavior.

---

# Expected outputs

At the end of this process there should be a small set of useful documents rather than another large documentation tree.

### 1. Matryoshka map

A compact map of the current concepts.

### 2. Difference inventory

A factual list of significant ztk / 3tk differences.

### 3. Common model

The language-neutral model extracted from both implementations.

### 4. Alignment proposal

The concrete list of changes that should be made to ztk.

### 5. Open questions

Questions requiring human design decisions.

---

# Working method for Claude Code

Work incrementally.

Do not attempt to read every Matryoshka document in one pass.

Start by inspecting both repositories.

Then identify:

- source directories
- tests
- examples
- public API
- specification directories
- design directories
- README files

Search before reading large documents.

Follow references only when they are relevant to a concept being investigated.

When a document conflicts with current code, report the conflict.

Do not silently resolve it.

Keep notes in the repository so that the investigation itself is reviewable.

Do not modify implementation code until the alignment proposal is approved.

---

# First task

Do only the following first:

1. Inspect the local ztk repository.
2. Inspect the local 3tk repository.
3. Identify their current implementation, tests, examples, and documentation structure.
4. Find the main sources describing the current Matryoshka model.
5. Produce a short initial `Matryoshka Map`.
6. Produce a list of documents that appear authoritative.
7. Produce a list of obvious major differences between ztk and 3tk.
8. Do not propose code changes yet.
9. Do not modify either project.

The result of this first task should be small enough for a human to review.

After that review, continue with the difference inventory.

