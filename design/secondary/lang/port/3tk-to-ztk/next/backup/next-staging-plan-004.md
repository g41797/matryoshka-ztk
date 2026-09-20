# next — staging plan (004)

Written 2026-09-20, by the SETUP stage. This is 004, by MBOX, 2026-09-20.

Change from 003, after MBOX: the MBOX charter is marked done and carries what
the stage decided — `close` and `receiveAll` return a `Queue` by value under
MB9, `Queue.countOfId` for the send limit, `isIdle` public against `destroy`,
and the slot-releasing `destroy` dropped. Question 11 is answered and moves
under **Answered**, so **no question is open**. The continue prompt is POOL.
003 is in `backup/`.

Change from 002, after CORE: the CORE charter is marked done and carries what
the stage decided — the std node in `Inner`, the name `Queue`, the std list as a
per-item border, and the negative mechanism. Five more questions are answered
and moved under **Answered**, the last of them the owner's confirmation that  
`no_create_destroy` is gone. One question is still open. The
continue prompt is MBOX. 002 is in `backup/`.

Change from 001, after SPEC: the five design questions are answered and recorded
under **Open questions** — no handle type, `OuterId` and `OuterInfo`, and no
`finish`, `magic` or `size` field. The CORE charter gains **Checked before the
stage**, the record of the shape being compiled and run before it was written
down, and reads `OuterInfo` throughout. New section **How to continue after a
clear**, with the CORE prompt.

**A gap in the record, stated rather than hidden.** SPEC made those changes by
editing 001 in place, against the rule that a document is never overwritten. So
the copy of 001 in `backup/` is the post-SPEC text, not the text SETUP wrote.
That earlier text is not recoverable — there is no git here. The same failure is
on record once before, in the old tree, where plan -069 was deleted against the
rule. `check_next_docs.sh` has a fourth check so the gate catches it next time
instead of the owner.

The stage menu for the rewritten toolkit. State lives in  
[next-status.md](next-status.md); the narrative in [next-log.md](next-log.md);  
the rulings in [../3tk-to-ztk-005.md](../3tk-to-ztk-005.md).

**A stage is a menu entry, not a queue.** Finishing one does not roll into the  
next. Stop and ask. A heading that reads like an ordering is not an instruction  
to start.

---

## The order, and why it is this one

Three layers, each finished before the next begins: the **core**, then the  
**mailbox**, then the **pool**. It is the old tree's own order and the  
dependency order of the code.

Two decisions about the shape of the work, both from the direction change:

- **The core is one stage, not three.** The old arrangement split identity, the
  list and the helper into separate groups. They are one model: the descriptor  
  holds the offset the helper computes, the list's checks read the descriptor,  
  and the helper's `init` fills a field the descriptor declares. Split, the file  
  gets written three times.
- **A container arrives carrying its own rulings.** The mailbox is written once,
  with the call counter, the method form of `destroy`, the queries and the  
  ordering it was ruled to have. Reproducing the old mailbox first and ruling it  
  afterwards is the mistake this tree exists to avoid.

Examples are last of the code stages. The build has no examples module until  
then, which is what keeps a stage's tests from depending on them.

---

## Stages

| stage | what it does | model |
|---|---|---|
| **SETUP** | The tree, the build, the scripts, the gate, these three documents. No toolkit code. DONE 2026-09-20. | Opus 5 |
| **SPEC** | The test scenarios for this model, in `ztk/design/`. No code. | Opus 5 |
| **CORE** | `Inner`, `Outer`, the descriptor, the helper, the queue. Implementation and tests. DONE 2026-09-20. | Opus 5 |
| **MBOX** | The mailbox, with its rulings. Implementation and tests. DONE 2026-09-20. | Opus 5 |
| **POOL** | The pool, with its rulings. Implementation and tests. | Opus 5 |
| **EXAMPLES** | The examples module, and the examples ported from the old tree. | Sonnet 5 |
| **DOCS** | The API reference and the concept pages, written from the finished code. | Opus 5 |
| **PROMOTE** | The tree is copied to the repo root and the old one is deleted. Owner's action. | — |

