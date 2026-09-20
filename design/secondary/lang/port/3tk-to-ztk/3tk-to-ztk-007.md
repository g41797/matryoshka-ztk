# 3tk to ztk — the backport (007)

Written 2026-09-19, stage BKP 1. This is 007, written 2026-09-20 at SURFACE.

Change from 006, 2026-09-20, the owner's rulings on the module surface: new  
section **The module surface**. It reopens and replaces one ruling of **BKP 2 —  
the rulings** — that the module root is the whole public surface, flat. **No  
other technical ruling changed.**

Change from 005, 2026-09-20, the owner's rulings on documentation: new section  
**The documentation direction**. It says what the new tree publishes, what it  
does not, and who writes which part. **No technical ruling changed.** Three  
things it settles that no earlier version could: the reference book is dropped  
as a stage, the old mkdocs pages are frozen and unreachable rather than  
rewritten, and the README is the entry to the project and gets a stage of its  
own.

Two stale names in 005 are corrected here, both found by reading it rather than  
reported: **Where it lives** named `next-staging-plan-004.md` and the continue  
prompt named 004 and offered `SPEC | CORE`. The live plan was 013 at the time.  
This is the copy-goes-stale failure the new tree's own status file warns about,  
caught in this document.

005 and 006 are in `backup/`.

Change from 004, 2026-09-20, after the owner dropped the apply groups: new  
section **The direction change**, which says why the rulings are now applied in a  
tree of their own rather than to the existing one. **The apply groups** is kept  
and marked superseded — it is the record of what was decided, and its dependency  
reasoning is what the new stage order is built from. The stage table and the  
continue prompt now name the new tree. **No ruling changed.** 004 is in  
`backup/`.

Change from 003, 2026-09-20, after BKP 2: the owner ruled on every survey row.  
New section **BKP 2 — the rulings**, which carries each question as it was  
asked, the facts behind it, and the answer. New section **The apply groups**,  
derived from those rulings and approved by the owner. Three rows the survey did  
not have — IT5, HP6 and the vocabulary ruling — were raised during BKP 2 and are  
in the rulings section. The stage table and the prompt now name BKP 3. 003 is in  
`backup/`.

**The rulings section is the reading copy.** It is written to be re-read and  
argued with later, not only applied. A ruling that is reopened is reopened  
there.

Change from 002, 2026-09-19, after BKP 1: the owner answered the four open  
questions. New section **Owner rulings after BKP 1**. The four questions are  
closed in **Open questions**. The prompt now names this version. 002 is in  
`backup/`.

Change from 001, written by BKP 1 on 2026-09-19:

- New: **The survey.** The public surfaces side by side, one row per difference, and the example pairing.
- New: **Findings in ztk itself**, which BKP 1 found while reading, and which are not differences from 3tk.
- **Open questions**: the example-numbers question has an answer. New questions from the survey were added.
- **How to continue**: the BKP 2 prompt.
- 001 is in `backup/`.

This is the subject document of the backport.

- Every BKP stage reads it first.
- It carries the method, the findings and the rulings.
- `design/STATUS.md`, `design/STATUS-LOG.md` and the plan carry one pointer to it. No technical detail.
- A new version is written when more than a sentence changes. The old one goes to `backup/` next to it, with a plain `mv`.

---

## Why

3tk is the latest Matryoshka.

- It started as a C3 port of ztk.
- It became a redesign.
- It is the most advanced of the three dolls: otk (Odin), ztk (Zig), 3tk (C3).

ztk is almost finished, and its work is on hold.

- The goal: ztk takes what 3tk learned, where it fits Zig.
- The target: the same Matryoshka model, written the natural way in each language.
- Not identical APIs.

This is the first backport, not the last.

- Candidates after it: 3tk to otk, or a new port to ctk (C).
- So the method is written to be reused.
- What is language-neutral goes to `lang/common/`, not here.

---

## Where the files live

| what | where |
|---|---|
| this subject document | `design/secondary/lang/port/3tk-to-ztk/` |
| its old versions | `design/secondary/lang/port/3tk-to-ztk/backup/` |
| the language-neutral model | `design/secondary/lang/common/matryoshka-specification-NNN.md` |
| the external meta-plan, frozen input | `design/secondary/lang/common/meta-plan-external-001.md` |
| stage state | `design/STATUS.md` |
| stage narrative | `design/STATUS-LOG.md` |
| stage menu, old tree | `design/matryoshka-ztk-implementation-plan-NNN.md`, section BKP |
| the new tree, and its own three documents | `design/secondary/lang/port/3tk-to-ztk/next/` |

The next backport gets its own sibling folder.

- For example `lang/port/3tk-to-otk/`.
- It reuses the method below and `lang/common/`.

---

## Sources, and how much each counts

**The sources are the truth.**

- ztk: `src/`.
- 3tk: `design/secondary/lang/c3/3tk/src/` in this repo.
    - 3tk `.c3` files are edited here. The owner copies them to `matryoshka-3tk`.

**Next come the tests and examples.** They show the API in use.

**Documents and logs explain why.** They are not evidence of what is.

- They were written at different times.
- A document that disagrees with `src/` is reported, not believed.

**`lang/common/` is not a source of truth.**

- It is the language-neutral denominator of Matryoshka.
- Its files: `matryoshka-specification-005.md`, `port-flow-001.md`, `ztk-audit-001.md`, `README.md`.

---

## The four kinds of difference

Owner's classification, 2026-09-19.

- **Newer API in 3tk.**
    - Later and more advanced.
    - Usually worth adding to the other tks.
- **Removed API.**
    - Gone from 3tk.
    - Usually removed from the other tks too.
- **Std difference.**
    - Zig's std has a type-erased list, and ztk uses it.
    - C3's std has none, so 3tk has its own, `InnerQueue`.
- **Language difference.**
    - C3 has a unique `typeid`, and it works in a `switch`.
    - Zig has no such thing.

The test for every row:

> If C3 did not exist, would this change still make sense?

- No: a std or language difference. Usually not ported.
- Yes: a model difference. Brought to the owner.
- Decided by behaviour, not by name.

A row that fits no kind is marked **unclear** and goes to the owner.

---

## The method

**Iterative.** Nothing is planned past the next stage.

**Not split by module.**

- The modules depend on each other too much.
- A module-by-module port would keep breaking at the joins.

**The axis is the shape of the public API.** It is what a user touches.

- ztk: every `pub` declaration in `src/*.zig`.
- 3tk: every declaration outside an `::internal` module.
    - 3tk moved the non-user API into `::internal` modules, so its public surface is clean.
- A ztk `pub` item used only inside `src/` is a candidate to hide, the way 3tk did.
- Shape means more than the name:
    - a slot or a pointer
    - a method or a free function
    - what `create` fills
    - error sets or faults
    - what `close` gives back
    - which calls take a timeout

**Examples are the usage evidence.**

- 3tk's examples were borrowed from ztk's.
- ztk describes its examples in `design/task1-examples-006.md` and `design/task2-examples-007.md`.
- ztk: 87 example files, `examples/layer1` to `layer4`, `helpers`, `hooks`, `items`.
- 3tk: 67 example files in `examples/`.
- A pair of examples, one scenario written twice, shows the difference the user feels.
- A 3tk-only example points to a newer API.
    - For example the `l_bridge` group and `k_new_in_3tk`.
- A ztk-only example points to a removed API, or one never ported.

**Tests only where no example covers a behaviour.**

- ztk describes its tests in `design/task1-tests-008.md` and `design/task2-tests-004.md`.

**Then the owner rules.**

- Apply groups and their order come from the rulings.
- They are not fixed in advance.

**The common layer is updated every time.**

- After each ruling round, and after each apply stage.
- A new version of `lang/common/matryoshka-specification-NNN.md`.
- An ongoing duty, not a final step.

**A big-bang audit from time to time.**

- The common spec against both `src/` trees and the docs.
- Every few apply groups, and at the end.

---

## Borrowed from the external meta-plan

The owner gave an outside meta-plan as input. It is kept frozen in `lang/common/meta-plan-external-001.md`.

Taken from it:

- Code first, documents second.
- Neither repo is the authority.
    - Newer is not automatically right for Zig.
    - Older is not automatically wrong.
- The language test, above.
- Open questions are listed, not guessed.
- The same model, a natural implementation in each language.

Not taken:

- Ten fixed phases. This work runs in named stages, one at a time.
- Branch and commit snapshots. Git is disabled.
- Reading every document up front. There is too much, written at different times.

---

## The survey (BKP 1)

Read-only. No code changed.

**What was read.**

- ztk: `src/matryoshka.zig`, `polynode.zig`, `mailbox.zig`, `pool.zig`, in full.
- 3tk: `src/mtk.c3`, `inner.c3`, `helper.c3`, `queue.c3`, `mailbox.c3`, `pool.c3`, in full.
- The doc header of every example in both trees.
- Caller counts for every ztk `pub` name, in `examples/`, `stories/` and `tests/`.
- For reasons only: `matryoshka-3tk/design/3tk-port-findings-005.md`.
    - Its ztk `file:line` citations were not trusted. Each one used here was checked against `src/` again.

**How to read a row.**

- **kind**: newer, removed, std, language, or unclear.
- **test**: the answer to *if C3 did not exist, would this change still make sense?*
- **to owner**: yes when the row needs a ruling. No when the kind settles it.
- **why** points to a section of `3tk-port-findings-005.md` (**F§**) where 3tk wrote its reason.

### The item and its link

