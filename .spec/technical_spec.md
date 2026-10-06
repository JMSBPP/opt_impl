# Technical Specification: opt_impl

**Status:** Draft 0 — algebra first
**Method:** Algebra-Driven Design
**Implementation target:** Idris 2

## 0. Purpose

`opt_impl` is a standalone daemon/library that gives AI agent sessions durable,
directory-independent memory using an OptChat-style append-only event log and
compressed binary summary tree.

The technical design is expressed first as algebras. Concrete storage, daemon
transports, and model-provider implementations must preserve these laws.

---

## 1. Event Log Algebra

### Types

```text
MessageId        -- stable zero-based index into the event log
Timestamp        -- local/UTC timestamp attached at append time
Kind             -- user | talk | tool | echo | note | work
Payload          -- verbatim text payload, excluding model thoughts
Event            -- { id, kind, text, size, timestamp }
Log              -- finite append-only sequence of Event
```

### Operations

```text
emptyLog       : Log
append         : Log -> Kind -> Payload -> Timestamp -> Log
size           : Log -> Nat
get            : Log -> MessageId -> Maybe Event
ids            : Log -> List MessageId
```

### Laws

```text
size(emptyLog) = 0
size(append(log, k, p, t)) = size(log) + 1

get(append(log, k, p, t), id) = get(log, id)        when id < size(log)
get(append(log, k, p, t), size(log)) = Event(size(log), k, p, bytes(k,p), t)

ids(log) = [0 .. size(log)-1]
```

### Invariants

- Event IDs never change.
- Append never edits or deletes previous events.
- Thoughts/reasoning are not valid `Kind` values and must not enter the log.
- Tool results may be capped before append, but the capped text is then the exact event payload.

### Idris Classification

- `MessageId < size(log)` should be checked at API boundaries.
- Append-only behavior is an operational/storage invariant.
- Kind exclusion is a type-level invariant.

---

## 2. Range and Node Address Algebra

### Types

```text
Width           -- positive power of two
Start           -- MessageId aligned to Width
Range           -- { start : MessageId, width : Width }
Level           -- Nat where width = 2^level
NodeIndex       -- Nat where start = index * width
Address         -- rendered as start+width
```

### Operations

```text
widthOf       : Level -> Width
rangeOf       : Level -> NodeIndex -> Range
levelOf       : Width -> Maybe Level
aligned       : MessageId -> Width -> Bool
end           : Range -> MessageId
contains      : Range -> MessageId -> Bool
leftChild     : Range(width > 1) -> Range
rightChild    : Range(width > 1) -> Range
parent        : Range -> Maybe Range
```

### Laws

```text
end(r) = r.start + r.width
contains(r, id) = r.start <= id < end(r)

leftChild(r).start = r.start
leftChild(r).width = r.width / 2
rightChild(r).start = r.start + r.width / 2
rightChild(r).width = r.width / 2

coverage(leftChild(r)) ∪ coverage(rightChild(r)) = coverage(r)
coverage(leftChild(r)) ∩ coverage(rightChild(r)) = ∅
```

### Invariants

- Width is always a positive power of two.
- Start is aligned to width.
- Ranges are half-open: `[start, start + width)`.

### Idris Classification

- `Width` should be a refined type carrying a `PowerOfTwo` proof.
- `Range` construction should require or check alignment.

---

## 3. Summary Tree Algebra

### Types

```text
SummaryText     -- one-line text, target <= NODE bytes
Node            -- { range, text, size }
Tree            -- partial map Range -> Built Node
```

### Operations

```text
built          : Tree -> Range -> Bool
node           : Tree -> Range -> Maybe Node
insertNode     : Tree -> Node -> Tree
sourceText0    : Log -> MessageId -> Payload
mergeText      : Node -> Node -> SummaryText
children       : Range(width > 1) -> (Range, Range)
```

### Laws

```text
built(tree, r) => node(tree, r).range = r

For width = 1:
  node(tree, r) summarizes get(log, r.start)

For width > 1:
  built(tree, r) => built(tree, leftChild(r)) ∧ built(tree, rightChild(r))
  node(tree, r).text summarizes node(tree, leftChild(r)).text and node(tree, rightChild(r)).text
```

### Free Node Rule

```text
If source text bytes <= NODE, level-0 node text = source text.
If childA.text + "\n" + childB.text bytes <= NODE, parent text = concatenation.
```

Otherwise a compactor model may generate the summary.

### Invariants

- Parent nodes are built only after both children are built.
- Node text is one logical line when rendered.
- The summary tree is a cache over the log but should be persisted to avoid recomputation.

### Idris Classification

- Parent construction should require child nodes.
- Semantic summarization quality is a model obligation, not a type-level proof.

---

## 4. View Algebra

### Types

```text
Part            -- a Range included in the rendered view
View            -- ordered list of Part, oldest first
ViewBudget      -- byte budget
```

### Operations

```text
tile          : LogSize -> View -> Bool
renderPart    : Tree -> Part -> Text
renderView    : Tree -> View -> Text
appendPart    : View -> MessageId -> View
fit           : Tree -> ViewBudget -> LogSize -> View -> View
mergeablePair : Tree -> LogSize -> Part -> Part -> Bool
due           : LogSize -> Part -> Rational
```