Each stage ends green in all five gates listed in  
[next-status.md](next-status.md), and ends by naming the model the next one  
wants and whether to clear or compact.

---

## SETUP — done

The folder, `build.zig`, `build.zig.zon`, an empty module root, one test, the  
three kitchen scripts, the documents gate, and these three documents.

Verified: four optimization modes 1/1, cross-compile for three targets,  
`zig fmt --check` clean, `check_next_docs.sh` at exit 0.

---

## SPEC — the test scenarios

**Where to start.** `design/task1-tests-008.md` and `design/task2-tests-004.md`  
in the old tree. They are scenario lists, not code, so most of them port by  
meaning. Output: two files in `ztk/design/`, task1-tests and task2-tests at  
-001, keeping the old scenario numbers so a scenario can be traced back.

**What dies, and why.** Each traces to a ruling, so none of this is a judgment  
call:

- task1 102, and the iterator half of 103 — the removed list operations.
- task1 106 to 110 — the same.
- task1 42 — the walk of a plain std list, which the new list does not cross to.
- task1 82 — the batch put is removed; the caller writes the loop.
- task1 6 — the two-level cast chain. One link now, and the field is found by
  type.
- task1 1 to 5 survive but change shape: identity is a descriptor pointer, and
  scenario 2's by-hand stamp is what the helper-only ruling forbids.

**What is added.** Each of these is a ruling with no scenario behind it today:

- An item that was never stamped is refused at every crossing, in safe builds.
- The link test sees a chain of one. The old test could not.
- A call still running blocks `destroy`, in every build.
- The close hook is called more than once, possibly at the same time, and must
  survive it.
- The get hook is reached only when nothing is stored, so its slot is always
  empty.
- An identity the pool never registered is an error return, not an assert.
- The border pair between a slot and a bare handle, with its four checks.
- One check helper, compiled out where runtime safety is off, and a negative
  test in both directions for it.

**Why Opus 5.** It decides what is tested. Everything downstream is measured  
against it.

---

## CORE — done

**Contents.** The rulings IT1, IT3, IT4, IT5, LS1, LS2, HP1, HP3, HP6, TK2, TK3  
and the vocabulary ruling, together. Read them in  
[../3tk-to-ztk-005.md](../3tk-to-ztk-005.md) before writing anything.

**What it is.** An outer's id is `OuterId`, a pointer to its one `OuterInfo`,  
which holds the type's name and the offset of its inner field. The inner is  
singly linked, and the last of a chain points at itself, so the link test is  
exact and costs one compare. The helper finds the inner field by type, so its name is free.  
`create` calls the item's own `init` and frees it again if that fails. The list  
keeps the operations a real behaviour needs and no others, and its length is a  
stored count.

**Order inside the stage.** The check helper first, because every other piece  
adds checks written with it. Then `OuterInfo` and the inner. Then the helper.  
Then the list. One file at a time, with the tests for each before the next  
begins.

**The rule that governs it.** The exemplar before the rest: write the new check  
and one item type, watch the check fail on everything not yet converted, then  
convert. A check that has never been seen to fail has not been tested — so each  
one is broken deliberately, both ways, before it is trusted.

**Checked before the stage, 2026-09-20.** The descriptor was compiled and run  
before it was written down, not reasoned about. What holds:

- The inner field is found by type through `@typeInfo`, its name is used in
  `@fieldParentPtr`, and `@offsetOf` gives the offset. Two types with  
  differently-named inner fields, neither called `inner`, and a field ahead of  
  the inner so the offset is not zero.
- Zero inner fields and two inner fields are both compile errors, with the
  message naming the type.
- The step back with no type at comptime — the inner's address minus the
  descriptor's offset — agrees with `@fieldParentPtr`.
- The unstamped descriptor reads as its name, and its zero offset yields the
  inner's own address.
- All four optimization modes.

**And one correction to make in the stage.** The descriptor static is `const`,  
not `var`. Distinct types get distinct descriptor addresses even when the  
contents are byte-identical — measured in all four modes — and `const` puts the  
descriptor in read-only memory, where something that must never be written  
belongs.