| id | ztk | 3tk | kind | test | to owner |
|---|---|---|---|---|---|
| IT1 | `PolyNode` is `std.DoublyLinkedList.Node` plus `tag`. Two links. `is_linked` is blind to the only item of a list, and says so in its doc comment. `ItemList` adds an O(n) walk, `_holds`, on every insert under safety. | `Inner` has one `link`. The last item of a chain points at itself. `is_linked` is exact and O(1). No walk. | std, with a model effect | yes. An exact link test and O(1) insert make sense in any language. | yes |
| IT2 | Identity is `*const anyopaque`, the address of a per-type static. | Identity is `typeid`. | language | no | no |
| IT3 | The field must be named `poly` and have type `PolyNode`. | The one `Inner` field is found by type, anywhere in the struct. Zero or two is a compile error. | unclear | yes. Zig can find a field by type through `@typeInfo`. | yes |
| IT4 | An item made by hand has `tag = undefined` until `init`. Nothing refuses it. | Every crossing refuses an outer that was never stamped, in safe mode. | newer | yes | yes |

**IT1, the facts.**

- The spec (`lang/common`) says the link test must be exact, or the port carries the walk. ztk carries the walk. So ztk conforms today.
- Why 3tk changed: F§1. The self-link closed the blind spot and deleted the walk.
- The cost in ztk: `PolyNode` stops using `std.DoublyLinkedList`. ztk would own a singly linked list, as 3tk does.
- IT1 goes with LS1. Without `prev`, the removed list operations cannot exist anyway.

### The Slot

| id | ztk | 3tk | kind | test | to owner |
|---|---|---|---|---|---|
| SL1 | `Slot = ?ItemHandle`. Empty, full, peek and take are Zig's own optional syntax. Each acquiring call asserts `slot.* == null` itself. | `Slot` is a typedef with `is_empty`, `is_full`, `peek`, `take`, `fill`. `fill` refuses a full slot or a null inner. | language | no. An optional already is a slot. | no |

### The helper

| id | ztk | 3tk | kind | test | to owner |
|---|---|---|---|---|---|
| HP1 | `create` allocates and writes `item.* = .{}`, so every field needs a default. `destroy` frees. No user code runs in either. | `create` calls the outer's own `init(a)`, and frees it again if `init` fails. `release` calls the outer's `finish(a)`. Both are required at compile time, and an empty body is fine. | newer | yes | yes |
| HP2 | `PolyHelper(T)` returns a struct. Two variants, chosen by `no_create_destroy`. | A generic module. `alias MSG = helper::OF{Msg};` | language | no. The spec leaves the spelling to the port (F§8). | no |
| HP3 | No panicking form of `moveFromSlot`. 95 of its 96 calls in examples and stories unwrap with `.?` or `orelse unreachable`. | `must_take` takes and panics on another type. | newer | yes | yes |
| HP4 | Reading back is spread across a tag test `isIt(tag)` and six casts: `fromPoly`, `mustFromPoly`, `fromSlot`, `mustFromSlot`, `moveFromSlot`, `toPoly`. | `is`, `look`, `must_look`, `take`, `must_take` each take a `Slot*`, an `Inner*` or an `any*`. `inner` and `linked` complete the set. | language | no. Zig has no argument-type switch like C3's `$Typeof`. `anytype` could do it, and that is a style question. | unclear, low |
| HP5 | Nothing. | `to_any`, `to_slot`, `must_to_any`, `must_to_slot`: the border with C3 containers, which carry `any`. Examples 063, 064. | std | no. Zig's containers are typed. ztk already sends `ItemHandle` through `Io.Queue` (example L4 043). | no |

**HP1, the facts.**

- 3tk example 057 keeps the allocator inside the outer. `init` is where it is stored.
- 3tk example 010 is the reason in one line: an outer is made and freed through the helper, never through the allocator directly.
- In ztk, an item that owns memory frees it by hand before `destroy`, in every example that does so.
- The cost: every item type in `examples/items/`, `tests/` and `stories/` gets two functions. Most would have empty bodies.

### The list

| id | ztk | 3tk | kind | test | to owner |
|---|---|---|---|---|---|
| LS1 | `ItemList` has 17 `pub` operations, plus its iterator. | `InnerQueue` has 8: `push_back`, `push_back_slot`, `pop_front`, `is_empty`, `len`, `iter`, `take`, `append_queue`. | removed | yes. 3tk's rule: *add an operation when a real Matryoshka behaviour requires it* (F§2). | yes |
| LS2 | `len` walks the list, O(n). | `len` reads a count, O(1). | newer | yes | with LS1 |
| LS3 | `moveFromList`, `moveToList`: the crossing to `std.DoublyLinkedList`. | None. C3's std has no such list. | std | no | no |
| LS4 | The pool's free list is LIFO, through `prepend` and `popFirst`. No comment says so or why. | LIFO on purpose, and the doc comment gives the reason: a stale writer meets the next owner at once (F§5). | unclear, doc only | yes | yes, low |

**LS1, the evidence.** ztk operations with no caller in any example or story, only in `tests/layer1_itemlist.zig`:

- `popLast`, `first`, `last`, `remove`
- `prepend`, `prependFromSlot`, `insertAfter`, `insertBefore`
- `iterator`
- `moveFromList`, `moveToList`
- `polynode.reset` has the same shape: one test file, no example.

Used inside `src/` only:

- `insertAfter` and `prepend` by the mailbox, for out-of-band order.
- `prepend` by the pool, for LIFO.
- `concat` by the pool's `close`, and in one example.

Used widely: `append`, `appendFromSlot`, `popFirst`, `isEmpty`, `len`.

### The mailbox

| id | ztk | 3tk | kind | test | to owner |
|---|---|---|---|---|---|
| MB1 | `mailbox.new(io, alloc, slot)` fills a Slot. The Master detaches it on the next line. Owner's ruling, INTR 8, 2026-08-14. | `mailbox::create(a)` returns `Mailbox*?`. No acquisition Slot. Example 051 says so. | unclear | yes, both ways. It is a ruling in both repos. | yes |
| MB2 | `mailbox.destroy(mbx, alloc)` and `destroy_slot`. Free functions. `Mbox` stores `alloc` in a field and never reads it. | `mbox.release()`, a method. It frees with the allocator stored at creation. | newer | yes | yes |
| MB3 | `destroy` panics if not closed. Nothing counts calls still inside the mailbox. | Every call counts itself in `_active`. `release` aborts, in every build, unless closed and idle. `is_idle` reports it. | newer | yes | yes |
| MB4 | No public query. The fields are `pub` because Zig has no private fields, and the comment says *don't touch*. No caller reads them. | `is_closed`, `is_idle`, `len`. | newer | yes | yes |
| MB5 | `send(slot)`. | `send(slot, limit = 0)`. A non-zero limit counts queued outers of the sender's own type, and refuses with `LIMIT`. Example 062. | newer | yes | yes |
| MB6 | `try_receive(slot) error{Closed}!bool`. | `poll(slot)`, which fails with `EMPTY`. | language | no. A `bool` is the natural Zig answer. | no |
| MB7 | `receive(slot, ?u64)`. `null` waits forever, `0` returns at once. Cancel through `Io.Cancelable`. | `receive(slot, Duration)`. Always a timeout. No cancel. | std | no. `std.Io` shapes it. | no |
| MB8 | `Result`, `receive_future`, `receiveResult`. | None. | std | no. They exist for `Io.Select` and `Io.Group`. | no |
| MB9 | `close()` and `receive_batch()` return an `ItemList`. | `close(out)` and `receive_all(out)` fill an empty queue the caller passes. | language | no. Returning a value is natural in Zig. | no |
| MB10 | One list, plus `oob_count` and `oob_last`. | Two queues, out-of-band first. Same order promised (F§3). | std | no. Internal, same behaviour. | no, unless LS1 removes `insertAfter` |
| MB11 | `wakeUpAll`, `receive_batch`, `try_receive`, `send_oob` in one struct. camelCase and snake_case mixed. | `wake_all`, `receive_all`, `poll`, `send_oob`. All snake_case. | unclear | a naming question | yes, low |
| MB12 | `Mbox` has 9 names for travel: `TAG`, `toPoly`, `fromPoly`, `mustFromPoly`, `is_it_you`, `fromSlot`, `mustFromSlot`, `moveFromSlot`, and a module-level `is_it_you`. | 3: `TYPE`, `to_inner`, `of`. | removed | yes | yes |

**MB12, the evidence.**

- `mailbox.is_it_you` duplicates `Mbox.is_it_you`. It is in one example file.
- `mustFromPoly` is in 6 example files, `fromSlot` and `moveFromSlot` in many. Those stay.

### The pool

| id | ztk | 3tk | kind | test | to owner |
|---|---|---|---|---|---|
| PL1 | `pool.new(io, alloc, hooks, slot)`. The tags are a field of `Hooks`. A duplicate tag goes unchecked. | `pool::create(a, tags, hooks)`. Tags are a separate argument. A duplicate or an empty set is refused in safe mode. | newer, plus MB1's question | yes | yes |
| PL2 | `get(.available_or_new)` pops a stored item **and still calls `on_get`**, with the Slot full. | Returns the stored item. `on_get` is reached only when nothing is stored, so its Slot is always empty. | unclear | yes | yes, high |
| PL3 | `put`: if the pool closed while `on_put` ran, the list `on_put` returned is dropped. Those items are lost. The item in the Slot stays with the caller. | Everything the call still has goes to `on_close`. The spec made this a MUST, invariant 35 (F§4). | newer | yes | yes, high |
| PL4 | `on_close(ctx, list: *ItemList)`. | `on_close(InnerQueue remaining)`, by value. After the call there is no way back to the items (F§4a). | newer | yes | yes |
| PL5 | `on_put` returns `?ItemList` of extra items. | `on_put` gets an empty queue, `extra`, and adds to it. | language | no | no |
| PL6 | `put_all(list)`. Used in 4 examples: L4 029, 034, 040, 062. | Removed. The caller writes the loop (F§6). | removed | yes | yes |
| PL7 | A tag not given at creation: an assert. In a fast build, `get` calls `on_get` with that tag, and `get_wait` waits for the whole timeout. | `UNKNOWN_IDENTITY`, and a check in safe mode. | newer | yes | yes |
| PL8 | No public query. | `is_closed`, `is_idle`, `count_of(t)`. The same `_active` guard on `release` as MB3. | newer | yes | with MB3, MB4 |
| PL9 | `Hooks` is a struct of `ctx` and three function pointers. | `PoolHooks` is an interface. The hooks struct is its own context. | language | no | no |
| PL10 | `get_wait_future`, `getWaitResult`, `Result`. | None. | std | no | no |

