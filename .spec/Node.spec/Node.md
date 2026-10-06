# Node Algebra

## Type

`Node` is a built summary-tree node for a valid range.

## Constructors

```text
mkNode : Range -> SummaryText -> Nat -> Node
```

## Observations

```text
range : Node -> Range
summary : Node -> SummaryText
sizeBytes : Node -> Nat
```

## Operations

```text
covers : Node -> Range
renderNode : Node -> String
```

## Laws

```text
range(mkNode(r, s, b)) = r
summary(mkNode(r, s, b)) = s
sizeBytes(mkNode(r, s, b)) = b
covers(n) = range(n)
renderNode(n) = address(range(n)) ++ "|" ++ line(summary(n))
```

## Invalid States

- A parent node must not be built before both child nodes exist.
- A node's range must be aligned and power-of-two width.
- A node's `sizeBytes` must match the encoded summary size policy.

## Test / Proof Obligations

- Parent construction preserves child coverage union.
- Rendered node address matches its range.
- Node serialization roundtrips preserve range and summary.
