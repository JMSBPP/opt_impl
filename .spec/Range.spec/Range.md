# Range Algebra

## Type

`Range` is a half-open aligned interval `[start, start + width)` over message IDs.

## Constructors

```text
mkRange : MessageId -> Width -> Maybe Range
```

## Observations

```text
start : Range -> MessageId
width : Range -> Width
end : Range -> MessageId
```

## Operations

```text
contains : Range -> MessageId -> Bool
leftChild : Range -> Maybe Range
rightChild : Range -> Maybe Range
parent : Range -> Range
```

## Laws

```text
end(r).value = start(r).value + width(r).value
contains(r, id) = start(r).value <= id.value < end(r).value

leftChild(r).start = r.start
leftChild(r).width = r.width / 2
rightChild(r).start = r.start + r.width / 2
rightChild(r).width = r.width / 2

coverage(leftChild(r)) ∪ coverage(rightChild(r)) = coverage(r)
coverage(leftChild(r)) ∩ coverage(rightChild(r)) = ∅
```

## Invalid States

- `start` must be aligned to `width`.
- Child ranges are invalid for width `1`.

## Test / Proof Obligations

- Constructor rejects unaligned starts.
- Children exactly partition parent coverage.
- `contains` is true exactly for IDs in the half-open interval.