**PL2, the facts.**

- ztk's `on_get` doc comment reads as the pool filling the Slot, not the hook finding it full.
- `matryoshka-api-reference-042.md:1449` says `on_get` is *called for every `get` and `get_wait` call regardless of mode*. That is wrong twice: `get_wait` never calls it, and `.available_only` never calls it.
- The spec (`lang/common`, 004 and later) sides with 3tk and does not mark ztk as different (F§5a).
- The change is small in `src/`. The hooks in `examples/hooks/` that test for a full Slot would change too.

**PL3, the facts.** `src/pool.zig:354-371`. The work after the hook is inside `if (!closed)`, and there is no else. `returned` goes out of scope with its items still in it.

### The toolkit as a whole

| id | ztk | 3tk | kind | test | to owner |
|---|---|---|---|---|---|
| TK1 | An error set per call. | One fault set for the whole toolkit. Each call names its subset. | language | no | no |
| TK2 | Contracts are `std.debug.assert`. In ReleaseFast and ReleaseSmall that is `unreachable`, and the optimizer may treat a false condition as impossible. A few sites wrap it in `if (std.debug.runtime_safety)`. | `@check` is compiled out of a fast build. It is never an assumption (F§7). | unclear | yes. The reason 3tk gives is true of Zig too. | yes |
| TK3 | No version constant. | `VERSION`, `LOC`, `CHECKED`. | newer for `VERSION`. language for `CHECKED`, which is `std.debug.runtime_safety`. | yes for `VERSION` | yes, low |

### The example pairing

3tk numbers its examples by rule, not by ztk file. **No map existed in either repo before this.** This table is the first.

**Pairs.** One scenario, written in both.

| scenario | ztk | 3tk | what the pair shows |
|---|---|---|---|
| define an item | L1 021 | 011, 010 | IT3, HP1 |
| a transfer empties the Slot | L1 022 | 001, 003, 004, 016 | same |
| dispatch, item first | L1 023 | 017, 019 | same |
| dispatch, tag first | L1 026 | 018 | same |
| table dispatch | L1 027, L4 063 | 020 | same |
| cleanup through `defer` | L1 025 | 005, 006, 007, 008 | same |
| out of band | L2 055, L4 023 | 029 | same |
| pipeline | L2 056, L4 020 | 034 | same |
| request, response | L2 057, L4 021 | 033 | same |
| fan-in | L2 058 | 035 | 3tk uses `receive_all` |
| fan-out | L2 061 | 036 | same |
| close gives items back | L2 059 | 030 | MB9 |
| batch receive | L2 060 | 028, 015, 059 | MB9 |
| wake without a message | L2 097 | 032 | MB11 |
| a receive's outcomes | L4 030 | 046 | MB7 |
| capped pool | L3 090 | 040, 042 | PL9 |
| seeding | L3 091 | 040 | same |
| the three get modes | L3 089 | 037, 038, 039 | PL2 is visible in 037 |
| pool teardown | L3 092, L4 036, 037 | 052 | PL4 |
| mailbox as an item | L4 095 | 024, 025 | MB12 |
| pool as an item | L4 096 | 026 | MB12 |
| the Master | L4 017, 018, 019 | 049, 050, 051, 052, 053 | MB1, MB2 |
| items of several types in one pool | L4 033 | 045 | same |

**3tk only.** Each points at a newer API or a 3tk rule.

| 3tk | points at |
|---|---|
| 009 refused put, 031 refused send | same behaviour in ztk. No ztk example says so. Candidate example. |
| 012, 013 crossing, three spellings | HP4 |
| 023 infrastructure wrapper | no ztk example. Candidate example. |
| 027 poll | MB6. ztk has `try_receive` in one example only. |
| 057 the allocator in the outer | HP1 |
| 058 an identity needs no registration | same in ztk. Language point in 3tk. |
| 059 walk with `while` | language. `while (list.popFirst()) |ih|` is already ztk's form. |
| 060 guarding an expensive check | TK2, TK3 |
| 061 composite outer gives back its parts | PL5. ztk has the mechanism and no example. Candidate example. |
| 062 send with a limit | MB5 |
| 063, 064 the `any` bridge | HP5. Not ported. |

**ztk only.** Each points at a std difference, or at an API 3tk removed.

| ztk | points at |
|---|---|
| L4 025 to 031, 042 to 048 `Io.Select` | MB8, PL10. std. Keep. |
| L4 049 to 052 futures | MB8, PL10. std. Keep. |
| L4 057 to 061 pool without a mailbox | `Io.Future`, `Io.Group`. std. Keep. |
| L4 029, 034, 040, 062 | PL6, `put_all` |
| L1 024 builder, L2 054 worker loop, L2 062 shutdown command | patterns. No 3tk pair. No API difference. |
| L4 022 timer, 024 several sources, 039, 041 | std and patterns. Keep. |
| L4 032, 035, 038 pool and mailbox together | same API. No 3tk pair. |
| L4 053 to 056 pool fan-in, fan-out, recycle | same API. No 3tk pair. |

**Tests.** Only where no example covers a behaviour.

- 3tk has negative programs for the `_active` guard: `release_while_receiving`, `release_with_straggler_put`, `release_during_on_put`, `release_during_on_close`, `release_not_quiet_pool`. They are MB3's evidence.
- 3tk `t_concurrency.c3` holds the pool open during `on_put` and closes it. That is PL3's evidence. ztk has no such test.
- `tests/layer1_itemlist.zig` is the only caller of most of LS1.

---

## Findings in ztk itself

Found while reading. Not differences from 3tk. Each is a candidate fix whatever BKP 2 rules.

- **Z1.** `Mbox.alloc` is stored by `mailbox.new` and never read. `destroy` takes the allocator again. `src/mailbox.zig:53, 461, 479`.
- **Z2.** `Pool.get_wait`'s error set includes `NotAvailable` and `NotCreated`. It cannot return either. `getWaitResult` maps both to `.not_created`, which `get_wait` never means. `src/pool.zig:252, 549-550`.
- **Z3.** PL3 is a loss of items, not only a difference. `src/pool.zig:354-371`.
- **Z4.** `matryoshka-api-reference-042.md:1449-1452` describes `on_get` wider than the code. See PL2.
- **Z5.** A duplicate tag in `Hooks.tags` is not checked. `putAssumeCapacity` writes the same key twice. Harmless today, and silent. `src/pool.zig:215-218`.
- **Z6.** Already on record, and still true: `src/pool.zig` fails `zig fmt --check` on the blank line at 342.

---

## The stages

| stage | what it does | model |
|---|---|---|
| **BKP 0** | This setup. The files, the method, the prompts. No code. DONE 2026-09-19. | Opus 5 |
| **BKP 1** | The survey, read-only. Written as this version. DONE 2026-09-19. | Opus 5 |
| **BKP 2** | **The owner rules** on the rows. Apply groups and their order derived from the rulings. Written as this version. DONE 2026-09-20. | Opus 5 |
| **BKP 3** | Loose ends in the old tree: Z6, Z4, TK3, LS4. DONE 2026-09-20. | Sonnet 5 |
| **BKP 4** | The check helper in the old tree: TK2. DONE 2026-09-20. | Opus 5 |
| **BKP 5 to BKP 11** | **Apply groups. Not run** — dropped 2026-09-20. See **The direction change**. | — |
| **SETUP** | The new tree: its build, its scripts, its gate, its three documents. No toolkit code. DONE 2026-09-20. | Opus 5 |
| **the layer stages** | The rulings, applied once each, in the new tree. The menu is the highest-numbered `next/next-staging-plan-NNN.md`. | Named per stage there |
| **BKP AUDIT** | The big-bang audit. | Opus 5 |

Every stage:

- starts after a `/clear`, from these files alone
- ends with the prompt to continue, and the model to use
- follows `design/rules-050.md` Part 0 and `matryoshka-3tk/design/3tk-rules-007.md` Part 2

**The rows BKP 2 ruled on, in the survey's order.** Every row marked *to owner*.  
All are ruled — see **BKP 2 — the rulings**.

- High: PL2, PL3.
- The model: IT1 with LS1 and LS2, IT3, IT4, HP1, HP3.
- Creation and release: MB1 with PL1, MB2, MB3 with PL8, MB4.
- New API: MB5, PL7, PL4.
- Removed API: PL6, MB12.
- Style and docs: TK2, MB11, LS4, TK3, HP4.
- Z1 to Z6.

This is the survey's order, not an apply order. BKP 2 derived that — see  
**The apply groups**.

---

## Owner rulings after BKP 1

Ruled 2026-09-19, before BKP 2.

- **R1. MB1: INTR 8 is not reopened.** ztk creation keeps filling a Slot.
  3tk's pointer-returning `create` is not ported. PL1's Slot half follows.
