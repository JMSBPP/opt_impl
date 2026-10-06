# Width Algebra

## Type

`Width` is a positive power-of-two range width.

## Constructors

```text
mkWidth : Nat -> Maybe Width
widthOfLevel : Level -> Width
```

## Observations

```text
value : Width -> Nat
levelOf : Width -> Level
```

## Operations

```text
half : Width -> Maybe Width
```

## Laws

```text
value(widthOfLevel(l)) = 2^l
levelOf(widthOfLevel(l)) = l
mkWidth(n) = Just(w) iff n > 0 and n is a power of two
half(widthOfLevel(S l)) = Just(widthOfLevel(l))
half(widthOfLevel(0)) = Nothing
```

## Invalid States

- Zero width is invalid.
- Non-power-of-two width is invalid.

## Test / Proof Obligations

- Constructor rejects zero and non-powers-of-two.
- `levelOf` and `widthOfLevel` are inverses for valid widths.