### Laws

```text
tile(T, view) => coverage(view) = [0, T)
tile(T, view) => parts are ordered, adjacent, and non-overlapping

fit(tree, budget, T, view).coverage = view.coverage
fit never splits a part
fit only replaces adjacent sibling parts with their built parent
fit preserves ordering
```

### Merge Rule

When over budget, choose the mergeable adjacent sibling pair with largest due value:

```text
due(T, part(level=l, start=s)) = (T - s) / 2^(l + 2)
```

If no parent is built, the view may temporarily exceed budget rather than showing cut text.

### Invariants

- Rendered agent views must contain only built summaries.
- The daemon may display placeholders internally, but no agent/model call may receive an unsummarized placeholder.
- View construction is incremental append+fit; do not recompute a fresh optimum each turn.

### Idris Classification

- Tiling can be represented by a dependent `View T` type later.
- Budget compliance is an operational/property-test invariant because it depends on byte sizes and built parents.

---

## 5. Zoom and Date Algebra

### Operations

```text
zoom          : Log -> Tree -> Address -> Either ZoomError ZoomResult
date          : Log -> MessageId -> Either DateError Timestamp
```

### Laws

```text
zoom(id, 1) = exact original event id

For n > 1:
  zoom(id, n) = [node(id, n/2), node(id + n/2, n/2)]

Repeated zoom descent from a rendered view part eventually recovers every event in its range.
```

### Validity

`zoom(id, n)` is valid iff:

```text
n is a positive power of two
id is aligned to n
id + n <= log.size
requested node or leaf exists
```

### Idris Classification

- External `zoom` requests are checked constructors into a valid `Address`.
- Internal zoom over `Address` should not represent invalid ranges.

---

## 6. Storage and Durability Algebra

### Abstract Effects

```text
persistEvent       : Event -> DurableWrite
persistNode        : Node -> DurableWrite
loadEvents         : Storage -> Log
loadNodes          : Storage -> Tree
recoverTornLines   : Storage -> Storage
acquireWriterLock  : Storage -> Either LockError LockHandle
```

### Laws / Operational Rules

- A successful append returns only after write + fsync.
- A process must hold the writer lock before appending events or nodes.
- Invalid/torn JSONL lines are reported and skipped at load.
- If a file does not end in newline, recovery appends one before next write.
- Tree storage is append-only; bad summaries are invalidated by later explicit mechanisms, not silent edits.

### Idris Classification

- Durability is an operational invariant tested with integration/fault tests.
- Single-writer access is enforced by daemon startup and lock acquisition.

---

## 7. Compactor Scheduling Algebra

### Types

```text
Job             -- request to build one Range summary
BusySet         -- running jobs
FailureSet      -- first failure reports / retry tracking
```

### Operations

```text
ready          : Log -> Tree -> Range -> Bool
firstUnbuilt   : View -> LogSize -> MessageId
eligible       : Log -> Tree -> View -> Range -> Bool
pump           : State -> State
completeJob    : State -> Range -> Node -> State
failJob        : State -> Range -> Error -> State
```

### Eligibility Laws

A range is eligible when:

```text
not built(range)
not busy(range)
ready(log, tree, range)
rangeEnd(range) <= firstUnbuilt(view, log.size)
```

For level 0, readiness requires the source event exists.
For level > 0, readiness requires both child nodes exist.

### Retry Rule

Failed jobs retry after `RETRY` forever; only first failure per node is reported unless diagnostics are requested.

### Idris Classification

- Readiness should be a checked predicate before constructing a `Job`.
- Retry/backoff behavior is operational.

---

## 8. Daemon API Algebra

### Core Commands

```text
record(kind, payload) -> MessageId
view(budget?)         -> RenderedView
zoom(id, n)           -> ZoomResult
date(id)              -> Timestamp
status                -> DaemonStatus
settle                -> Settled | Cancelled
```

### API Laws

```text
record(k, p) returns id such that get(logAfter, id).payload = p
view returns only built summaries
zoom accepts only valid addresses
settle returns Settled only when every current view part is built
```

### Integration Rule

Runtime adapters may differ, but they must not bypass the daemon's validation and append-only storage rules.

---

## 9. Property Obligations

Initial executable tests/proofs should cover:

1. `append` preserves old messages and assigns the next ID.
2. `Range` child coverage exactly partitions parent coverage.
3. `View` append+fit preserves total coverage.
4. `fit` never splits parts.
5. `zoom` recursively recovers all source events under a view part.
6. Invalid zoom addresses are rejected.
7. Storage load skips torn lines without renumbering valid events.
8. Parent jobs are never scheduled before child nodes are built.

---

## 10. Open Design Questions

- Exact daemon transport: Unix socket, HTTP localhost, MCP-compatible server, or multiple adapters?
- JSONL schema versioning strategy.
- Whether event payload capping belongs in adapter layer or daemon core.
- How to represent project overlays without compromising global memory laws.
- How much of `View T tiles [0,T)` should be proven in Idris vs tested.
- Which provider should be used for the first compactor implementation.