- **R2. IT1: yes, an exact link test, on `std.DoublyLinkedList.Node`.**
    - `PolyNode` keeps the std node.
    - The link test becomes exact, as in 3tk. The O(n) insert walk goes.
    - How to make it exact on the std node is BKP 2's to design. One way: the last node's `next` points at itself, as 3tk's does. Then std's own list functions cannot maintain the chain, and ztk writes the few operations it keeps.
    - This goes with LS1: fewer operations to write.
- **R3. BKP runs first.** The PARKED WORK in `design/STATUS.md` waits until BKP is done.
- **R4. `lang/` old versions go to `backup/`.** Confirmed. `design/` keeps its own rule.

---

## BKP 2 — the rulings

Ruled by the owner, 2026-09-20, one group at a time.

**How to read this section.** Each entry is the question as it was put to the  
owner, the facts behind it, and the answer. The facts were checked against  
`src/` during BKP 2, not taken from the survey. Where BKP 2 found something the  
survey had missed, it says so. Nothing here is applied yet — the apply groups  
are the next section.

### The standing rule

**3tk is the more advanced API. Where a difference does not come from a  
language feature or a std difference, 3tk's solution wins by default.** Owner's  
rule, 2026-09-20. ztk keeping its own way needs a reason written down. Two  
exist: R1, the Slot, and R2, the std node.

### High — PL2, PL3

**PL2. `get(.available_or_new)` calls `on_get` even when the Slot is full.**

- The facts. `src/pool.zig:575-586`. A stored item is popped into the Slot, and
  `hooks.on_get(...)` runs anyway.
- What the survey missed, found by BKP 2: two hooks depend on that call.
  `examples/hooks/CappedPoolHooks.zig:23` does `self.count -= 1` when the Slot is  
  full, to track the pool's count. `tests/layer3_pool.zig:967` resets a recycled  
  item there.
- The 3tk way. `on_get` runs only on an empty Slot. A capped hook reads
  `in_pool_count` in `on_put` instead. A reset moves to `on_put`, which  
  `resetOnPut` in that same test already does.
- **Ruled: adopt the 3tk behaviour.** `on_get` is reached only when nothing is
  stored, so its Slot is always empty. `CappedPoolHooks`, the test hook, the  
  `on_get` doc comment and Z4 all change with it.

**PL3. `put` loses items if the pool closes while `on_put` runs.**

- The facts. `src/pool.zig:354-371`. Everything after the hook is inside
  `if (!closed)` and there is no else. The list the hook returned is dropped and  
  its items are lost. The item in the Slot stays with the caller.
- Three ways out were put to the owner. (a) the 3tk way, everything still held
  goes to `on_close`. (b) the items go back to the caller, which changes `put`'s  
  signature. (c) `close` waits for any `on_put` in flight, so the case cannot  
  happen.
- The owner asked for 3tk to be checked first, recalling that `on_close` there
  may run more than once. **It does.** `3tk/src/pool.c3:282-332`: a straggling  
  `put` builds a queue of its own — the Slot item plus the hook's `extra` — and  
  calls `on_close` a second time, outside the lock. So the two calls can run at  
  the same time, and the hook needs its own lock. The caller's Slot is empty  
  either way; the item does not come back.
- `lang/common/matryoshka-specification-005.md:1809` says the same: *called once
  by close, and once more per straggling put. A hook must not destroy its own  
  state on the first call.* It is the only MUST that 003 weakened.
- Reported, not fixed, on the 3tk side: no `on_close` doc comment in `pool.c3`
  says it can be called more than once — only the spec does. No 3tk example shows  
  the second call.
- **Ruled: (a), and the documents change with the sources.** The doc comments,
  the api reference and every page that says `on_close` is called once are  
  rewritten. A hook must survive being called more than once, possibly  
  concurrently.

### The model — IT1, LS1, LS2, IT3, IT4, HP1, HP3

BKP 2 corrected one survey figure: there are **10** `PolyHelper(...)`  
definitions in 7 files, not the larger number the survey implied. HP1 costs less  
than it said.

**IT1. An exact link test.** R2 had already ruled yes. This was how.

- Today `is_linked` is `prev != null or next != null`, `src/polynode.zig:84`. The
  only item of a list has both null, so the test cannot see it. `_holds` walks the  
  list on every insert under safety to cover part of the gap.
- **Ruled: the tail's `next` points at itself, so linked means `next != null`.**
  Exact, O(1), and the walk goes. `ItemList` stops wrapping a std list and writes  
  its own operations.
- **And a change to R2, ruled the same day: the node becomes
  `std.SinglyLinkedList.Node`, not the doubly linked one.** One link, still  
  intrusive, still reached with `@fieldParentPtr`. `PolyNode` loses a pointer.  
  What a singly linked list cannot do cheaply is exactly what LS1 removes, so  
  nothing is lost. `std.DoublyLinkedList` leaves `src/`, which also settles LS3:  
  `moveFromList` and `moveToList` have nothing left to cross to.

**LS1. The reduced operation set.**

- Kept: `append`, `appendFromSlot`, `popFirst`, `isEmpty`, `len`, `concat`, and a
  `while (popFirst())` walk in place of `iterator`.
- Removed: `popLast`, `first`, `last`, `remove`, `prependFromSlot`,
  `insertBefore`, `iterator`, `moveFromList`, `moveToList`, `polynode.reset`.
- `prepend` and `insertAfter` had two options: keep them internal, or restructure
  as 3tk did.
- **Ruled: (b), restructure.** The mailbox keeps two queues, out-of-band first,
  so `insertAfter` is not needed. The pool pushes to the front of its own free  
  list internally.

**LS2. `len`.** Today an O(n) walk. **Ruled: a stored count, O(1).**

**IT3. Finding the field.** Today the field must be named `poly` and typed  
`PolyNode`, checked at `src/polynode.zig:328-331`. **Ruled: find the one field by  
type through `@typeInfo`. Zero or two is a compile error.** The name stops being  
required. The offset this computes is what IT5 stores.

**IT4. The unstamped item.** Today `tag = undefined` until `init`, and nothing  
refuses an item that was never stamped. **Ruled: every crossing refuses an  
unstamped item in safe builds.** IT5 made the mechanism a pointer compare.

**HP1. The item's own hooks.** Today `create` does `item.* = .{}`, so every field  
needs a default, and no user code runs in `create` or `destroy`. **Ruled: `create`  
calls the outer's `init(alloc)` and frees it again if that fails; `destroy` calls  
`finish(alloc)` first. Both required at compile time, an empty body allowed.**

**HP3. The panicking take.** 95 of the 100 `moveFromSlot` calls in `examples/`  
and `stories/` unwrap with `.?` or `orelse unreachable`. **Ruled: add  
`mustMoveFromSlot`, which panics on a wrong type or an empty Slot.**

### Identity — IT5, and what `Any` is

Not a survey row. It came out of the owner's question about the difference  
between an `Inner` and an `any`, and it changes what identity is.

**The asymmetry the owner named.**

- `Inner` holds a pointer to the **next inner** and the type of the **outer**.
  The pointer and the type describe different things.
- `any` holds a pointer to the **outer** and the type of the **outer**. They
  agree.
- The consequence: getting from the inner back to the outer needs the offset, and
  the offset lives only at compile time — `@fieldParentPtr` in Zig, `inline`  
  inheritance in C3. So every crossing back needs `T` at comptime.

**Why 3tk took `any` out of `Inner`.** Owner's own experience, recorded here  
because it is the reason the opposite now works: an `any` stored inside the  
inner makes it carry a pointer to the struct it lives in. Self-referential,  
redundant with the offset, another field to keep true across a move, and it must  
be re-stamped whenever the outer is copied. The type was already there; only the  
pointer was new, and the pointer was derivable.

**The opposite case, which is this one.** Do not store an `any` in the inner —  
derive it from the inner, at the border, and let it die there. That is what 3tk's  
`to_any`/`to_slot` do. Nothing is stored.

**The ruling: identity becomes a pointer to a per-type descriptor.**

```zig
pub const Identity = *const OuterDesc;

pub const OuterDesc = struct {
    name: []const u8,     // "Chunk" — logs and panic text
    size: usize,          // @sizeOf(Outer)
    inner_offset: usize,  // @offsetOf(Outer, <the Inner field>)
    finish: ?*const fn (outer: *anyopaque, alloc: Allocator) void,
    // magic: u64 — reserved, see below
};
```

- The pattern is not new. **otk documents it already**, as *Advanced —
  descriptor struct as tag*, with `name` and `size`. There it is advice to a  
  programmer, because an Odin user may make a tag by hand. Here the helper always  
  builds it and it is part of the toolkit.
- **`inner_offset` is the field that changes what is possible.** Inner to outer
  becomes a runtime subtraction, so the crossing back no longer needs `T` at  
  comptime. IT3 already computes this offset and today throws it away.
- `finish` is HP1's hook, type-erased, so `close`, `on_close` and `freeList` can
  release a mixed list with no tag switch. **Marked re-think**: the field is  
  reserved, and whether the toolkit calls it is reopened when HP1 lands.
- `name` and `size` come from otk and earn their place in logs and panic text.
- One static per outer type, built at comptime by the helper. Identity is still
  compared by pointer, so identity semantics do not change.

**Mandatory, and the helper is the only way.** Owner's ruling. If the toolkit  
reads every identity as a descriptor, an identity that is only an address becomes  
undefined behaviour the moment it is dereferenced — that is 3tk's example 058,  
*an identity needs no registration*. So a hand-made identity must build a  
descriptor too, even one with an empty body. This narrows the model, and the  
narrowing is the price of `inner_offset`.

**`UNSTAMPED` is a built-in descriptor, not a sentinel value.** Owner's ruling.

