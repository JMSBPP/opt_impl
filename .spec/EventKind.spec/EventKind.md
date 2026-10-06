# EventKind Algebra

## Type

`EventKind` classifies durable log events.

## Constructors

```text
User : EventKind
Talk : EventKind
Tool : EventKind
Echo : EventKind
Note : EventKind
Work : EventKind
```

## Observations

```text
renderKind : EventKind -> String
```

## Operations

(none yet)

## Laws

```text
renderKind(User) = "user"
renderKind(Talk) = "talk"
renderKind(Tool) = "tool"
renderKind(Echo) = "echo"
renderKind(Note) = "note"
renderKind(Work) = "work"
```

## Invalid States

- Model thoughts/reasoning are not an `EventKind` and must not be logged.
- Unknown external kind strings must be rejected or mapped through an explicit migration.

## Test / Proof Obligations

- Every valid `EventKind` renders to the canonical lower-case wire spelling.
- No constructor exists for thoughts/reasoning.
