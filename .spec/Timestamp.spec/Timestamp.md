# Timestamp Algebra

## Type

`Timestamp` records when an event was appended.

## Constructors

```text
mkTimestamp : Iso8601String -> Timestamp
```

## Observations

```text
iso8601 : Timestamp -> String
```

## Operations

```text
date : Log -> MessageId -> Maybe Timestamp
```

## Laws

```text
iso8601(mkTimestamp(s)) = s
date(append(log, kind, payload, t), nextId(size(log))) = Just(t)
date(append(log, kind, payload, t), oldId) = date(log, oldId) when oldId < size(log)
```

## Invalid States

- Invalid timestamp strings must not cross into trusted storage once timestamp parsing is implemented.

## Test / Proof Obligations

- `date(id)` returns the timestamp associated with the original event.
- Appending later events never changes earlier dates.