```zig
const unstamped: OuterDesc = .{ .name = "<unstamped>", .size = 0,
                                .inner_offset = 0, .finish = null };
pub const UNSTAMPED: Identity = &unstamped;

pub const Inner = struct {
    next: ?*Inner = null,
    id: Identity = UNSTAMPED,
};
```

- `id` is never `undefined` and never dangling. An unstamped item is wrong, and
  reading it is not undefined behaviour.
- IT4's check is `id == UNSTAMPED`, a pointer compare, the same cost as today's
  tag compare.
- Panic text reads `desc.name`, so an unstamped item prints `<unstamped>` and
  every wrong-type panic gets both names for free.
- `inner_offset = 0` and `size = 0` are deliberate: a missed check yields the
  inner's own address, not a wild pointer.
- The rule it imposes: **check before you compute.** Any path using
  `inner_offset` or `finish` asserts `id != UNSTAMPED` first — which is IT4's  
  check, so it costs nothing extra.

**What ztk's `Any` is: `ItemHandle` itself. No new type.** IT5 is what makes that  
true. From one pointer:

```zig
const id = ih.id;                                 // the type
const outer = @intFromPtr(ih) - id.inner_offset;  // the pointer
```

- It carries everything `any` carries, in one pointer instead of two, and the
  cast back is checked against the descriptor rather than trusted.
- Zig containers are typed, so the common case erases nothing:
  `Io.Queue(ItemHandle)`, `Io.Select`, `ArrayList(ItemHandle)`.
- HP5 stays not ported. What 3tk's `to_any`/`to_slot` really contribute is their
  **checks**, not their types — and that is HP6.
- A C boundary, where only `*anyopaque` can cross, would want `toOpaque` and
  `fromOpaque`. The danger is that `fromOpaque` cannot verify it was handed one  
  of ours. A `magic: u64` first field in `OuterDesc` would make that check  
  possible, at eight bytes per type, not per item. **No C caller exists today, so  
  the pair is not added and `magic` is reserved.**

**HP6, new. The border pair.** ztk has no checked way to move an item between a  
Slot and a bare `ItemHandle`; a caller writes `const ih = slot.*.?; slot.* = null;`  
with none of the checks. **Ruled: add `takeFromSlot(slot) ItemHandle` and  
`fillSlot(slot, ih)`**, each asserting: stamped, unlinked as it crosses, the  
destination empty, the source cleared. That is the border 3tk guards, in Zig's  
terms. It earns an example — 3tk's 063 and 064 have no ztk pair, and an item  
crossing into a std container and back is shown nowhere today.

### Creation and release — PL1, MB2, MB3, MB4, PL8

**PL1.** R1 had already kept the Slot. What was left: the tags are a field of  
`Hooks` and a duplicate goes unchecked, `src/pool.zig:215-218`.  
**Ruled: the tags become a separate argument, `pool.new(io, alloc, tags, hooks,  
slot)`, and a duplicate or an empty set is refused in safe mode.** `Hooks` goes  
back to a context and three functions. This closes Z5.

**MB2.** Today `destroy` and `destroy_slot` are free functions taking the  
allocator, while `Mbox.alloc` is stored and never read. **Ruled: `destroy`  
becomes a method using the stored allocator, on both containers. `destroy_slot`  
is kept, with a note — re-think.** This closes Z1: the field starts being read.

**MB3 and PL8's guard.** Today `destroy` panics if not closed, and nothing counts  
calls still inside the container. **Ruled: every public call counts itself in  
`_active` while it runs, and `destroy` panics in every build unless closed and  
`_active == 0`.** It also fits PL3 = a — a `put` still running its straggling  
`on_close` blocks `destroy`.

**MB4 and PL8's queries. Ruled: all four.** `isClosed()` and `isIdle()` on both  
containers, `len()` on the mailbox, `countOf(tag)` on the pool.

### New API — MB5, PL7, PL4

**MB5.** 3tk's `send(slot, limit = 0)` refuses with `LIMIT` when the sender's own  
type already has that many queued. Zig has no default arguments, so it is either  
a second parameter at every call site or a separate function. **Ruled: a separate  
`sendLimited(slot, limit)`.**

**PL7.** Today an unknown tag is an assert; in a fast build `get` calls `on_get`  
with a tag the pool never knew and `get_wait` waits out the whole timeout.  
**Ruled: an error return, in every build,** plus the safe-mode check. It widens  
the error sets of `get`, `get_wait` and `put`.

**PL4. Ruled: `on_close` takes the list by value**, so after the call there is no  
way back to the items. It pairs with PL3 = a, where a straggling `put` builds its  
own list and hands it over.

### Removed API — PL6, MB12

**PL6. Ruled: `put_all` is removed.** The caller writes the loop. Four examples  
change: L4 029, 034, 040, 062. It also removes the not-atomic-with-close  
mid-batch case at `src/pool.zig:376-415`, which PL3 = a would otherwise have had  
to handle a second way.

**MB12. Ruled: (a) — drop only the duplicate.** The module-level  
`mailbox.is_it_you` duplicates `Mbox.is_it_you` and is in one example file. The  
rest of the infrastructure surface stays, because it comes from the helper and  
`mustFromPoly`, `fromSlot` and `moveFromSlot` have many callers.

### Style and docs — TK2, MB11, LS4, TK3, HP4

**TK2.** `std.debug.assert` becomes `unreachable` in ReleaseFast and  
ReleaseSmall, so the optimizer may treat a broken contract as a promise — a  
false condition turns into undefined behaviour rather than nothing. 3tk's  
`@check` is compiled out and is never an assumption, and the reason holds for  
Zig. **Ruled: one `check()` in `src/`, compiled out when `runtime_safety` is off,  
replacing `assert` at every contract site.**

**MB11.** `wakeUpAll`, `receive_batch`, `try_receive`, `send_oob` mix two cases  
in one struct. 3tk is snake_case throughout, but that is a C3 convention, so the  
standing rule does not apply — this is a language difference. Zig's own  
convention: **functions `camelCase`** unless they return a type, types  
`TitleCase`, fields and variables `snake_case`, constants `snake_case` too, and  
acronyms as words. About half of ztk already follows it. **Ruled: camelCase.**  
`TAG` also loses its all-caps, which Zig reserves for C mirrors, and becomes part  
of the IT5 rename.

**LS4. Ruled: document the LIFO reason** — a stale writer meets the next owner at  
once. Doc only.

**TK3. Ruled: add `VERSION`** to `src/matryoshka.zig`. `CHECKED` is  
`std.debug.runtime_safety` in Zig and `LOC` is 3tk's own, so neither is ported.

**HP4. Ruled: leave the six casts.** Zig has no argument-type switch; `anytype`  
could do it and that is style, not model.

### The vocabulary — Outer and Inner

Raised by the owner during BKP 2. ztk says Item and PolyNode; 3tk says Outer and  
Inner.

**Why "parent" cannot be the shared word.** The owner's reason, and it is the  
reason `design/STATUS.md:72` bans it: the term points opposite ways in the two  
languages. In C3 the **inner** is the parent, because the outer is declared as  
deriving from it. In Zig the **outer** is the parent, because the inner is a  
field of it and `@fieldParentPtr` walks from the field up. The same pair of dolls  
gets opposite labels. Outer and inner say which doll is inside which, and that  
does not move between languages.

The glossary and the rule disagree today: `design/language-of-matryoshka.md:221`  
already defines **ParentHandle**, while `STATUS.md:72` bans the word. That entry  
needs an edit in any case — it names `std.DoublyLinkedList`, which IT1 removes.

**Ruled: take 3tk's words. Item becomes Outer, PolyNode becomes Inner. Split:  
the documents and the glossary first, the `src/` names in a later apply group.**  
`ParentHandle` keeps its narrow Zig-mechanism meaning, marked clearly as a  
Zig-side term and not a model term.

### The ztk findings — Z1 to Z6

- **Z1**, `Mbox.alloc` stored and never read. Carried by MB2.
- **Z2**, `get_wait`'s error set declares `NotAvailable` and `NotCreated` and can
  return neither; `getWaitResult` maps both to `.not_created`, which `get_wait`  
  cannot mean. `src/pool.zig:252, 549-550`. **Ruled: narrow the error set and drop  
  the dead arms.** PL7 adds `UnknownIdentity` in the same pass.
- **Z3**, items lost in `put`. Carried by PL3 = a.
- **Z4**, `matryoshka-api-reference-042.md:1449-1452` says `on_get` is called for
  every `get` and `get_wait` regardless of mode — wrong twice. **Ruled: fixed in  
  its own small pass now**, not only when PL2 lands, because the page is wrong  
  today.
- **Z5**, the unchecked duplicate tag. Carried by PL1.
- **Z6**, `src/pool.zig` fails `zig fmt --check` on the blank line at 342.
  **Ruled: fix it.** It was left alone as the owner's file; that hold is released.

---

## The apply groups — SUPERSEDED 2026-09-20

**These nine groups are not run.** The owner dropped them the same day they were  
approved, in favour of writing the model once in a tree of its own. See **The  
direction change** below for the reasons and for where the work lives now.

The section is kept, not deleted, for two reasons. It is the record of what was  
approved, and the dependency reasoning in it — what has to come before what — is  
what the new stage order was built from. Read it as the argument, not as the plan.

Derived from the rulings, approved by the owner 2026-09-20. Ordered by  
dependency, not by survey order.

Each group is a stage. Each ends green in all four optimization modes with  
`check_design.sh` at exit 0, and each splits into **.a** — implementation and  
tests — and **.b** — examples, per the tests-before-examples rule.

