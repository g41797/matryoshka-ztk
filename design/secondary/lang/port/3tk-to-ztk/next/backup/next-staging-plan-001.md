# next — staging plan (001)

Written 2026-09-20, by the SETUP stage.

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
| **CORE** | `Inner`, `Outer`, the descriptor, the helper, the list. Implementation and tests. | Opus 5 |
| **MBOX** | The mailbox, with its rulings. Implementation and tests. | Opus 5 |
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

## CORE — the model

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

**Why Opus 5.** It is the whole model, and one of its open questions is still  
open.

---

## MBOX — the mailbox

**Contents.** MB2, MB3, MB4, MB5, MB10, MB12 and the unchanged `std.Io`  
surface.

**What comes across as it is.** The `std.Io` shape was ruled unchanged: the  
timeout form of `receive`, cancellation, `Result`, the future form, and  
`internal/cond_timeout.zig`. Copy them; do not rewrite them.

**What is new.** Every public call counts itself while it runs, and `destroy`  
refuses in every build unless the mailbox is closed and no call is inside it.  
`destroy` becomes a method and uses the allocator it already stores — which is  
why that field stops being dead. Two queues, out-of-band first, so no insert  
needs a reference item. `isClosed`, `isIdle` and `len` become public. A second  
send form takes a limit.

**The counter is designed here and copied to the pool.** That is why the mailbox  
comes first.

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

**One is open.** Five were answered on 2026-09-20, before CORE, and each was
checked against the sources rather than reasoned about.

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

### Open

6. **Whether the slot-releasing form of `destroy` survives.** Kept by the
   ruling with a re-think note, because it takes no allocator once `destroy` is  
   a method. Decided in CORE or MBOX, wherever its callers land. It blocks  
   neither.

Answered already, and not reopened by writing code: every ruling in  
[../3tk-to-ztk-005.md](../3tk-to-ztk-005.md) under **BKP 2 — the rulings**.

---

## How to continue after a clear

Each stage starts from a clear, reading these documents and nothing else at the
repo root but `design/rules-050.md`.

**CORE — Opus 5:**

```
Read design/secondary/lang/port/3tk-to-ztk/next/next-status.md in full,
then next-staging-plan-001.md beside it: the CORE charter, and the five
answers under Open questions.
Read design/secondary/lang/port/3tk-to-ztk/next/ztk/design/task1-tests-001.md
in full. It is what CORE is measured against.
Read The direction change and the BKP 2 rulings in
design/secondary/lang/port/3tk-to-ztk/3tk-to-ztk-005.md — IT1, IT3, IT4, IT5,
LS1, LS2, LS4, HP1, HP3, HP6, TK2, TK3 and the vocabulary ruling.
Read design/rules-050.md Part 0 and matryoshka-3tk/design/3tk-rules-007.md Part 2.

Sources are the truth: 3tk at design/secondary/lang/c3/3tk/src/ for the model,
the old ztk tree at the repo root for behaviour being kept.
The old tree is frozen. Read it, copy from it, do not edit it.
Git is disabled. Work only under
design/secondary/lang/port/3tk-to-ztk/next/ztk/.

Run CORE: the check helper, then OuterInfo and Inner, then the helper,
then the chain. One file at a time, its tests before the next begins.
Ask about the negative-test mechanism before writing any negative test.
Show intent before code. The gates are the five in next-status.md.
```

**What CORE already has, and must not re-decide.** The five answers in **Open
questions** above are closed: no handle type, `OuterId` and `OuterInfo`, and no
`finish`, `magic` or `size` field. `OuterInfo` has `name` and `inner_offset`. The
shape was compiled and run before it was written down — see **Checked before the
stage** in the CORE charter.

**The one thing CORE must ask first.** The negative scenarios, task1 300 to 313.
Zig has no standard way to assert a panic inside a test, and a compile-error case
needs a build step of its own. The old tree carries this as Open Item 11,
unresolved. CORE proposes a mechanism and gets a ruling before writing the first
one. The rest of CORE does not wait on it.

**The stage after CORE is MBOX, and it is not started by finishing CORE.** Stop
and ask.

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