That is a measurement, not a language guarantee, and identity is pointer  
equality. So task1 scenario 1 — *two different types produce different  
identities* — is load-bearing rather than a formality, and it stays in the suite  
for that reason.

**What the stage decided, on the owner's rulings of the same day.**

- The inner embeds `std.SinglyLinkedList.Node`. IT1 stands over IT5's
  hand-written field. `@sizeOf(Inner)` is 16 either way, measured in all four  
  modes, and the std node lets an outer go onto a plain `std.SinglyLinkedList`.
- The chain type is `Queue`. Append at the tail, pop at the head, first in first
  out — the behaviour names the type. "Chain" stays the prose word for the  
  linkage.
- The std list is a **border, not a second home**: per-item crossing through
  `takeFromSlot` and `fillSlot`, and no bulk conversion. LS1 and LS3 removed  
  `moveFromList` and `moveToList`, and nothing brings them back.
- The facts a caller gets wrong silently are stated as MUST doc comments on the
  declarations. `rules-050.md` is not touched; it gets its version at DOCS.
- `no_create_destroy` is not ported. Zig analyses a generic struct's
  declarations lazily, so a container that never calls `create` never reaches  
  the requirement for `init`. The old tree's duplicated second struct body is  
  gone with it.

**The negative mechanism, decided here.** Two halves, and a new build step,  
`zig build negative`:

- `negative/compile/` — programs that must fail to compile, checked against the
  message. Scenarios 306 to 309.
- `negative/panic/` — programs that must die, run and checked for an abort.
  Scenarios 300 to 305.
- A `check`-based case is built in Debug and ReleaseSafe only. Scenario 301 is a
  `@panic`, not a `check`, and it runs in all four.

**Why Opus 5.** It was the whole model, and one of its questions was still  
open.

---

## MBOX — done

**Contents.** MB2, MB3, MB4, MB5, MB10, MB12 and the unchanged `std.Io`
surface.

**What came across as it is.** `internal/cond_timeout.zig`, copied
byte-for-byte — it imports `std` and names no toolkit type, so the vocabulary
rename passes over it and it has nothing to re-point. With it: the `?u64`
timeout, cancellation, `Result`, the future form, and the deadline anchored
once before the retry loop.

**What is new.** Every public call counts itself in `_active` while it runs.
`destroy` is a method, uses the stored allocator, and refuses in **every**
build unless the mailbox is closed and no call is inside it. Two queues,
out-of-band first, so nothing is inserted into the middle of a chain and
`oob_count`, `oob_last` and `insertAfter` are all gone. `isClosed`, `isIdle`
and `len` are public. `sendLimited` is the second send form.

**What the stage decided, on the owner's rulings of the same day.**

- **`close` and `receiveAll` hand a `Queue` back by value**, rather than
  filling an out-parameter. MB9 already ruled that returning a value is
  natural in Zig; the out-parameter was 3tk's shape. A `Queue` value holds no
  pointer into itself — the self-pointing last link points at the item's own
  node — so it survives being returned. `close` cannot fail; `receiveAll`
  keeps `error{Closed}`.
  - **A queue value is moved, never copied.** Two copies over one chain are
    two owners of every outer on it. Stated as a MUST on `Queue` and on both
    calls.
  - This corrected `next-status.md`, which said a queue comes out as an
    out-parameter and that calls accumulate. That sentence was CORE's own and
    was out of step with MB9. Fixed in place, and the log names the
    correction rather than letting it pass.
- **`Queue.countOfId(id, stop_at)`**, added to `queue.zig`, feeds the send
  limit. MB5 counts the sender's own type among the queued outers and LS1
  removed the iterator, so the walk stays inside the queue and what a caller
  gets is a number. It stops at the limit rather than counting the whole
  chain. Not an iterator, and it does not become one.
- **`isIdle` is public**, and documented against `destroy` rather than as a
  general query. The usage evidence says it is test scaffolding — six call
  sites in 3tk, all in its own tests, while `is_closed` has real example
  callers. What makes it public is that `destroy` aborts when its
  precondition is wrong, so without `isIdle` there is no way to ask whether
  freeing is allowed yet other than to try it and be right.
  - MUST: it takes the mutex, so it is never called from inside a call on the
    same mailbox. `isClosed` answers the other half and takes no lock.