| group | contents | why here | model |
|---|---|---|---|
| **BKP 3** — loose ends | Z6, Z4, TK3, LS4, and the -073 line in `context.md` | No dependencies, no design. Clears the fmt trip-wire before anything touches `pool.zig`. | Sonnet 5 |
| **BKP 4** — `check()` | TK2 | Every later group adds safe-mode checks. This is the thing they add. | Opus 5 designing, Sonnet 5 sweeping |
| **BKP 5** — identity | IT5, IT3, IT4 | The core. IT3 computes the offset IT5 stores; IT4 is one compare against `UNSTAMPED`. Splitting them means writing the helper twice. | Opus 5 |
| **BKP 6** — the list | IT1, LS1 (b), LS2 | Rewrites `ItemList` and the mailbox's ordering. After BKP 5, so `polynode.zig` is rewritten once. | Opus 5 |
| **BKP 7** — the helper | HP1, HP3, HP6 | HP1 fills the `finish` field BKP 5 reserved. 10 helper sites. | Opus 5 for HP1's shape, Sonnet 5 for the item types |
| **BKP 8** — the mailbox | MB2, MB3, MB4, MB5, MB12 | The `_active` pattern is designed once here and copied to the pool. | Opus 5 |
| **BKP 9** — the pool | PL1, PL2, PL3, PL4, PL6, PL7, PL8, Z2 | The largest. PL3 depends on PL8's counter and PL4's by-value list. | Opus 5 |
| **BKP 10** — the words | Vocabulary B in `design/`, the glossary, the `ParentHandle` entry, the api reference; MB11's camelCase sweep; **and `check_design.sh`'s glossary check updated to the new words** | Docs first, as ruled. The camelCase sweep rides along because both are renames across many files. | Opus 5 for the glossary, Sonnet 5 for the sweeps |
| **BKP 11** — the names in code | `PolyNode` → `Inner`, `Item*` → `Outer*`, `TAG` → `id`, the rest of vocabulary B in `src/`, tests, examples, stories | Mechanical, and last, so no earlier group renames twice. | Sonnet 5 |
| **BKP AUDIT** | The common spec against both `src/` trees, and the big-bang audit | After the model groups. A new `lang/common` spec version also follows each group. | Opus 5 |

Three notes on the order.

- **BKP 3 first, deliberately.** Four small things, but Z6 blocks every later
  group that touches `pool.zig`.
- **BKP 5 before BKP 6.** Both rewrite `polynode.zig`. Identity first, because
  the list's checks read `id`.
- **BKP 11 last.** Every earlier group would otherwise rename its own files, and
  the sweep would collide with itself.

`check_design.sh`'s glossary conformance check is tied to the current words, so  
BKP 10 updates the check as part of the group. Owner's ruling, 2026-09-20.

---

## The direction change

Ruled by the owner, 2026-09-20, after the apply groups were approved and before  
any of them ran. **No ruling in this document changed. Only the order and the  
place the work happens.**

### What was tried, and what measuring it showed

BKP 5 — identity as a descriptor — was started. Before writing code it measured  
what the group would touch, and the three figures decided the matter:

- **The identity change alone reaches about 70 call sites** outside `src/`: every
  place that writes the identity type by name, in `Hooks.tags`, in the get hook's  
  signature, in the table-dispatch helpers, and in the two hook files. The 224  
  bare uses of the per-type constant are inferred and would not change.
- **Three groups rewrite the same file and then re-read the same call sites.**
  BKP 5, BKP 6 and BKP 7 all rewrite `src/polynode.zig`. Across them, about 300  
  call-site reads, most of them twice or three times. The plan's own note — *BKP  
  11 last, so no earlier group renames twice* — had the right instinct applied to  
  one row only.
- **The intermediate states are designs nobody wants to keep.** After BKP 5 the
  toolkit would have descriptor identity on a doubly-linked std node, with a link  
  test that cannot see a chain of one, and a `create` that cannot run user code.  
  That is a fourth design, not a step toward the third, and every four-mode gate  
  run on it verifies something that will never ship.

And one hard blocker, found in the build rather than argued: **`build.zig:53` has  
the tests module import the examples module.** So `zig build test` compiles  
`examples/`, and the implementation half of a stage cannot be green until its  
examples half is done. The tests-before-examples rule and the `.a`/`.b` split  
could not both hold. The owner named the cause plainly: splitting was the wrong  
decision.

### What replaces them

The model is written once, whole, in a tree of its own, layer by layer: the  
**core**, then the **mailbox**, then the **pool**. Examples last.

- The rulings compose into one model. The descriptor holds the offset the helper
  computes; the list's checks read the descriptor; the helper's `init` fills a  
  field the descriptor declares. Written together, each file is written once.
- **Two of the nine groups stop existing.** BKP 10 and BKP 11 — the rename of the
  documents and the rename of the code — were needed only because the old code  
  would still be carrying the old words. New code carries Outer and Inner from its  
  first line.
- The old tree is frozen, not forked. No edits to it at all. It is read, and
  files are copied out of it. It is deleted in one step when the new tree  
  overtakes it.
- The std rows stay copied, not rewritten. The `std.Io` surface, the futures, the
  result types and the copied timeout code were all ruled unchanged, so they move  
  across as they are. This is where a fresh start could quietly lose behaviour,  
  and copying is the guard.

The cost, stated rather than buried: **the 87 examples must still be ported.** That  
work does not disappear. It moves to one stage at the end and is paid once  
instead of three times.

### Where it lives

The owner chose the arrangement the C3 work already uses: a whole project root  
kept under `design/secondary/lang/`, edited in place, copied out when ready.

| what | where |
|---|---|
| the new tree's state | `next/next-status.md` |
| its stage menu | `next/next-staging-plan-NNN.md`, the highest number present |
| its narrative | `next/next-log.md` |
| its code | `next/ztk/` — a whole Zig project root |
| its test scenarios | `next/ztk/design/` |

`next/` sits beside this document because this document is what produced it.

One asymmetry against the C3 case, recorded because it is a hazard: for C3 the  
destination is a different repository, so a mistaken path cannot damage the  
source. Here the destination is this repository. So the new tree's scripts root  
themselves from their own location and never reach above `next/ztk/`.

The new tree needed its own documents gate. `kitchen/tools/check_design.sh` line  
103 prunes `design/secondary/lang` outright and line 115 excludes `secondary/`  
from the word checks — correct for the frozen C3 material, and wrong for a tree  
being written, which would have been invisible to it.  
`next/ztk/kitchen/tools/check_next_docs.sh` replaces it, and adds the one check  
the old gate cannot make: the old gate defends the old words, and the new one  
refuses them.

### What this does not change

- Every ruling in **BKP 2 — the rulings** stands, and each is implemented by a
  named stage of the new tree.
- **Owner rulings after BKP 1** stand: R1, the acquisition Slot; R2 as amended to
  the singly linked node; R3, this work before the waiting work; R4, old versions  
  to `backup/`.
- The survey, the findings and the example pairing are unchanged and are still
  the input to the new stages.
- BKP 3 and BKP 4 are done and stay done, in the old tree. The check helper BKP 4
  added is written again in the new tree's core, which is where every other check  
  in it is written.

---

## The documentation direction

Ruled by the owner, 2026-09-20, after BRIDGE finished and before DOCS wrote  
anything. DOCS as chartered no longer exists. **No technical ruling changed.**

### The new tree is not bound by the old arrangement

What the old ztk did before the port to 3tk is **not automatically kept**. The  
owner is weighing changes to the inherited arrangement, and some of them may be  
temporary.

This is written down because of how the failure happens. A session reads a  
working tree, finds it consistent, and infers that its shape was chosen. Most of  
it was only inherited. The examples layout and its `NNN-name.zig` numbering, the  
seven `examples-*` build steps and their test wrappers, the api reference as a  
book of seven parts, the scenario tables as an index a new example registers in —  
every one of those is a **candidate**, not a default.

What a session does about it: before reusing an old-tree arrangement, say that  
is what you are about to do, and let the owner rule. Do not present the  
inherited shape as settled.

### Three standing constraints

1. **Everything stays under `next/ztk/`.** Files needed from the old tree are
   copied in. They are backported to the root later, as its own stage. The root  
   stays frozen meanwhile — including references that go stale there, which are  
   reported rather than fixed.
2. **A file that deserves versioning gets a new number when it changes**, and the
   superseded one goes to a `backup/` beside it. `README.md` is the one  
   exception: a README cannot carry a suffix and still be a README, so it is a  
   stable entry point updated in place, the way `next-status.md` is.
3. **Migration to the repository root is a separate stage.** No stage before it
   copies anything up, deletes anything at the root, or rewrites the root  
   `design/`.

### What the project publishes

Three things, and nothing else:

- the **README**
- the **landing page**
- the **Zig documentation generated from the sources**

3tk's GitHub Pages carries only the source-generated documentation. Its examples  
catalog is generated locally and dropped from the deployment in the Actions  
workflow. **ztk does the same, with one exception: 3tk has no mkdocs part and so  
no landing page at all, and ztk keeps one.**

### The old documentation is frozen, not rewritten

`kitchen/docs/index.md` gets two edits, and they are the whole change:

- the `<a href="manifesto/">` wrapper is dropped, so the logo is a picture and
  nothing more
- `target="_blank" rel="noopener"` is dropped from the Lines Of Code badge, so
  `apidocs/` opens in the same tab

The picture *was* the only way in to the mkdocs pages. Un-linking it makes that  
whole body unreachable. It is still generated. It is not visible. That is the  
intent, not an accident of it.

**Only what the landing page needs is copied** into `next/ztk/`: `mkdocs.yml`  
with its navigation pruned to what is present, `docs/index.md`, `assets/`,  
`stylesheets/`, `favicon.ico`, `hooks/` — `index.md` calls `src_loc()` — and the  
site tools. The 148 markdown pages under `kitchen/docs/` stay in the frozen root.

