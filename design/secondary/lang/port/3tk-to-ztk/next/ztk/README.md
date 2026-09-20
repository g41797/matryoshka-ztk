# matryoshka-ztk

The rewritten toolkit. This file stores the context for the README that DOCS  
writes. It is not the README yet.

## The bridge

The toolkit does not replace the io side. It sits beside it.

- The io side has its own queue and its own types.
- Matryoshka has outers, a pool and a mailbox.
- The bridge is the point where an outer crosses to the io side and back.

An outer crosses as an `AnyOuter`.

- `any.moveFromSlot(&slot)` moves the outer into an `AnyOuter`, before a put.
- `any.moveToSlot(&slot)` moves it back into a Slot, after a get.
- `fromAny` tells the receiver whether it is its own type.
- An `AnyOuter` is moved, never copied.

## The working code

`examples/bridge/104-server_handler_and_workers.zig`, tested by  
`tests/examples_bridge.zig`. Run it alone with `zig build examples-bridge`.

- The queue carries `Msg`: `request` from the io side, `reply` as an
  `AnyOuter`, and `stop`.
- A handler dispatches on the tag.
- A request becomes a greeting from the pool, sent to a shared mailbox.
- Workers receive from the mailbox and reply through the queue.
- "Hello, Matryoshka!" goes in, "Hello, Io" comes out.

## Steps for a reader

The order the README follows, from 3tk's "How to start".

1. One thread, one struct. An `Inner` in your struct, a helper, a `Queue`.
2. Add a thread. Send outers over `Io.Queue(AnyOuter)`.
3. Add a pool, when repeated allocation becomes a problem.
4. Replace the channel with a mailbox, when the channel stops being enough.

What the mailbox adds to a channel:

- no allocation on transfer
- `close` gives back what was queued
- timeouts, `wakeUpAll`, sending to the front, a per-type limit

If the channel already does what you need, keep it.
