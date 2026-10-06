# MessageId Algebra

## Type

`MessageId` is a stable zero-based index into the append-only event log.

## Constructors

```text
mkMessageId : Nat -> MessageId
```

## Observations

```text
value : MessageId -> Nat
```

## Operations

```text
nextId : LogSize -> MessageId
lessThan : MessageId -> LogSize -> Bool
```

## Laws

```text
value(mkMessageId(n)) = n
nextId(size).value = size
lessThan(id, size) = (id.value < size)
```

## Invalid States

- A `MessageId` used to access a log is invalid when `id.value >= log.size`.
- Message IDs are never reused or renumbered.

## Test / Proof Obligations

- Appending an event assigns `MessageId = previous log size`.
- Appending preserves all existing IDs.
- Loading storage must not renumber valid events after skipping torn lines.
