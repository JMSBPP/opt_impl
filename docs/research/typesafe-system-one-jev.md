# Research Note: TypeSafe System One Models & Jev

Source: https://typesafe.ai/blog/introducing-system-one-models-and-jev

## Summary

TypeSafe describes System One Models as a new class of model optimized for fast,
typed, calibrated decisions that software can use directly. Their first model,
Jev, gives up general string generation in favor of structured outputs with known
schemas, confidence scores, and low latency.

Key claims from the article:

- Jev is intended for “frontier-intelligence function calls”: unstructured state
  in, typed probabilistic decisions out.
- Outputs are type-safe structured values defined in advance, not arbitrary text.
- Sampling is parallel rather than autoregressive token generation.
- The model is positioned for AI-powered workflows: classify, route, score,
  extract, branch, verify, judge, guardrail, and detect jailbreaks.
- TypeSafe emphasizes calibrated probabilities and consistent confidence as a
  requirement for automation.

## Relevance to opt_impl

`opt_impl` has two kinds of AI work:

1. **Textual compression** — summarizing chat/tool history into dense lines.
2. **Workflow decisions** — routing, scoring, filtering, zoom planning, and
   guardrail decisions around memory operations.

Jev appears more relevant to the second category than the first. The OptChat
compactor still needs a natural-language summarizer, but a System One model could
make surrounding decisions much cheaper and more reliable.

## Candidate Integration Points

- Event importance scoring.
- Global vs project memory routing.
- Secret/sensitive-content detection before memory exposure.
- Prompt-injection/tool-output risk classification.
- Deciding whether a view line is too vague and should be zoomed.
- Choosing among multiple candidate branches during recall.
- Verifying that compactor output fits schema and preserves required entities.

## Design Stance

Keep Jev optional. The core daemon should expose typed decision hooks so Jev or
similar models can be plugged in later, while the MVP runs with conventional LLMs
and deterministic heuristics.
