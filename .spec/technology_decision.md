# Technology Decision: Idris 2

**Status:** Accepted
**Date:** 2026-10-06

## Decision

`opt_impl` will use **Idris 2** as the primary implementation language.

The project may still use:

- **Agda** for optional formal specifications/proofs of critical algorithms.
- **Bend2** for optional experimental/offline accelerators.
- Small shell scripts or generated bindings for packaging and runtime integration.

But the daemon, library API, CLI, storage model, tree/view algorithms, and integration surface should be designed around Idris 2 first.

## Rationale

`opt_impl` needs to be both correct and usable. The core data model has invariants that are easy to get subtly wrong:

- Node ranges must tile message history without gaps or overlap.
- `zoom(id, n)` is valid only for aligned power-of-two ranges within history.
- Summary-tree parents must cover exactly their two children.
- Rendered views must contain only built summary nodes.
- Append+fit should coarsen history without deleting or splitting merged ranges.
- External API requests must be validated before becoming trusted core values.

Idris 2 is the best fit among Agda, Bend2, and Idris because it can encode many of these invariants in the implementation while still supporting a practical daemon/library.

## Comparison

### Agda

Agda is strongest as a proof assistant. It is ideal for formalizing the OptChat algorithms and proving properties about range tiling, node addressing, and zoom validity. It is not the best primary language for a production daemon with filesystem IO, locking, background workers, JSONL storage, HTTP/Unix-socket APIs, and provider integrations.

Use Agda later for formal models, not the first executable system.

### Bend2

Bend2 is promising for parallel tree workloads: replaying views, checking tree consistency, or experimenting with large offline summary/index rebuilds. It is not mature enough to be the control-plane language for a durable local daemon.

Use Bend2 later for experiments or accelerators, not the first daemon.

### Idris 2

Idris 2 offers the best compromise: dependent types for the correctness-sensitive core, plus enough practical programming capability to build the daemon, CLI, and library. The ecosystem is smaller than Rust/TypeScript/Python, so some bindings and infrastructure work may be necessary, but the language matches the domain's correctness requirements.

## Implementation Implications

The repository should organize the Idris code around typed boundaries:

```text
src/OptImpl/Core/
  Message.idr      -- message IDs, ranges, kinds
  Tree.idr         -- summary nodes and parent/child addressing
  View.idr         -- bounded view representation and fit algorithm
  Zoom.idr         -- validated zoom requests
  Invariants.idr   -- proofs/types for range and alignment properties

src/OptImpl/Storage/
  Jsonl.idr        -- append-only JSONL streams
  Durability.idr   -- fsync/torn-line recovery boundaries
  Lock.idr         -- single-writer process lock

src/OptImpl/Daemon/
  Api.idr          -- runtime-neutral daemon API
  Worker.idr       -- background compactor scheduling
  Server.idr       -- local transport

src/OptImpl/Model/
  Provider.idr     -- model-provider abstraction
  Compactor.idr    -- textual summary generation workflow
```

External inputs should enter through validation functions that construct typed core values only after proving or checking their constraints.

## Non-Negotiables

- Do not rewrite the core in an untyped scripting language for convenience.
- Do not make Bend2 the daemon control plane.
- Do not make Agda the only executable implementation path.
- Do not hide invalid tree/view states behind comments; represent them in types where practical.
- If Idris lacks an ecosystem component, prefer a small FFI/binding layer over weakening the core model.

## Revisit Criteria

This decision can be revisited only if one of the following becomes true:

1. Idris 2 cannot provide or bind essential daemon/runtime functionality after a focused spike.
2. Build/deployment friction prevents a usable CLI/daemon from being distributed.
3. Another language can demonstrably preserve the same core invariants with lower operational risk.

Until then, Idris 2 is locked as the implementation language.