The reason is measured, not stylistic. Those pages describe the old model:  
`Item` 498 times, the retired node word 485, the retired handle word 79,  
`lifecycle` 21, the retired tag word 11. Copied in, they would put roughly 1,100  
hits through `check_next_docs.sh` checks 2 and 3 and make gate 4 useless — and  
that gate is the only thing defending the new vocabulary. A rewrite, if it ever  
happens, starts from the frozen originals.

### The reference book is dropped

DOCS was chartered to write an api reference modelled on the old tree's book of  
seven parts. **That stage does not happen.**

- The per-module part of each generated page takes over what mkdocs carried.
- The rest of each page is the api reference.
- Examples and snippets go in the first part.

So the reference is the generated documentation plus doc comments worth reading,  
and a separate book would be a third description of the same model, invisible  
behind an un-linked picture, written against a model the owner is still weighing  
changes to. That is the trap the apply groups were, in another shape.

### Doc comments

The rules already exist and are not rewritten: **`design/rules-050.md` Part 4 —  
Comments, doc comments, autodoc.** What matters most there, because it is what a  
session gets wrong:

- the doc-stub rule — a `///` on the first declaration after the `//!` header is
  spliced onto the module overview page with no separator, and  
  `const _doc_stub = void;` absorbs it
- ASCII diagrams live in a fenced block, because autodoc renders CommonMark and
  collapses single line breaks into one paragraph
- `//!` and `///` above the same function silently truncate each other
- no reference to a `.md` file from inside `src/`, because a reader of the
  generated page cannot follow it
- **verify by rendering the page, not by reading the source**

`/home/g41797/Downloads/zig-docs-comments.md`, written by another AI on  
2026-09-20, is optional input and **not a source of truth**. If it is taken in,  
it is taken the way `meta-plan-external-001.md` was: copied as it arrived, with  
`-external-` in the name, cited for its reasoning and never as authority.

### The README

**The most important thing in this list**, and its own stage. It is the entry to  
the project, and with the picture un-linked there is almost nothing behind it.

- It is the 3tk README with only the facts that are wrong for Zig rewritten.
  Most of it is common to every toolkit in the family.
- 3tk's README is in its own repository and frozen, so it is read when needed
  rather than copied in and kept. Nothing to drift.
- The 3tk README broke completely with every ztk README before it. **The old ztk
  README is not a starting point, and neither is its tone.**
- The working file is `next/ztk/design/README-001.md`, versioned, superseded
  copies to `next/ztk/design/backup/`. The approved text becomes `ztk/README.md`  
  at the end, and the repository root's `README.md` at migration.
- `ztk/README.md` holds the BRIDGE stage's context until then. That text is real
  content and belongs in the finished README's step 2.

Who it is for: working developers, human beings. They will not read AI slop,  
impressive vocabulary, or a large documentation site.

### Who writes which part

The owner's judgement, recorded because it decides how the work is split:  
**Claude usually writes awful, non-human text.** The 3tk README was drafted by  
ChatGPT and improved by Claude, and that division worked.

The failure is specific rather than vague. Left to draft prose, Claude  
generalises where a fact belongs, adds connective tissue carrying nothing,  
summarises instead of showing, and reaches for an adjective where a measurement  
belongs. Told to be plain, it still produces competent-sounding filler — worse  
than obvious slop, because it survives review. The banned-word list of Part 5 is  
a floor, not a fix: text can clear it and still say nothing.

So the split is by what each side is reliably good at.

- **Drafting** — the owner, or another model. Voice, order, what the reader
  cares about, the mantra.
- **Material, before the draft** — Claude. The facts a section needs, the
  snippet from a file the build compiles, what differs between ztk and 3tk.  
  Bullets, not prose.
- **Checking and cutting, after the draft** — Claude. Every claim traced to a
  source, every snippet compiled, one vocabulary across every file, no dead  
  reference. And the pass it is best at: deleting what does not earn its line.

Constraints that can be checked beat instructions about quality:

- one idea per line
- no adjective without a number or a code reference behind it
- no sentence that still works when deleted
- a section opens on the reader's problem, not on a feature
- no snippet that is not copied from a file that compiles

Because most of the README is common across the family, the ztk work is a  
**difference**, not an authoring job. That suits the editor's seat rather than  
fighting it.

### What this does not change

- Every ruling in **BKP 2 — the rulings** stands.
- The three layers are written, tested and green. Documentation does not reopen
  them. A shape that reads badly in a doc comment is reported to the owner, not  
  fixed in `src/`.
- The old tree stays frozen.

---

## The module surface

Ruled by the owner on 2026-09-20, at SURFACE, after a comparison of the two
trees. This **reopens the flat-surface ruling** of **BKP 2 — the rulings**,
which said the module root is the whole public surface and nothing else is
importable. That ruling stood until the first site was built and looked at.

### What was measured, not reasoned about

The `docs` step is byte-for-byte identical in both trees and both document the
module rooted at `src/matryoshka.zig`, so the root file was the whole
difference.

- The old root exports 6 names: three `pub` namespaces, `VERSION`, `Mbox`,
  `Pool`. Autodoc gives each namespace a page of its own.
- The new root exported 23 names, all flat, each one `pub const x = file.x`.
  Autodoc listed them on one page, showed a re-exported function under its
  original name — two entries called `new` — and produced no per-module pages.
- All five of the new root's file imports were private, so **five written `//!`
  module headers were unreachable**: `inner`, `queue`, `helper`, `mbox`, `pool`.
  In the old tree the same text is the body of the three namespace pages.
- Counting calls through the module alias, and reading `examples/` as the user's
  voice, six exported names had zero or one example use: `OuterInfo` (0 calls
  anywhere outside `src/`), `UNSTAMPED` (0), `isStamped` (0), `outerAddr` (0),
  `ofNode` (1), the free `isLinked` (1). The flat root published them because a
  flat root publishes whatever a file declares; nobody had asked which of them a
  user calls.

### The rulings

1. **Namespaces per file.** The root exports `inner`, `queue`, `helper`, `mbox`
   and `pool` as `pub` namespaces. Each gets a page, and each page's body is
   that file's own `//!` header — written once, in the file it describes.
2. **No flat re-exports of what lives in a namespace.** `Slot`, `Queue`,
   `OuterHelper`, `newMbox`, `newPool`, `receiveResult`, `getWaitResult` and the
   rest are written through their namespace: `inner.Slot`, `mbox.new`,
   `pool.getWaitResult`. The two `new` collisions disappear by structure, and
   the spelling on the page is the spelling a caller writes.
3. **`Mbox`, `Pool` and `VERSION` stay flat**, beside the namespaces, exactly as
   the old root keeps them. Application code holds an `*Mbox` or a `*Pool` for
   the life of the program; that is what earns a flat name. A `Queue` does not —
   it comes out of `close` or `receiveAll`, is drained, and is gone.
4. **`OuterInfo` is internal.** It moves to `src/internal/info.zig`. `inner.zig`
   and `helper.zig` path-import it; `inner.OuterId` stays public and is the only
   spelling a caller needs.
5. **`UNSTAMPED`, `isStamped` and `outerAddr` leave the site too.** Ruled after
   the rest, the same day. `UNSTAMPED` moved to `src/internal/info.zig` beside
   `OuterInfo`; `isStamped` and `outerAddr` to a new `src/internal/stamp.zig`.
   All three had zero calls in `examples/` and zero in `negative/`, and every
   caller is inside the toolkit — the helper, the queue, the pool's stack, each
   checking an item before it takes it.

   **What it cost was one scenario, not seven tests.** The estimate of seven was
   a count of call sites, not of tests, and reading them showed most were single
   assertions in tests whose subject was something else:

   - **202 is retired** — the crossing back from a bare `*Inner` *was*
     `outerAddr`, so the scenario has no subject left. `helper.slotToAny`
     computes the same address and scenario 321 checks the result, which is why
     the behaviour is still covered. The retirement is in `task1-tests-003.md`
     with the ruling named, per that document's own rule.
   - **203 and 204 are reworded and keep their claim.** 203 reads the unstamped
     state through the helper's typed read, which answers null — which is what a
     caller actually has. 204 reads the zero offset off the inner's own id
     instead of naming `UNSTAMPED`. A field is readable through a pointer whose
     type is not nameable, so nothing was lost.
   - **Three assertions dropped as redundant.** Two in scenario 320, where
     `any.id == UNSTAMPED` sat beside `any.isEmpty()` on the next line and
     `isEmpty` is defined as that state; one in the helper's border test, which
     became `MSG.fromInner(item) != null` — the same claim, publicly.

   196 tests: 195 pass and 1 skips.

6. **Each function is documented with the type it acts on.** Ruled after the
   owner read the generated pages and found the split strange — types on one
   page, the functions that take them on another. The four border functions were
   on the `helper` page while `Slot`, `Inner` and `AnyOuter` were all on
   `inner`'s, so a reader at `Slot` had no way to move anything into or out of
   it, and a reader at `helper` found them next to a comptime generator they have
   nothing to do with.

   - `slotToAny` and `anyToSlot` became **methods on `AnyOuter`** —
     `any.moveFromSlot(&slot)` and `any.moveToSlot(&slot)`. It already had
     `set`, `reset` and `isEmpty`, so that is where a reader looks, and the
     argument order stops being something to remember.
   - `takeFromSlot` and `fillSlot` moved to `inner.zig`, beside `Slot`. `Slot` is
     `?*Inner`, an optional, so it cannot carry methods; free functions next to
     the type are the only shape, and `isLinked` and `unlink` are already that.
   - `helper.zig` is now `OuterHelper` alone, which is what its header always
     claimed.
   - `mbox` and `pool` were already this shape — a type, its `new`, its result
     reader — and they are why the asymmetry showed.

   `queue` stays a one-type page. `Queue` has a dozen methods and its page is its
   own documentation; a single-type module is ordinary in Zig, and folding it
   into `inner` would rebuild the grab-bag this stage took apart.

   **What autodoc still does on its own** is group every page into Types,
   Functions and Values sections. Nothing in the sources changes that. What the
   sources control is which page a name lands on.

   `outerAddr` fell out of use in the same move — `AnyOuter.moveFromSlot`
   computes the address itself, to avoid an `inner` to `stamp` to `inner` import
   cycle — so it was removed, and `internal/stamp.zig` is `isStamped` alone. 29
   call sites changed. Still 196 tests: 195 pass and 1 skips.