- **The slot-releasing `destroy` is dropped.** Question 11, closed. Its only
  reason to exist was that the old `destroy` needed an allocator passed in,
  and a method does not. `moveFromSlot` plus `mbx.destroy()` is two lines.
- **`condition_waitTimeout` keeps its name**, against MB11's camelCase rename.
  It is internal, unreachable from the module root, and its name mirrors the
  `Condition.waitTimeout` method it stands in for — which is the join where
  it disappears when ziglang/zig#31278 lands. Byte-for-byte won.

**The negative programs.** 310 and 312 joined the six from CORE, and both run
in **all four modes**, because `destroy` aborts with `std.debug.panic` and not
with `check`. 312's ordering was measured, not assumed — 200 runs, 200
aborts — and its header says so.

**The gate's banned-word list met the std mutex's releasing method.** Kept by
the owner's ruling, 2026-09-20, confirming what MBOX wrote. The
banned word is the AI-ish verb — *the potential of* — and a std method name
that a mailbox both calls and cannot rename happens to be spelled the same.
`check_next_docs.sh` now skips that literal method call, the same kind of
exception the script already carries for `@fieldParentPtr`; the skipped string
is written out in the script and deliberately not repeated here, because the
word on its own in prose is still a hit. The gate was seen to bite, on this
word and two others, before it was trusted.

**The counter is designed here and copied to the pool.** That is why the
mailbox came first. The shape: `self._active += 1;` with
`defer self._active -= 1;`, both under the mutex, in every public call.

**Why Opus 5.** It carried a ruling still being decided and designed the
counter everything downstream copies.

---

## POOL — the pool

**Contents.** PL1, PL2, PL3, PL4, PL6, PL7, PL8 and the narrowed error sets.

**The two that matter most.** A put that is still running when the pool closes  
gives everything it still has to the close hook, so no item is lost — which  
means the hook can be called a second time, at the same time as the first, and  
its own documentation must say so. And the get hook is reached only when nothing  
is stored, so its slot is always empty; the capped hook and the recycling hook  
both move their work to the put hook.

**The rest.** The identities are a separate argument, and a duplicate or an  
empty set is refused. An identity the pool never registered is an error return.  
The close hook takes the list by value. The batch put is gone. `isClosed`,  
`isIdle` and a per-identity count become public.

**The largest stage.** The close-on-put path depends on the counter from MBOX  
and on the by-value list.

---

## EXAMPLES — the usage evidence

The examples module enters the build here and not before.

**Where to start.** `design/task1-examples-006.md` and  
`design/task2-examples-007.md` in the old tree, and the 87 files they describe.  
The pairing table in [../3tk-to-ztk-005.md](../3tk-to-ztk-005.md) says which  
scenario each one shows and which have no counterpart in the other toolkit.

**What is added.** The rulings named examples that no toolkit has yet: the  
border pair, a refused put, a refused send, an infrastructure wrapper, a  
composite item giving its parts back, and a send with a limit.

**What is dropped.** The four that use the removed batch put, and the ones that  
reach into a plain std list.

**Why Sonnet 5.** The model is decided by then, the examples are many, and a  
build says when one is wrong.

---

## DOCS — the reference

Written from the finished code, once, rather than kept true against two models  
while they both exist.

The old tree's api reference is a book of seven parts and its shape is worth  
keeping. Its content is measured against the new code line by line, and every  
snippet is extracted from a file the build already compiles.

The glossary check that the old gate runs is tied to the old words. This tree's  
gate already defends the new ones, so what DOCS adds is the glossary itself.

---

## PROMOTE — the switch

The owner's action, not a session's.

`next/ztk/` is copied to the repo root and the old `src/`, `tests/`,  
`examples/`, `stories/` are deleted. `design/` at the root is replaced by what  
DOCS wrote. The three documents of this tree become the root `STATUS.md`, plan  
and log, or are folded into them.

