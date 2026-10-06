# Mission Statement: opt_impl

## Mission

Build a standalone daemon and library that gives AI agent sessions durable,
directory-independent memory using an OptChat-style append-only log and compressed
summary tree.

Every session should be able to open in any directory, with any supported agent
runtime, and recover the user's long-term decisions, preferences, project history,
failed attempts, and useful facts without relying on fragile manual summaries,
per-project context files, or ever-growing chat contexts.

## Problem

Current AI agent workflows forget by default:

- Sessions are discarded, compacted, or isolated by tool/runtime.
- Important user decisions and corrections scatter across many chats.
- Long contexts rot: detail is lost, and model performance degrades.
- Project-local memory misses cross-project preferences and recurring patterns.
- Manual memory capture is useful but incomplete because the most important facts
  often appear in normal conversation, tool calls, and results.

The result is repeated context-setting, duplicated mistakes, and agents that cannot
reliably build on what already happened.

## Product Vision

`opt_impl` is a local-first memory substrate for AI agents:

1. **One durable global memory**
   - A user-level append-only log records sessions across directories and runtimes.
   - Project overlays may be added later, but global continuity is the foundation.

2. **Fresh turns, persistent continuity**
   - Agent sessions should not carry stale context forward forever.
   - Instead, each session gets a bounded, cache-friendly view of the whole memory.

3. **Compressed binary summary tree**
   - Every message/event is summarized into a small line.
   - Adjacent summaries merge pairwise into coarser summaries.
   - Older memory becomes lower-resolution but remains zoomable.

4. **Zoomable recall**
   - Any summary line can be opened into its children down to the original event.
   - The daemon exposes `zoom` and `date`-style APIs so agents can inspect exact
     history before acting on vague summaries.

5. **Runtime-neutral integration**
   - The core should be usable by Pi, Codex, Claude Code, Hermes, OpenCode, and
     future harnesses through a daemon API, CLI, and embeddable library.

6. **Safety through structure**
   - Model-generated free text is useful for compaction, but system behavior should
     depend on typed APIs, durable storage invariants, and explicit state machines.

## Primary Design Contract

The initial design is based on Victor Taelin's OptChat specification:

- Append every user message, agent reply, tool call, and tool result verbatim.
- Store an append-only log and a persistent binary tree of summaries.
- Keep model reasoning/thoughts out of the permanent log.
- Never show truncated unsummarized text to an agent; wait for summaries instead.
- Build a fixed-budget view over the whole history using incremental append+merge.
- Use `zoom(id, n)` to navigate from summaries to exact messages.
- Keep prompts/tool definitions stable for cache efficiency.
- Use locking, fsync, and torn-line recovery for durable local storage.

Where this project deviates from OptChat, the deviation must be explicit and justified.

## How TypeSafe System One Models / Jev May Help

TypeSafe's System One Models and Jev are relevant because `opt_impl` needs many
fast, reliable, structured decisions around the memory pipeline. Jev is described
as a model class optimized for typed probabilistic decisions rather than string
generation: unstructured state in, type-safe structured values out, with calibrated
confidence and very low latency.

Potential uses:

- **Memory routing**: decide whether an event belongs only to global memory, a
  project overlay, a private/sensitive partition, or should be excluded.
- **Importance scoring**: assign calibrated probabilities that an event will matter
  later, without asking a full LLM to generate prose.
- **Compaction triage**: choose which facts must survive when a summary is over
  budget before invoking a text summarizer.
- **Recall planning**: decide which summary branches to zoom based on a user query
  and confidence signals.
- **Guardrails**: classify tool outputs, secrets, prompt-injection attempts, or
  policy-sensitive content before writing or exposing memory.
- **Workflow branching**: make cheap, typed decisions inside the daemon's state
  machines where free-form LLM output would be too slow or brittle.

Jev should not replace the textual compactor initially: OptChat summaries require
high-quality natural-language compression. Instead, System One style models are a
candidate acceleration and reliability layer for classification, scoring, routing,
and verification around the compactor.

## Non-Goals for the First Version

- Do not build a full chat UI first.
- Do not depend on a single agent runtime.
- Do not require cloud storage.
- Do not require Jev/TypeSafe availability for core operation.
- Do not make project-local memory the foundation; it can be layered on later.
- Do not rely on manual note-taking as the only capture path.

## Initial Success Criteria

A first useful version succeeds when:

1. A daemon can record session events from any directory.
2. Events are durably appended with stable IDs and timestamps.
3. A background worker builds level-0 and merged summary nodes.
4. A bounded view can be rendered over the whole log.
5. `zoom` can recover exact source messages from a view line.
6. A CLI/API can inject the rendered memory view into a new agent session.
7. The design supports future project overlays without compromising global memory.

## Working Name

`opt_impl` — a pragmatic implementation of OptChat-style durable memory for local
agent ecosystems.
