# 3tk — staging plan 044

Written 2026-09-17.

**Provenance.** Follows `043`, which is spent: the README closed on 2026-09-17.
**Only `3TK-50` remains from any earlier plan, and it waits on the owner.**

State is in [3tk-status.md](3tk-status.md). Narrative is in
[3tk-log.md](3tk-log.md). **The rules are
[matryoshka-3tk/design/3tk-rules-007.md](https://github.com/g41797/matryoshka-3tk/blob/main/design/3tk-rules-007.md)
and [design/rules-049.md](../../../rules-049.md) Parts 4-6.**

**Its input is
[matryoshka-3tk/design/3tk-inner-without-any-001.md](https://github.com/g41797/matryoshka-3tk/blob/main/design/3tk-inner-without-any-001.md)**
(INTR 12) and the debts in
[3tk-readme-creation-002.md](https://github.com/g41797/matryoshka-3tk/blob/main/design/3tk-readme-creation-002.md)'s
*What is open*.

**Git is disabled for every stage of this plan.**

---

## Why this plan exists

**`any` is a border type.** The owner ruled it out of 3tk's internals on
2026-09-16 (INTR 12).

- At the border, 3tk converts.
- It does not police what happens to an `any` on the C3 side.

**The conversions do not exist.**

- `OuterHelper.look` takes a `Slot*` or an `Inner*` (`helper.c3:87`).
- It never takes an `any`.
- `Slot.fill` takes an `Inner*`.

**The README already leans on them** — debt `D-1`:

- *How to start*, step 2:
    - send outers over `UnboundedChannel(<any>)`
    - on arrival, `look` checks what arrived
- *If you already have a channel*:
    - never cast
    - use `look`, `must_look`, `take`, `must_take`

**Today both need a cast of `a.ptr`.** The README forbids exactly that.

## The use case

**The HTTP side of the opening system.**

- It has no Mailbox.
- It listens on an `UnboundedChannel(<any>)`.
- It receives two kinds of thing on the same channel:
    - outers coming back from workers
    - io events
- It tells them apart by `a.type`.
- An io event:
    - it allocates an outer, or takes one from a Pool
- An outer:
    - it puts it in a Slot
    - it sends it on through a Mailbox

**Two directions.**

- **Outbound:** an outer in a Slot becomes an `any`, for a C3 container.
- **Inbound:** an `any` from a C3 container becomes an outer in a Slot.

**Facts INTR 12 left standing.**

- An outer keeps its stamp when it leaves.
    - So the inbound crossing can cross-check `a.type` against `otrtypeid`.
- The crossings are typed, on `OuterHelper`.
    - The outer's pointer is stored nowhere.
    - `inner_offset($Type)` is what finds it.

## The stages

| stage | what it does | model |
|---|---|---|
| **3TK-87** | **The subject document.** Measure; write `3tk-any-border-001.md`; put the questions to the owner. No `.c3` change. | **Opus 5** |
| **3TK-88** | **The surface.** The crossings in `helper.c3`; tests; negatives; `run-builds.sh`. | **Opus 5** |
| **3TK-89** | **The `l_` examples group.** The io border as the HTTP side does it; the group page; `shc.c3`. | **Opus 5** |
| **3TK-90** | **The README passages.** Step 2 and the channel section's rules name the real calls and the `l_` examples. Closes `D-1`, `D-2`. | **Sonnet 5** |

**Why Opus 5 for the first three.** Rule 10:

- `3TK-87` rules a new public surface.
- `3TK-88` builds it, and the negatives decide what the surface refuses.
- `3TK-89` writes examples, and examples teach.

**Why Sonnet 5 for the last.** It applies calls already built to two passages
already written.

### Steps — 3TK-87

**1. Measure.**

- Every crossing in `helper.c3` and `inner.c3`, with `file:line`.
- C3's `any`: how `.ptr` and `.type` are built and read.
    - `MANUAL.md` is the reference.
- `UnboundedChannel(<any>)`: `push`, `pop`, what it copies.

**2. Write `matryoshka-3tk/design/3tk-any-border-001.md`.**

- The use case.
- The measured facts.
- *What is decided*, *What is open*.
- Owner's step before creating a file there: this plan is the ask.

**3. Put the questions to the owner, each with options to choose from.**

- **Names.**
    - For example: `REQ.to_any(&slot)` and `REQ.from_any(a, &slot)`.
- **Outbound and the slot.**
    - Does making an `any` empty the slot, as `send` does?
    - Or only read it, as `look` does?
    - Or both, as a pair?
- **Inbound checks.**
    - `a.type` against `Outer*`.
    - `otrtypeid` against `Outer`.
    - On mismatch: null, as `look`; or abort, as `must_look`; or both, as a pair.
- **Which `any` is accepted.**
    - An `Outer*` only?
    - An `Inner*` as well?
- **An `any` that is not an outer.**
    - How does an io event pass through untouched?
    - Is there a plain predicate, such as `REQ.is(a)`?
- **The unstamped outer.**
    - Refused at the inbound crossing, as everywhere else?

**4. Show the document. Stop.** `3TK-88` starts from the answers.

**Ran 2026-09-17.** The answers are *What is decided* in
`matryoshka-3tk/design/3tk-any-border-001.md`. They changed the surface named
here: `any` is handled like a Slot, by address; `look`/`take` accept `any*`;
`is(from)` is new for every holder; the pair is `to_any`/`to_slot`.

### Steps — 3TK-88

- The crossings, in `helper.c3`, on `OuterHelper`.
- Contract in the doc block (Rule 1).
- Tests in `test/`.
- Negatives in `negative/`, at least:
    - an `any` of the wrong type
    - an unstamped outer
    - an `any` whose `.type` and `otrtypeid` disagree
- `run-builds.sh`, in both repos (Rule 12).
- `is` replaces `look` at the yes/no sites; `examples/010` off `internal::is_mine`.
- New versions (Rule 14): `3tk-api-007.md` → `008`, `3tk-reference-013.md` →
  `014` (repoint `check-doc-loop.sh`, `move-module-docs.sh`),
  `3tk-patterns-004.md` → `005`.

**Ran 2026-09-17.** Built as listed. `c3c test` 157; `run-builds.sh` 135/9, the same 9; five
`negative/any_*`; doc loop 170 of 170. `api-008`, `reference-014`, `patterns-005`.

### Steps — 3TK-89

- The `l_bridge` group. Named by the owner, 2026-09-17.
- One file per pattern.
    - A channel of `any` sending into a Mailbox.
    - Io events and outers told apart on one channel.
- The group page, and a line in `shc.c3`.
- `3tk-example-rules-007.md` applies.

**Ran 2026-09-17.** `shc::l_bridge`: `063-from_a_channel_to_a_mailbox.c3`,
`064-io_and_outers_share_a_channel.c3`, `l_bridge.c3`, a line in `shc.c3`, two wrappers.
`c3c test` 159; `run-builds.sh` 135/9, the same 9.

### Steps — 3TK-90

- *How to start*, step 2.
- *If you already have a channel*, the rules.
- Both name the real calls and the `l_` examples.
- Staccato, as the rest of the README.
- `3tk-readme-creation-002.md`: `D-1` and `D-2` closed.
- **The `fed` family is banned (Part 5), added by the owner 2026-09-17.**
    - Search the whole family: `feed`, `feeds`, `feeding`, `fed`. Not only the listed spelling.
    - Search file names and text: `src/`, `test/`, `negative/`, `examples/`, the scripts, `matryoshka-3tk/README.md`, `matryoshka-3tk/design/` outside `backup/`.
    - A plain `grep -w` misses identifiers: `_` is a word character, so an identifier such as `x_feeds_y` does not match. Treat `_` as a separator:
      `grep -rniE '(^|[^a-z])(feed(s|ing)?|fed)([^a-z]|$)'`, and `find -iname '*feed*'`.
    - Every known hit was fixed before `3TK-90`. Re-run live anyway.
    - Not a hit: the ban list in `check-doc-loop.sh` names `fed` to ban it.
    - The log is append-only and keeps the old name. Status and this plan name the new one.
    - `063` was renamed before `3TK-90`: `a_channel_feeds_a_mailbox` → `from_a_channel_to_a_mailbox`.

**Ran 2026-09-17, on Opus 5.** Both passages name `to_any`, `to_slot` and the `l_bridge` examples. `D-1`, `D-2` closed. `fed` family: 0 hits. `c3c test` 159; doc loop clean. **This plan is spent.**

---

## Verification

- `c3c build`, `c3c test` — green. The count grows by this plan's tests.
- `run-builds.sh` — the same 9 failures as before, plus the new negatives passing.
- `check-doc-loop.sh` — clean.
- Banned-word scan, run live.
- **Every README claim is greppable in `src/`** after `3TK-90`.

## What this plan does not do

- **No git**, at any stage.
- **No copy to `matryoshka-3tk/src/`** — the owner's step.
- **No module doc blocks** — debt `D-3`, its own plan.
- **No `any` inside the toolkit.** The crossings build and read one at the
  border and keep nothing.

## How to start after a clear

**3TK-87 — Opus 5:**

```
Read design/secondary/lang/c3/3tk-status.md and
design/secondary/lang/c3/3tk-staging-plan-044.md.
Read matryoshka-3tk/design/3tk-inner-without-any-001.md and
matryoshka-3tk/design/3tk-readme-creation-002.md — its "What is open".
Read matryoshka-3tk/design/3tk-rules-007.md
and design/rules-049.md Parts 4-6.
Git is disabled. Run 3TK-87.
```

**3TK-88 — Opus 5:**

```
Read design/secondary/lang/c3/3tk-status.md and
design/secondary/lang/c3/3tk-staging-plan-044.md.
Read matryoshka-3tk/design/3tk-any-border-001.md — its "What is decided"
and "What is open".
Read matryoshka-3tk/design/3tk-rules-007.md
and design/rules-049.md Parts 4-6.
Git is disabled. Run 3TK-88.
```

**3TK-89 — Opus 5:**

```
Read design/secondary/lang/c3/3tk-status.md and
design/secondary/lang/c3/3tk-staging-plan-044.md.
Read matryoshka-3tk/design/3tk-any-border-001.md — its "What is decided"
and "The shape in use".
Read matryoshka-3tk/design/3tk-example-rules-007.md
and matryoshka-3tk/design/3tk-rules-007.md
and design/rules-049.md Parts 4-6.
Git is disabled. Run 3TK-89.
```

**3TK-90 — Sonnet 5:**

```
Read design/secondary/lang/c3/3tk-status.md and
design/secondary/lang/c3/3tk-staging-plan-044.md.
Read matryoshka-3tk/README.md — "How to start" and "If you already have a channel".
Read matryoshka-3tk/design/3tk-readme-creation-002.md — its "What is open".
Read matryoshka-3tk/design/3tk-rules-007.md
and design/rules-049.md Parts 4-6.
Git is disabled. Run 3TK-90.
```