Nothing in `next/ztk/` names a path above itself, which is what makes the copy a  
copy.

---

## Open questions

**None is open.** Five were answered on 2026-09-20 before CORE, five more by
CORE itself, and the last by MBOX. Each was checked against the sources rather
than reasoned about.

### Answered

1. **The handle type: there is none.** The new tree writes `*Inner` in every
   signature, and `Slot = ?*Inner`.

   3tk has no alias for the item pointer — checked in its sources. Every  
   signature says `Inner*`: `InnerQueue.push_back(&self, Inner* inner)`,  
   `fn Inner* InnerQueue.pop_front(&self)`, `to_inner`, `of`. The one typedef  
   over that pointer is `Slot = Inner*`. The word "handle" in 3tk names something  
   else — the opaque `Mailbox` and `Pool` typedefs, which ztk does not have at  
   all since it exposes `*Mbox` and `*Pool` directly.

   So the old `ItemHandle` was ztk's own invention, and not a language or std  
   difference, so the standing rule retires it. The idea behind it — *keep it,  
   send it, do not look inside* against *open it here* — was never enforced by the  
   compiler, because both spellings are one type. It survives as a doc comment on  
   `Inner`, which is where it belongs.

2. **The type is `OuterId`, and the struct is `OuterInfo`. Not `Identity`.**

   "Identity" is already the role word in this toolkit, and it is load-bearing.  
   The api reference says *the tag is the identity*, and it splits the word two  
   ways on purpose: **class** identity, which is what a tag answers, against  
   **instance** identity, which is `received == worker_mbx`. Taking the word for  
   the type collapses the role into the thing, and takes the umbrella word for one  
   branch — the wrong one, because a bare `Identity` in a signature reads as *which  
   one* when it means *what kind*.

   3tk does not use the word either. Its field is `otrtypeid`, its reader is  
   `outer_tid()`, and its type is C3's own `typeid`. It says **outer type id** in  
   full, and keeps "identity" for prose. Zig has no `typeid`, so the spelling is  
   ztk's to choose, and `OuterId` is the shortest one that stays true to that.

   `Info` rather than `Desc` or `Meta`, from Zig's own usage: `Info` is the  
   suffix on 19 type declarations in std, `Desc` on one, `Meta` on none. And  
   "descriptor" is already taken by something this toolkit is about — the pool's  
   own documentation warns about leaking file descriptors. `OuterDesc` came from  
   otk's `TypeDesc`, which is Odin advice, not a Matryoshka decision. The helper  
   reads `@typeInfo` to build an `OuterInfo`, which is the same word twice on  
   purpose.

   So "identity" goes back to prose, with both its branches, and the glossary  
   gains an entry for each — it has neither today, which is how this nearly went  
   through unnoticed.

3. **`finish` is not a field of `OuterInfo`.** `finish` the method is HP1 and is
   ruled: every outer declares `init(alloc)` and `finish(alloc)`, an empty body is  
   fine, and both are required at compile time. The *field* is a different thing —  
   a type-erased pointer to that method — and it buys exactly one capability:  
   releasing an item whose type the caller does not know.

   Nothing needs it. Checked in both trees: the only place an item is freed is  
   inside the helper, where the type is known at comptime — `polynode.zig:237` in  
   ztk, `helper.c3:101` and `:123` in 3tk. Every other free is a container freeing  
   itself.

   And it is not a convenience but a model change. It contradicts the sentence the  
   old tree worked to arrive at — *the mailbox keeps items, it never touches them,  
   so releasing them is the caller's job* — and it reopens what PL3 and PL4 just  
   decided about who is responsible for the items the close hook is handed.

   Deferring costs nothing: an `OuterInfo` is built by the helper and only by the  
   helper, so a later field touches one comptime function and no user code.

4. **`magic` is not reserved.** Same reasoning, less at stake. It was reserved for
   a C boundary that has no caller.

