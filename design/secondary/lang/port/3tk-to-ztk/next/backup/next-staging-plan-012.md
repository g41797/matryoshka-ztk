# next — staging plan (012)

Written 2026-09-20, by the SETUP stage. This is 012, after FUTURES,
2026-09-20.

Change from 011, after FUTURES: the FUTURES charter is marked done.
`Pool.Result`, `getWaitResult` and `Pool.getWaitFuture` are written, the ten
waiting examples are ported, and the owner's ruling removed the safe-build
check on an unknown identity: `get`, `getWait`, `put` and `countOf` return
`error.UnknownIdentity` in every build. 201 tests, 200 pass and 1 skips. The
continue prompt is BRIDGE. 011 is in `backup/`.

Change from 008, before DOCS: two stages are added, ANY and BRIDGE, on the
owner's ruling. The README of 3tk makes the bridge to the I/O side part of the
process (the README of the 3tk repository, "How to
start", step 2), and ztk had no counterpart. Read it before either stage.
The continue prompt is ANY. 008 is in `backup/`.

Change from 007, after EXAMPLES: the EXAMPLES charter is marked done and
carries what the stage did. 69 example files, 64 example tests, 179 tests in
all. Nine old examples wait for the pool's futures, five were dropped for
removed APIs, and six new ones were added. One finding for the owner: a put of
an unknown identity panics in safe builds. The continue prompt is DOCS.
007 is in `backup/`.

Change from 006, after POOL: the POOL charter is marked done and carries what
the stage decided — `countOf` refuses an unknown identity the way every other
call does, the futures are left to the task2 stage, the containers declare
`init` and `finish` **privately**, and `src/` grew a test root of its own.
No question is open. The continue prompt is EXAMPLES. 006 is in `backup/`.

Change from 005, after ENV: the ENV stage is marked done. `init`, `finish`,
`create`, `destroy` and `newMbox` take `(alloc, io)` in that order. The test
count is unchanged, 80 pass and 1 skips, and the six gates are green. The
continue prompt is POOL. 005 is in `backup/`.

Change from 004, before POOL. The session that was told to run POOL read the
sources first and brought back three findings the owner ruled on. No code was
written.

- **The pool's store is a stack, not a queue.** Checked in 3tk and confirmed:
  `PoolBucket { typeid tag; InnerStack free; }`, and `InnerStack` is its own
  internal type. The buckets are a plain array scanned linearly. So POOL writes
  `src/internal/stack.zig`, touches no layer-1 file, and the two hash maps of
  the old tree are gone along with the separate count. The POOL charter below
  is rewritten around it.
- **`on_put` takes the extra as an out-parameter**, matching 3tk. The PL5 row
  called that a language difference and it is not one.
- **A new stage, ENV, runs before POOL.** `init` and `finish` take an `Io`
  beside the allocator. Zig 0.16 split the environment in two and the toolkit
  was passing half of it. Sonnet 5.

Five more questions are answered and moved under **Answered**, numbered 12 to
16. **No question is open.** The continue prompt is ENV, then POOL. 004 is in
`backup/`.

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
| **ENV** | `init` and `finish` take the `Io` beside the allocator. A signature change and every call site that follows it. No new behaviour. DONE 2026-09-20. | Sonnet 5 |
| **POOL** | The pool, with its rulings. Implementation and tests. DONE 2026-09-20. | Opus 5 |
| **EXAMPLES** | The examples module, and the examples ported from the old tree. DONE 2026-09-20. | Sonnet 5 |
| **ANY** | `AnyOuter`, the type-erased carrier, and the pair that crosses it. Implementation, tests and negative programs. Sonnet 5. | Sonnet 5 |
| **FUTURES** | The pool's `getWaitFuture`, `getWaitResult` and `Result`, and the ten examples that wait for them. DONE 2026-09-20. | Sonnet 5 |
| **BRIDGE** | A new group of examples, written for the README: outers over `Io.Queue` and into a mailbox and back. | Sonnet 5 |
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

## ENV — done

**Why it exists.** `create` calls `item.init(allocator)`, and `destroy` calls
`out.finish(allocator)`. In Zig 0.16 that is half the environment. std moved
file, net, time and concurrency behind `Io`, so the outer a pool exists for — a
connection, a socket, a buffered stream — cannot release itself in `finish`
with an allocator alone.

**Where the reasoning first went wrong, recorded so it is not repeated.** The
session's first answer was *an outer that needs an `Io` writes its own
constructor, the way `Mbox` does*. The owner rejected it, and the rejection is
the useful part: `Mbox` and `Pool` are the toolkit's own containers. They
allocate themselves, declare no `init` and no `finish`, and were never going to
call `create`. Reasoning from them says nothing about a user's outer, which is
the only case that matters here.

**Two arguments for waiting that turned out to be wrong.**

- *It hands an `Io` to every outer that never uses one.* The toolkit already
  passes an allocator to outers that allocate nothing. `_ = io;` costs what
  `_ = alloc;` costs, and "an empty body is fine" stays true.
- *It can be added later.* The opposite of question 3's deferred `finish`
  field. A new field of `OuterInfo` touches the helper and no user code;
  `init`'s signature is every outer anyone has written. The asymmetry says
  decide now, and now is cheap — this tree has ten test outers and no users.

**The signatures.**

```zig
pub fn init(self: *Outer, alloc: std.mem.Allocator, io: Io) !void
pub fn finish(self: *Outer, alloc: std.mem.Allocator, io: Io) void

pub fn create(allocator: std.mem.Allocator, io: Io, slot: *Slot) !void
pub fn destroy(allocator: std.mem.Allocator, io: Io, slot: *Slot) void
```

**The order is std's, and it was measured.** In `lib/std` of 0.16, a function
taking both puts the allocator first 12 times and the `Io` first 3 times. The
three are `process.currentPathAlloc(io, allocator)` and its two neighbours,
where the `Io` is the subject of the call and the allocator is where the result
lands — a different shape, not a competing convention. Every `self` method in
std that takes both puts the allocator first, and one of them is this exact
case: `std.Build.Cache.Directory.closeAndFree(self, gpa, io)`.

**The containers flip with them.** Owner's ruling. `newMbox(io, alloc, slot)`
becomes `newMbox(alloc, io, slot)`, and the pool's `new` is written that way
from the start. One order in the toolkit, and it is std's.

**What the stage touches.** `helper.zig` — the two calls and the two
`@compileError` messages. `mbox.zig` — the argument order of `new`. Ten outers
in `tests/outers.zig`. The `create` and `destroy` call sites in the four test
files. Negative programs 308 and 309, whose expected messages change.

**The doc comment this earns.** 3tk's `init` and `finish` take an allocator
because C3 has no `Io`; ztk takes both because 0.16 split the environment in
two. That is a language difference, so it is written on `create` as a note,
once, rather than left for a reader to find as an unexplained divergence. With
it, the sentence 3tk's own `create` carries: the allocator is passed to your
hook and the toolkit does not keep it.

**A MUST that goes with it.** An outer that keeps an `Io` in a field must not
outlive the runtime that produced it. `Mbox` keeps `_io` already, so the tree
has taken that trade; it is said out loud here rather than discovered.

**What ENV does not do.** No new behaviour, no new test scenario, no change to
what any call means. Six gates green, and the test count unchanged.

**Why Sonnet 5.** Every decision above is made. What is left is a mechanical
change with a compiler and six gates saying when it is wrong. Rule 10's case
for asking for the weaker model, said rather than passed over.

---

## POOL — done

**Contents.** PL1, PL2, PL3, PL4, PL5, PL6, PL7, PL8 and the narrowed error
sets.

**Read `3tk/src/pool.c3` before writing anything.** This charter was rewritten
from it, and the paragraphs below name line numbers so a reader can check them
rather than take them.

**The store is a stack.** Owner's ruling, confirmed against the source.
`pool.c3:477` is `PoolBucket { typeid tag; InnerStack free; }`, and
`InnerStack` at `:541` is a type of its own, declared in `mtk::pool::internal`
and not part of the public API. So:

- POOL writes `src/internal/stack.zig` — `push`, `pop`, `isEmpty`, `len`, and
  the same insert guard `Queue` has. It is internal, reachable from `pool.zig`
  only, and is **not** re-exported from `matryoshka.zig`.
- The last item of a stack points at itself, the way the last of a queue does
  (`inner.repoint_to(self.top ? self.top : inner)`), so the exact link test
  holds on both and `pop` clears the link before the item leaves.
- `queue.zig` is not touched, and neither is any other layer-1 file. LS4's
  "prepend, and write down why it is LIFO" is answered better by the type: a
  stack is last in, first out because that is what a stack is. The reason still
  goes in the doc comment — a stale writer meets the next owner at once.
- **The queue stays at the border.** `_close` empties every bucket's stack into
  an `InnerQueue` and `on_close` takes that by value (`pool.c3:493-507`). Stack
  inside, queue out.

**The buckets are an array, scanned.** `bucket_for` at `pool.c3:484` walks
`_buckets` and compares. No hash map, and no second map of counts: `in_pool` is
`b.free.len()`, read off the stack itself (`:214`, `:295`). Both of the old
tree's `AutoHashMapUnmanaged` fields are gone, and the duplicate-identity check
falls out of building the array.

**The two rulings that matter most.** A put that is still running when the pool
closes gives everything it still has to the close hook, so no item is lost —
which means the hook can be called a second time, at the same time as the
first, and its own documentation must say so. And the get hook is reached only
when nothing is stored, so its Slot is always empty; the capped hook and the
recycling hook both move their work to the put hook.

**The close-on-put path, as 3tk writes it** (`pool.c3:305-328`). `put` takes
the item out of the caller's Slot **before** the hook runs, so on this path the
caller's Slot is empty and the item is not given back. If the pool closed while
the hook ran, the call builds a queue of its own — the item it took, then
everything the hook added — unlocks, and calls `on_close` with it. It holds
`_active` across that second call and drops it only after relocking, so a
`destroy` racing it aborts. That is PL8's guard and PL3 agreeing.

**The hooks.**

```zig
on_get(ctx, id, in_pool_count, slot: *Slot) void
on_put(ctx, in_pool_count, slot: *Slot, extra: *Queue) void
on_close(ctx, remaining: Queue) void
```

- `extra` is an **out-parameter**, matching `pool.c3:455`. The PL5 row called
  this a language difference; it is not one, Zig writes it the same way, so the
  standing rule gives it to 3tk. It also keeps the hook from holding a `Queue`
  value that a second copy could take.
- `on_close` takes the queue **by value** (PL4), so after the call there is no
  way back to the items.
- **No hook takes an `io`.** Owner's ruling: a hook's implementation carries
  whatever it needs in its own `ctx`, and that is the hook's business, not the
  toolkit's. 3tk's signatures are kept exactly.

**`put` reports one failure and not the other.** `error{UnknownIdentity}!void`.
An identity the pool was not created with is PL7 and is an error return in
every build, plus the safe-mode check — that ruling goes past 3tk, whose `put`
swallows it (`pool.c3:293`), and a ruling is not reopened by writing code. A
pool already closed on entry stays **silent**, with the caller's Slot untouched
(`pool.c3:288`, task1 scenario 77): 3tk had the option of a fault there and did
not take it, and nothing about that is a language difference. The doc comment
gives the reason for the pair — an unknown identity is a caller's mistake about
the pool's own shape, a closed pool is a race the caller cannot avoid.

**The rest.** The identities are a separate argument, and a duplicate or an
empty set is refused by `check`, in safe builds (PL1). The batch put is gone
(PL6). `isClosed`, `isIdle` and `countOf` become public (PL8). The call counter
and the `destroy` guard are copied from `mbox.zig` as they are, and `isIdle`
carries the same mutex MUST — which matters more here, because a hook is caller
code running inside a call, so a hook that asks `isIdle` deadlocks.

**What it writes.** `src/internal/stack.zig` and its tests first, then
`src/pool.zig`. `tests/layer3_pool.zig` and `tests/layer3_threads.zig` for
task1 scenarios 63 to 88 and 280 to 291, with the hook fixtures in a new
`tests/hooks.zig`. Negative programs 311 and 313.

**What the stage decided, on the owner's rulings of the same day.**

- **`countOf` is `error{UnknownIdentity}!usize`.** 3tk answers 0 there
  (`pool.c3:387`) and PL7 had only reached `get`, `getWait` and `put`. A
  query with no error channel was the one place left where a wrong identity
  looked like an empty store. Now the whole surface answers it one way, in
  every build, with the safe-mode check beside it.
- **The futures are not written here.** PL10 keeps `getWaitFuture`,
  `getWaitResult` and `Result` as std surface, and their scenarios are
  task2's. They go at the end of `pool.zig`, beside where `mbox.zig` keeps
  `receiveResult`, and never in the module header. POOL wrote `getWait` and
  stopped there.
- **`Mbox` and `Pool` declare `init` and `finish`, and both are private.**
  Owner's ruling. Answer 10 left the containers with no declaration at all
  and rested on Zig analysing a generic struct lazily. Now the declaration is
  there to be read, and privacy keeps what lazy analysis was giving:
  `@hasDecl` cannot see a private declaration from `helper.zig`, so
  `OuterHelper(Mbox).create` in a user's own file still does not compile.
  Both halves were measured before the edit, and the measurement is why it
  is private rather than public — see the log.
- **`src/internal_tests.zig`, a second test root.** An internal type is not
  reachable from the module root, so the `tests/` tree cannot reach
  `InnerStack` at all. A file two imports deep from a test root contributes
  no test blocks — measured, 0 tests — so the internal stack gets a root of
  its own and `zig build test` runs both. The kitchen scripts did not change.

**What POOL wrote.** `src/internal/stack.zig` with five tests of its own,
`src/pool.zig`, `tests/hooks.zig`, `tests/layer3_pool.zig`,
`tests/layer3_threads.zig`, and four negative programs: 311, 313, and two for
286, because one scenario broken two ways cannot be one program that dies
once.

**The largest stage.** The close-on-put path depends on the counter from MBOX
and on the by-value queue.

---

## EXAMPLES — done

**What it wrote.** `ztk/examples/`: the four demo outers, two hook sets, the
`IdTable` (the old `TagTable`, keyed by `OuterId`), and 69 files in four layer
folders. The build got an `examples` module and six steps,
`examples-layer1` to `examples-layer4c`, so a group builds alone. Test
wrappers are `tests/examples_*.zig`. Layer 4 is three parts, `part_a` to
`part_c`.

**New examples.** 098 border pair, 099 refused send, 100 send limit, 101
refused put, 102 composite parts, 103 infrastructure wrapper.

**Dropped, for removed APIs.** 029, 034, 040, 062 (batch put) and 039 (a plain
std list).

**Waiting for the pool's futures** — `getWaitFuture` and `getWaitResult` are
not written. Not ported, no stubs: 028, 031, 046, 047, 048, 050, 056, 058, 060,
061. They come back with the futures. 057 ported, because it calls `getWait`
only.

**Reported to the owner, not changed.** `Pool.put` with an unknown identity
calls `check` first, so in a safe build it panics instead of returning
`error.UnknownIdentity`. The doc comment and PL7 say the error is returned in
every build. Example 101 shows the error only where safety is off.
Separately, `std.SinglyLinkedList.popFirst` leaves the link set, so 098 clears
it by hand before `fillSlot`.

**Tests need a real `Threaded`.** `global_single_threaded` gives
`ConcurrencyUnavailable` for `io.concurrent`. Only 052 keeps it, on purpose.

**Old charter, kept for the record.**

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

## ANY — done

**Why.** Zig has no `any`. A queue that std or the user owns carries a value
the toolkit does not know, and often a tagged union: `Io.Queue(union(enum) {
outer: AnyOuter, quit, ... })`. A receiver gets `ptr` and `id`, compares the
id with its own type's id, and has its struct without knowing the toolkit. 3tk
has the same thing, `to_any` and `to_slot`. **Read `3tk/src/helper.c3` for both
before writing** so the semantics are a port and not a reinvention.

**Owner's rulings, 2026-09-20.**

1. The pair is two free functions in `helper.zig`, `slotToAny(slot, *AnyOuter)`
   and `anyToSlot(*AnyOuter, slot)`, beside `takeFromSlot` and `fillSlot`. The
   per-type helper adds a typed read, `fromAny`, that returns null on a wrong id,
   like `fromSlot`.
2. The fields are `ptr` and `id`. Not `otrptr` and `otrid`.
3. `ptr` is the **outer's** address, not the inner's. The id carries the offset
   to the inner.

**The shape.** `AnyOuter` lives in `inner.zig` beside `Slot` and is exported
from `matryoshka.zig`. `ptr: ?*anyopaque = null`, `id: OuterId = UNSTAMPED`.
Two inline methods, `set` and `reset`, and `isEmpty`. The invariant: `ptr` is
null exactly when `id` is `UNSTAMPED`, and `set` checks it.

**The checks.** Entering an `AnyOuter` empties the Slot, and requires the outer
stamped, unlinked and the `AnyOuter` empty. Leaving requires an empty Slot,
fills it, empties the `AnyOuter`, and requires it stamped.

**MUST.** An `AnyOuter` is moved, never copied — two copies are two owners, the
rule `Queue` carries. A container closed while it still holds `AnyOuter` values
leaks them, so the caller drains it. A raw cast of `ptr` loses alignment.

**What it writes.** The type, the pair, `fromAny`, scenarios in
the next version of task1-tests (a new version, the old to `backup/`), tests,
and negative programs for the entry into a full `AnyOuter`, an unstamped outer
and a linked one.

**Why Sonnet 5.** The decisions are made above and the gates say when it is
wrong.

---

## FUTURES — done

PL10 keeps `getWaitFuture`, `getWaitResult` and `Result`; their scenarios are
task2's. They go at the end of `pool.zig`, beside `receiveResult` in
`mbox.zig`. Then the ten examples that waited for them are ported from the old
tree: 028, 031, 046, 047, 048, 050, 056, 058, 060, 061. Tests before examples,
as always.

**What it wrote.** `Pool.Result` (`item`, `closed`, `timeout`, `canceled`,
`unknown_identity`), `getWaitResult` beside `receiveResult`'s counterpart at
the end of `pool.zig` and exported from the module root, `Pool.getWaitFuture`,
`tests/layer4_pool_futures.zig` (six tests), and the ten examples in
`examples/layer4/`. task2-tests is at -002 with scenarios 209 and 210.

**Owner's ruling.** The checks that stopped a safe build on an unknown
identity in `get`, `getWait`, `put` and `countOf` are gone, so PL7 holds in
every build. Test 285 and example 101 no longer skip in safe builds. The check
on a put hook giving back an unknown identity stays: no caller is left to
receive an error.

**Why Sonnet 5.** The shape is `receiveResult`'s, already written.

---

## BRIDGE — examples for the README

A new group, `examples/bridge/`, written for a reader of the README. 3tk's
`shc::l_bridge` is the model. Each is small and shows one idiom.

- Outers over `Io.Queue(AnyOuter)` from a producer into a mailbox, and back.
- **Secondary, and labelled so:** a tagged union in the queue with `AnyOuter`
  as one variant, and a receiver that dispatches on the tag and then on the id.
  It is for a queue the caller already has and cannot change. 3tk's README
  lists "a tag plus a union of every message" among the workarounds the toolkit
  exists to avoid, because the queue changes with every feature. The main
  examples carry `AnyOuter` alone.
- The step-4 progression: the same flow with the channel replaced by a mailbox,
  and what the mailbox adds — no allocation on transfer, `close` handing back
  what was queued, timeouts.
- A refused crossing: an unstamped outer and a linked one.

The examples module already has a group step per layer; the group gets its own,
`examples-bridge`, and a wrapper `tests/examples_bridge.zig`.

**Why Sonnet 5.** Same as EXAMPLES.

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
CORE itself, one by MBOX, five more by the POOL design session the same day,
and three by POOL as it was written — answers 17 to 19. Each was checked against the sources rather than reasoned about.

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

12. **The pool's store is a stack, not a queue.** Owner's ruling, 2026-09-20,
   confirmed in 3tk before it was written down. `PoolBucket` carries an
   `InnerStack`, an internal type of its own, and the buckets are a plain
   array. POOL writes `src/internal/stack.zig` and touches no layer-1 file.
   The queue keeps its place at the border, where `on_close` takes one by
   value. See the POOL charter for the line numbers.

13. **`on_put` takes `extra` as an out-parameter.** `pool.c3:455`. The PL5 row
   filed this as a language difference and it is not one — Zig writes the
   out-parameter as readily as the return — so the standing rule gives it to
   3tk. A hook that never holds a `Queue` value is also a hook that cannot
   copy one.

14. **`put` is `error{UnknownIdentity}!void`, and says nothing about a closed
   pool.** PL7 stands over 3tk, which swallows the unknown identity. The
   closed pool stays silent because 3tk chose silence there with a fault
   available two calls earlier, and that choice is not a language artifact.

15. **`init` and `finish` take `(alloc, io)`, in that order, and the
   containers follow.** Owner's ruling, 2026-09-20. Zig 0.16 split the
   environment in two, and a pooled `Io` resource cannot release itself in
   `finish` with an allocator alone. The order is std's, measured: 12 to 3 for
   the allocator first, and every std `self` method that takes both agrees.
   `newMbox` flips to match. This is the ENV stage, and it runs before POOL.

16. **No hook takes an `io`.** Owner's ruling: a hook's implementation carries
   both the allocator and the `Io` in its own `ctx`. 3tk's three hook
   signatures are kept as they are.

17. **`countOf` refuses an unknown identity**, rather than answering 0 the
   way 3tk does. PL7's reasoning reaches the query too: an identity the pool
   was not made with is a caller's mistake about the pool's own shape, and a
   count of zero is indistinguishable from an empty store.

18. **The pool's futures wait for task2.** PL10 keeps them; POOL does not
   write them. They belong at the end of `pool.zig`, not in the module
   header.

19. **A container declares `init` and `finish`, privately.** Owner's ruling,
   2026-09-20. It replaces answer 10's mechanism without replacing its
   promise: `helper.zig` cannot see a private declaration, so a user file
   that asks `OuterHelper(Mbox)` for `create` still fails to compile, with
   the message that names what is missing.

Answered already, and not reopened by writing code: every ruling in  
[../3tk-to-ztk-005.md](../3tk-to-ztk-005.md) under **BKP 2 — the rulings**.

---

## How to continue after a clear

Three lines. `next-status.md` carries the reading list under **Start here —
every session**, so a prompt that repeats it is a copy that goes stale.

**BRIDGE:**

```
Read design/secondary/lang/port/3tk-to-ztk/next/next-status.md and follow
Start here.
Run BRIDGE. Sonnet 5.
```

Every later stage is the same three lines with its own name and model. The
models are in the stage table above.

**What EXAMPLES must not re-decide.** All three layers are written and green.
The examples show the toolkit; they do not change it. A shape that reads badly
in an example is reported to the owner, not fixed in `src/`.

**What EXAMPLES inherits.** The examples module enters the build there and not
before — that is what has kept every stage's tests free of it.

**ANY is not started by finishing EXAMPLES.** Stop and ask. BRIDGE follows ANY, then DOCS.

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
