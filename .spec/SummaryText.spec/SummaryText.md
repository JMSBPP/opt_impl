# SummaryText Algebra

## Type

`SummaryText` is one logical line used in a summary-tree node.

## Constructors

```text
mkSummaryText : String -> SummaryText
```

## Observations

```text
line : SummaryText -> String
bytes : SummaryText -> Nat
```

## Operations

```text
flattenNewlines : SummaryText -> SummaryText
withinTarget : Nat -> SummaryText -> Bool
```

## Laws

```text
line(mkSummaryText(s)) = s
flattenNewlines(flattenNewlines(x)) = flattenNewlines(x)
withinTarget(n, x) = bytes(x) <= n
```

## Invalid States

- Rendered summary text must be one logical line.
- A summary may exceed the target only through explicit compactor retry fallback.

## Test / Proof Obligations

- Rendering replaces embedded newlines with spaces.
- Free-node summaries preserve source text exactly when within target.
