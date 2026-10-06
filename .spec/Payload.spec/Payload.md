# Payload Algebra

## Type

`Payload` is verbatim event text after adapter-level capping/sanitization.

## Constructors

```text
mkPayload : String -> Payload
```

## Observations

```text
text : Payload -> String
bytes : Payload -> Nat
```

## Operations

```text
cap : Nat -> Payload -> Payload
```

## Laws

```text
text(mkPayload(s)) = s
bytes(cap(n, p)) <= max(bytes(p), n with explicit truncation marker)
cap(n, cap(n, p)) = cap(n, p)
```

## Invalid States

- Payload must not contain hidden model thoughts/reasoning events.
- If capping occurs, the capped payload is the durable truth for that event.

## Test / Proof Obligations

- Payload text survives append/load unchanged.
- Capping is idempotent.
- Capping records that content was omitted when omission occurs.
