# Event Algebra

## Type

`Event` is one durable append-only log entry.

## Constructors

```text
mkEvent : MessageId -> EventKind -> Payload -> Nat -> Timestamp -> Event
```

## Observations

```text
id : Event -> MessageId
kind : Event -> EventKind
payload : Event -> Payload
sizeBytes : Event -> Nat
timestamp : Event -> Timestamp
```

## Operations

```text
renderEventSource : Event -> String
```

## Laws

```text
id(mkEvent(i, k, p, s, t)) = i
kind(mkEvent(i, k, p, s, t)) = k
payload(mkEvent(i, k, p, s, t)) = p
sizeBytes(mkEvent(i, k, p, s, t)) = s
timestamp(mkEvent(i, k, p, s, t)) = t

renderEventSource(e) = renderKind(e.kind) ++ ": " ++ text(e.payload)
```

## Invalid States

- An event's `id` must match its position in the append-only log.
- `sizeBytes` must match the encoded size policy for `kind + ": " + payload`.

## Test / Proof Obligations

- Appending creates an event whose ID equals the prior log size.
- Serialization roundtrips preserve event fields.
- Events are never edited in place.
