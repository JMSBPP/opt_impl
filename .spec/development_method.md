# Development Method: Type-Driven + Test-Driven from Per-Type Algebra Specs

**Status:** Accepted
**Date:** 2026-10-06

## Decision

`opt_impl` development will combine:

1. **Algebra-Driven Design** — define the algebra before implementation.
2. **Brady-style Type-Driven Development** — once a type's algebra is designed, implementation proceeds using the workflow from Edwin Brady's *Type-Driven Development with Idris*: write types first, refine holes interactively, make invalid states unrepresentable where practical, and let totality/type errors guide the implementation.
3. **Test-Driven Development** — derive tests/properties from each type's algebra before or alongside implementation.

The unit of design is the **type**.

Each important domain type gets its own spec directory:

```text
.spec/SomeType.spec/SomeType.md
```

That file contains **only the algebra for that type**: constructors, observations, operations, laws, invalid states, and test/proof obligations. It must not contain implementation notes, daemon planning, storage details, or prose that belongs in higher-level design docs.

## Required Per-Type Spec Shape

Each `.spec/SomeType.spec/SomeType.md` should use this structure:

```markdown
# SomeType Algebra

## Type

## Constructors

## Observations

## Operations

## Laws

## Invalid States

## Test / Proof Obligations
```

Sections with no content may say `(none yet)`, but should not be replaced by implementation discussion.

## Development Loop

For each type:

1. Write or update `.spec/SomeType.spec/SomeType.md` with the algebra only.
2. Write tests/properties from the algebra.
3. Start implementation using Brady-style type-driven development:
   - write the type signatures first;
   - encode the strongest practical invariants in the type;
   - leave holes for implementation details;
   - inspect hole contexts and refine constructors/functions step by step;
   - prefer total functions and explicit impossible cases;
   - use compiler/type errors as design feedback, not merely as bugs to fix.
4. Run:

   ```sh
   pack typecheck opt_impl
   pack test opt_impl
   ```

5. If implementation reveals a better algebra, update the spec first, then code.

## Rules

- Do not add a core Idris type without a matching `.spec/<Type>.spec/<Type>.md` file.
- Do not put implementation details in per-type algebra specs.
- Do not let tests encode behavior that is absent from the type's algebra spec.
- Prefer total functions and refined constructors over runtime checks.
- Prefer Brady-style hole-driven refinement over writing large untyped implementations and fixing them afterward.
- External input validation should construct trusted typed values only after checking the algebra's invalid-state rules.

## Relationship to `.spec/technical_spec.md`

`.spec/technical_spec.md` remains the system-level algebra map.

Per-type specs are the source of truth for individual type behavior. If the system-level spec and a per-type spec conflict, resolve the conflict by updating both in the same change.