7. **The id is opaque, and null is unstamped.** Ruled last, after the owner saw
   `OuterInfo` still on the preview. `pub const OuterId = ?*const anyopaque`.

   **Why `internal/` was not enough, which corrects ruling 5's mechanism.**
   Autodoc renders what a `pub` chain from the root reaches, and **a type named
   by a published declaration is reached through that declaration's own type**.
   `OuterInfo` was already under `internal/`, and `pub const OuterId = *const
   OuterInfo` put it back on the page. A name is off the site only when no
   published declaration names it.

   **The owner's insight, which changed the shape.** `UNSTAMPED` was a real
   `OuterInfo` in read-only memory, named `<unstamped>`, and it existed for one
   reason: a Zig `*const T` cannot be 0, so an unstamped id needed something real
   to point at. An **optional** pointer can be 0. So the sentinel is not hidden —
   it is deleted, and unstamped is `null`.

   What that gives, each of it measured in all four optimization modes:

   - The zero value of an `Inner` is unstamped, so zeroed memory —
     `std.mem.zeroes`, a `@splat` of `.{}`, a calloc'd array — is a valid
     unstamped outer rather than an accidental one.
   - `@sizeOf` is unchanged. An optional pointer is pointer-sized, so `Inner` is
     still 16 bytes and CORE's measurement holds.
   - Identity is unchanged: distinct types keep distinct ids, including two types
     of identical shape and offset, and the same type answers the same id. The
     cast changes the type the compiler sees, never the address.
   - A missed check **faults** instead of lying. The sentinel's zero offset made
     the crossing back return the inner's own address — a plausible pointer that
     corrupts later. A null id faults at `infoOf`. In the safe modes nothing
     changed: the border check fires first, with its own message.

   **Why `?*const anyopaque` and not the alternatives**, all four probed rather
   than argued:

   - `usize` was rejected. It hides as much and reads as simply, but a `usize` is
     what half this API already traffics in — `countOf` returns one, `sendLimited`
     takes a limit — so `pool.countOf(n)` with a count would compile and ask the
     pool about an identity that is really a number. The pointer type rejects it.
   - `?*const Identity`, an `opaque {}` handle, rejects *every* wrong argument,
     including another pointer: `countOf(item)` with an `*Inner` fails to
     compile, where `?*const anyopaque` accepts it. It costs one empty type on
     the page. The owner chose `anyopaque`: nothing about identity appears at
     all, and user code never constructs an id, which was measured — no example
     or negative program builds one, and none reads a field off one.
   - The non-optional forms keep the sentinel object, so they miss the point.

   `isStamped` and `outerAddr` are gone as names: the first is `item.id != null`
   at its two remaining call sites, so `internal/stamp.zig` went with it, and the
   second was absorbed by `AnyOuter.moveFromSlot`. `OuterInfo` stays, internal and
   unchanged, beside the one function that reads it.

   **Two scenarios retired**, both recorded in `task1-tests-003.md` with the
   ruling named: **202**, whose subject was `outerAddr`, and **204**, which
   measured the sentinel's zero offset and the near miss it produced — neither
   exists now, and the refusal 204 guarded is negative program 321. **201** and
   **203** keep their claims, read the way a caller reads them: the crossing
   lands on the outer, and a declared or zeroed outer's id is null.

   195 tests: 194 pass and 1 skips.

8. **The second test root is dropped.** `src/internal_tests.zig`, the five test
   blocks in `src/internal/stack.zig` and their fixtures, and the `imod` /
   `src_tests` entries in `build.zig`. Every property those tests asserted is
   asserted through the pool's public surface — scenario 289 was implemented
   twice, in two binaries, and `task1-tests-002.md` asks for it once.
   `InnerStack` has exactly one caller, `pool.zig`, so testing it through that
   caller is complete coverage, not partial. `src/` is now nine toolkit files
   and the shipped `sources.tar` no longer carries a test root.

### What web visibility is, and what it is not

The owner's need was stated exactly: **restrict what the generated site shows**,
not what a caller can reach. Two facts settle how that is done.

- Autodoc has **no hide attribute**. It renders the declarations reachable from
  the root it is given by an unbroken chain of `pub` — precisely the set user
  code can name. Documented and reachable are one set, by construction.
- A file under `src/internal/` is `pub` for the toolkit and reachable by path
  import, but no `pub` chain from the module root reaches it, so it has no page
  and user code cannot name it. `internal/check.zig` has worked this way since
  CORE.

So **hiding is per file, under `src/internal/`** — the mechanism this tree
already used. Two alternatives were designed and rejected in the same session:

- **A second, curated docs root** (`src/docs_root.zig`, with the docs object
  rooted there and a gate keeping it in step). It gives per-name control and
  costs nothing in calls or tests. Rejected once the namespace split landed:
  with `OuterInfo` moved to `internal/`, it would have withheld an empty list,
  and it is a second root file plus a gate to keep honest. **A docs root may
  only withhold names, never re-shape them** — a page that says
  `matryoshka.inner.Slot` while a caller writes `matryoshka.Slot` is a
  documentation that lies. If curation is ever wanted again, that constraint is
  the first thing to carry forward.
- **Stand-in namespaces** in such a root, listing published names one by one.
  Rejected: the page body would come from the stand-in rather than from the
  file's `//!` header, so the module prose would live in two places, and
  COMMENTS needs one.

### What this does not change

- Every other ruling in **BKP 2 — the rulings** stands. The model, the identity,
  the link test, `create` running the item's own `init`, Outer and Inner.
- No behaviour changed. The rewrite is a spelling change at 690 call sites in
  `tests/`, `examples/`, `negative/` and the README material, plus the root, and
  the six gates are green on both sides of it.
- The old tree stays frozen.

---

## Open questions

The first four were answered by the owner on 2026-09-19. See **Owner rulings after BKP 1**.  
None of the rest blocks BKP 2.

- **Order.** Answered: R3. BKP was named ahead of the PARKED WORK in `design/STATUS.md`. Does any of that work run before an apply stage?
    - New from BKP 1: two parked items touch rows here. `polynode` audit touches IT1 and LS1. The `pool.zig` fmt line is Z6.
    - From BKP 2: Z6 is now ruled and belongs to BKP 3. The `polynode` audit is overtaken by BKP 5 and BKP 6, which rewrite the file.
- **Owner edits.** ztk `src/*.zig` doc comments carry the owner's own edits. How does an apply stage treat them?
    - New from BKP 1: PL2 and LS4 change doc comments in `src/pool.zig`. MB2 and MB3 change the `destroy` comments.
    - From BKP 2: released for Z6 only, which the owner told BKP 2 to fix. The rest still stands — ask before rewording.
- **New from BKP 2: `finish`.** The field is in `OuterDesc` and marked re-think. Whether the toolkit calls it is reopened when HP1 lands, in BKP 7.
- **New from BKP 2: `destroy_slot`.** Kept by MB2's ruling, with a re-think note. It would take no allocator once `destroy` is a method.
- **New from BKP 2: `magic`.** Reserved in `OuterDesc` for a C border that does not exist yet. Nothing is added until a caller does.
- **New from BKP 2, for 3tk, not ztk.** No `on_close` doc comment in `3tk/src/pool.c3` says it can be called more than once; only the spec does. No 3tk example shows the second call. Reported, not fixed.
- **New from SURFACE, and answered the same day: three internals on the web.**
  The owner ruled `UNSTAMPED`, `isStamped` and `outerAddr` off the generated site.
  See ruling 6 in **The module surface**.
- **Example numbers.** Answered by BKP 1.
    - Neither candidate holds a map. `3tk-port-findings-005.md` has none. The 3tk log has none. The 3tk example files name no ztk file.
    - The pairing table above is the first map. It lives here.
- **Old versions.** Answered: R4.
- **New: MB1 against INTR 8.** Answered: R1.
- **New: IT1 and std.** Answered: R2.
- **New: 3tk-port-findings-005.md.** Its ztk citations are old. BKP 1 checked every one it used, and they still hold. It is cited here as *F§*, for reasons only.

---

## How to continue after a clear

The work is in the new tree now, so a session starts from that tree's own  
documents. This one is read for the rulings.

**The prompt is three lines, and it lives in the staging plan**, under **How to  
continue after a clear**. It names this file only through `next-status.md`'s  
reading list, so it cannot go stale the way the long prompt here did — that  
prompt named `next-staging-plan-004.md` for as long as 005 stood, while the live  
plan reached 013.

```
Read design/secondary/lang/port/3tk-to-ztk/next/next-status.md and follow
Start here.
Run <STAGE>. <MODEL>.
```

Name the stage, and one only. The new tree's stages are a menu, not a queue.  
The models are in the plan's stage table.

This document is read for the rulings: **BKP 2 — the rulings**, **The direction  
change**, **The documentation direction**, and **The module surface**, which
replaces one ruling of BKP 2.