5. **`size` is not a field either.** Its only prospective reader was the
   type-erased release that `finish` was for, so the two stand or fall together.  
   In otk, where it came from, it is illustrative — `fmt.println(desc.name,  
   desc.size)` — and otk has no caller for it.

   The fact that decides it: `std.mem.Allocator.rawFree` takes the memory **and  
   the alignment**. So the reserved set — `name`, `size`, `inner_offset`, `finish`  
   — would not have been enough for the capability it was reserved for. Reserving  
   fields for an unbuilt feature got the set wrong, which is the argument for  
   deciding this when a caller exists.

   `name` stays, and not speculatively: a wrong-type panic names both types  
   instead of today's *the item is of another type*, and an unstamped item prints  
   `<unstamped>`.

So `OuterInfo` has two fields, `name` and `inner_offset`.

6. **The inner embeds `std.SinglyLinkedList.Node`.** Owner's ruling, and IT1
   stands over IT5 on this point. An outer may go onto a plain  
   `std.SinglyLinkedList`, at no cost in size.

7. **The chain type is `Queue`.** The behaviour names the type.

8. **The std list is a border, not a second home.** Per-item crossing only.
   Bulk conversion stays removed.

9. **The negative mechanism.** A build step for the compile-error cases, run
   programs for the panic cases.

10. **`no_create_destroy` is gone, and nothing replaces it.** Owner's ruling,
   2026-09-20, confirming what CORE wrote. Zig analyses a generic struct's  
   declarations lazily, so a container that never calls `create` never reaches  
   the requirement for `init`, and the old tree's duplicated second struct body  
   has no reason to exist. Scenario 253's promise holds by that mechanism  
   instead: `FakeMbox` has no hooks, has an id and every crossing, and asking  
   it for `create` does not compile.

11. **The slot-releasing form of `destroy` does not survive.** Owner's
   ruling, 2026-09-20, in MBOX, where its callers landed. MB2 kept it with a
   re-think note, and the re-think is this: its only reason to exist was that
   the old free-function `destroy` needed an allocator passed in. A method
   does not, so what it saved is one line. `Mbox.moveFromSlot(&slot)` then
   `mbx.destroy()` says the same thing and says it out loud.

   The pool follows it at POOL. Nothing replaces either.

Answered already, and not reopened by writing code: every ruling in  
[../3tk-to-ztk-005.md](../3tk-to-ztk-005.md) under **BKP 2 — the rulings**.

---

## How to continue after a clear

Three lines. `next-status.md` carries the reading list under **Start here —
every session**, so a prompt that repeats it is a copy that goes stale.

**POOL:**

```
Read design/secondary/lang/port/3tk-to-ztk/next/next-status.md and follow
Start here.
Run POOL. Opus 5.
```

Every later stage is the same three lines with its own name and model. The
models are in the stage table above.

**What POOL must not re-decide.** The eleven answers in **Open questions** are
closed, and so are CORE and MBOX: the inner, the id, the queue, the helper and
the whole mailbox are written and green. A pool is built on them, not beside
them.

**What POOL inherits.** The call counter, designed in MBOX and copied as it
is: `self._active += 1;` with `defer self._active -= 1;`, both under the
mutex, in every public call, and a `destroy` that aborts in every build unless
closed and quiet. `isClosed`, `isIdle` and the query shape copy with it, and
`isIdle` carries the same mutex MUST — which matters more for the pool,
because a hook is caller code running inside a call, and a hook that asks
`isIdle` deadlocks.

Also inherited: a container's close hands its items back **by value**, the way
`Mbox.close` does. PL4 already ruled the close hook takes the list by value,
so the two agree.

**What POOL decides.** Nothing carried over. Its own rulings — PL1, PL2, PL3,
PL4, PL6, PL7, PL8 — and the close-on-put path, which is the largest single
piece left in the tree.

**POOL is not started by finishing MBOX.** Stop and ask.

---

## What this tree does not do

- It does not reopen the rulings. A ruling is reopened in the subject document,
  by the owner.
- It does not touch the old tree. See **The old tree is frozen** in
  [next-status.md](next-status.md).
- It does not carry the old tree's waiting work. That list is in
  `design/STATUS.md` and is the old tree's business. Two of its items — the  
  intrusive-node audit and the formatting line — are answered by this tree  
  existing.
