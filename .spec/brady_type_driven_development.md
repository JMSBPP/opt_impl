# Brady-Style Type-Driven Development

**Status:** Accepted
**Date:** 2026-10-06
**Reference:** Edwin Brady, *Type-Driven Development with Idris*

## Decision

After a type's algebra has been designed in `.spec/<Type>.spec/<Type>.md`, implementation starts using Brady-style Type-Driven Development.

This means implementation is not written bottom-up from ad hoc data structures. It starts from the type-level contract and proceeds by refinement.

## Workflow

For each type or operation:

1. **Start from the algebra**
   - Read `.spec/<Type>.spec/<Type>.md`.
   - Identify constructors, observations, operations, laws, invalid states, and test/proof obligations.

2. **Write the public type signatures first**
   - Encode the intended operation shape before writing implementation bodies.
   - Prefer precise domain types over generic `String`, `Nat`, or raw tuples.

3. **Strengthen types where practical**
   - Make invalid states unrepresentable when the cost is reasonable.
   - Use checked constructors when external data cannot be proven statically.
   - Keep raw/unsafe values at API boundaries only.

4. **Use holes deliberately**
   - Create Idris holes for implementation details.
   - Inspect hole contexts to see available assumptions.
   - Refine by pattern matching, constructors, and helper functions.

5. **Use totality as a design signal**
   - Prefer total functions.
   - Make impossible cases explicit.
   - If totality fails, decide whether the algebra is missing a case, the type is too weak, or the implementation is wrong.

6. **Derive tests/proofs from laws**
   - Tests should correspond directly to laws in the per-type spec.
   - No test should define behavior absent from the algebra.

7. **Only then optimize**
   - Efficient storage/indexing may replace the initial encoding only after preserving the algebraic interface.

## Idris Conventions

- Public APIs should expose typed domain values, not raw validated primitives.
- Raw constructors may be kept internal when they can violate invariants.
- Boundary functions should return `Maybe`, `Either`, or a domain-specific error type when constructing refined values from raw input.
- `%default total` is preferred for pure core modules.
- Holes are acceptable during development but must not be committed in passing code.

## Example Shape

```idris
module OptImpl.Core.Range

%default total

public export
record Range where
  constructor UnsafeMkRange
  start : MessageId
  width : Width
  aligned : Aligned start width

public export
mkRange : (start : MessageId) -> (width : Width) -> Maybe Range
mkRange start width = ?mkRange_rhs
```

The hole `?mkRange_rhs` should be refined using the alignment decision from the `Range` algebra.

## Relationship to Tests

TDD remains required, but tests follow the algebra and types:

```text
Algebra law -> Idris property/proof/test -> implementation refinement
```

Tests are not a substitute for stronger types. If a law can be enforced in the type, prefer the type. If a law depends on IO, byte encoding, provider behavior, or process ordering, use tests/integration checks.
