# Specification Methodology: Algebra-Driven Design First

**Status:** Accepted
**Date:** 2026-10-06
**Source:** `~/Downloads/AlgebraDrivenDesign.pdf` — Sandy Maguire, *Algebra-Driven Design: Elegant Software from Simple Building Blocks*

## Decision

`opt_impl` will be specified before implementation using an Algebra-Driven Design approach.

The technical specification must define the core system as a set of small algebras:

- abstract types;
- primitive constructors/observers;
- composition operations;
- equational laws;
- invalid-state exclusions;
- property-test obligations;
- implementation derivation notes.

Implementation in Idris 2 should follow the spec, not lead it.

Development is also locked as type-driven and test-driven from per-type algebra specs. Each important type gets a dedicated algebra-only file at:

```text
.spec/SomeType.spec/SomeType.md
```

See `.spec/development_method.md` for the detailed convention.

## What This Means

Before writing daemon/storage/model code, we first describe the behavior of the system in terms of algebraic interfaces and laws. For each subsystem, the spec must answer:

1. **What are the values?**
   - Example: `MessageId`, `Range`, `Node`, `View`, `Log`, `SummaryTree`.

2. **What are the primitive operations?**
   - Example: `append`, `covers`, `merge`, `fit`, `zoom`, `render`.

3. **What observations can clients make?**
   - Example: range start/end, rendered bytes, child nodes, exact message text.

4. **What laws must always hold?**
   - Example: appending preserves old IDs; a parent covers exactly its children;
     a view tiles `[0, total)` without overlap.

5. **What impossible states should types prevent?**
   - Example: unaligned zoom requests, non-power-of-two widths, parent nodes
     without built children.

6. **What properties become tests?**
   - Example: `zoom` after repeated descent recovers original message; `fit`
     never drops coverage.

## Workflow

Every major feature should follow this order:

1. **System algebra sketch**
   - Define the subsystem, operations, observations, and laws in `.spec/technical_spec.md`.

2. **Per-type algebra specs**
   - For each important type, create or update `.spec/SomeType.spec/SomeType.md`.
   - Keep these files algebra-only: constructors, observations, operations, laws, invalid states, and test/proof obligations.

3. **Property tests / proof obligations**
   - Convert the per-type laws into Idris properties, proofs, or executable tests.

4. **Initial encoding**
   - Implement the simplest Idris representation that makes the laws explicit,
     even if inefficient.

5. **Efficient implementation**
   - Replace naive structures with durable/indexed versions while preserving the
     algebraic interface.

6. **Refinement note**
   - Document any law changes, performance compromises, or explicit deviations.

## Required Algebra Sections

The initial specification must include at least these algebras:

- Event Log Algebra
- Range and Node Address Algebra
- Summary Tree Algebra
- View Algebra
- Zoom/Date Algebra
- Storage/Durability Algebra
- Compactor Scheduling Algebra
- Daemon API Algebra

## Non-Negotiables

- Do not start with framework/API code and retrofit correctness later.
- Do not treat JSONL files as the primary design model; they are an implementation of the Log algebra.
- Do not make model prompts the source of truth for memory behavior.
- Do not accept behavior that cannot be stated as laws or explicit operational rules.
- Do not optimize before the simple algebraic model is implemented and tested.

## Relationship to Idris

Idris 2 is the implementation language because many algebraic laws can become types, proofs, or total functions.

The spec should classify each law as one of:

- **Type-level invariant** — should be unrepresentable if invalid.
- **Checked constructor invariant** — validated when crossing from external input.
- **Property-test invariant** — tested over generated values.
- **Operational invariant** — enforced by daemon sequencing, locks, or fsync boundaries.

## Success Criteria

The methodology is working when implementation tasks start from laws like:

```text
covers(parent(a, b)) = covers(a) ∪ covers(b)
fit(view).coverage = view.coverage
zoom(id, 1) = originalMessage(id)
append(log, msg).size = log.size + 1
```

rather than from ad hoc file formats or API endpoints.
