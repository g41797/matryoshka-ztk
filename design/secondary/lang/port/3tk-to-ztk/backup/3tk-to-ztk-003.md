# 3tk to ztk — the backport (003)

Written 2026-09-19, stage BKP 1.

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
| stage menu | `design/matryoshka-ztk-implementation-plan-NNN.md`, section BKP |

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
| **BKP 2** | **The owner rules** on the rows. Apply groups and their order derived from the rulings. `lang/common` spec gets a new version. | Opus 5 |
| **BKP 3+** | **Apply groups** in ztk: code, tests, examples, docs, under the ztk gates. Each ends with a common-layer update. | Opus 5 when deciding. Sonnet 5 for mechanical edits across many files. |
| **BKP AUDIT** | The big-bang audit. | Opus 5 |

Every stage:

- starts after a `/clear`, from these files alone
- ends with the prompt to continue, and the model to use
- follows `design/rules-049.md` Part 0 and `matryoshka-3tk/design/3tk-rules-007.md` Part 2

**The rows for BKP 2, in the survey's order.** Every row marked *to owner*.

- High: PL2, PL3.
- The model: IT1 with LS1 and LS2, IT3, IT4, HP1, HP3.
- Creation and release: MB1 with PL1, MB2, MB3 with PL8, MB4.
- New API: MB5, PL7, PL4.
- Removed API: PL6, MB12.
- Style and docs: TK2, MB11, LS4, TK3, HP4.
- Z1 to Z6.

This is the survey's order, not an apply order. BKP 2 derives that.

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

## Open questions

The first four were answered by the owner on 2026-09-19. See **Owner rulings after BKP 1**.  
None of the rest blocks BKP 2.

- **Order.** Answered: R3. BKP was named ahead of the PARKED WORK in `design/STATUS.md`. Does any of that work run before an apply stage?
    - New from BKP 1: two parked items touch rows here. `polynode` audit touches IT1 and LS1. The `pool.zig` fmt line is Z6.
- **Owner edits.** ztk `src/*.zig` doc comments carry the owner's own edits. How does an apply stage treat them?
    - New from BKP 1: PL2 and LS4 change doc comments in `src/pool.zig`. MB2 and MB3 change the `destroy` comments.
- **Example numbers.** Answered by BKP 1.
    - Neither candidate holds a map. `3tk-port-findings-005.md` has none. The 3tk log has none. The 3tk example files name no ztk file.
    - The pairing table above is the first map. It lives here.
- **Old versions.** Answered: R4.
- **New: MB1 against INTR 8.** Answered: R1.
- **New: IT1 and std.** Answered: R2.
- **New: 3tk-port-findings-005.md.** Its ztk citations are old. BKP 1 checked every one it used, and they still hold. It is cited here as *F§*, for reasons only.

---

## How to continue after a clear

**BKP 2 — Opus 5, after `/clear`:**

```
Read design/STATUS.md, then
design/secondary/lang/port/3tk-to-ztk/3tk-to-ztk-003.md in full, then the
BKP section of design/matryoshka-ztk-implementation-plan-076.md.
Read design/rules-049.md Part 0 and matryoshka-3tk/design/3tk-rules-007.md Part 2.
Sources are the truth: ztk src/, 3tk design/secondary/lang/c3/3tk/src/.
Git is disabled. Run BKP 2: take the owner's rulings on the survey rows,
one group at a time, then derive the apply groups.
```
