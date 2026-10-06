# OptMem vs opt_impl

## Short Answer

`opt_impl` is inspired by Victor Taelin's OptMem and OptChat work, but it is **not the same project as OptMem**.

OptMem is a lightweight manual memory tool. `opt_impl` aims to be a standalone daemon/library that records complete agent sessions and exposes OptChat-style durable memory across directories and runtimes.

## OptMem

Reference: https://github.com/VictorTaelin/OptMem

OptMem is:

- A small plug-and-play memory CLI.
- Installed under `~/.optmem/memo`.
- Driven by explicit agent calls like `memo wake`, `memo note`, `memo nap`, `memo recall`, and `memo zoom`.
- Based on manually captured short memories, not full chat/event logs.
- A binary summary tree over memory notes.
- Session-independent, but not a full harness-level chat runtime.
- Simple enough to integrate by pasting a Memory block into `AGENTS.md` / `CLAUDE.md`.

Its core unit is a **memory note**.

## opt_impl

`opt_impl` aims to implement an OptChat-style substrate:

- A long-running daemon/library usable by multiple agent runtimes.
- Directory-independent global memory for all sessions.
- Append-only recording of user messages, agent replies, tool calls, and tool results.
- Background compaction into a binary tree of one-line summaries.
- A bounded rendered view of the whole history for session startup.
- `zoom(id, n)` and `date(id)` APIs over exact event history.
- Durable storage with locking, fsync, torn-line recovery, and process ownership.
- Optional future project overlays on top of global memory.

Its core unit is a **session event/message**, not a manually written note.

## Key Differences

| Dimension | OptMem | opt_impl |
|---|---|---|
| Primary unit | Manual memory note | Full session event/message |
| Capture path | Agent decides when to call `memo note` | Harness/daemon records chat, tool calls, and results |
| Runtime shape | CLI script | Standalone daemon + library + CLI/API |
| Memory model | Persistent notes + summary tree | Full append-only chat/event log + summary tree |
| Startup | `memo wake` prints memory view | Daemon renders bounded OptChat-style view |
| Compaction | Manual/command-driven `nap` | Background worker with retries and scheduling |
| Scope | Global note memory | Global cross-directory session memory; project overlays later |
| Exact recall | Raw notes and zoom tree | Exact original messages/events via `zoom` |
| Integration | Prompt convention | Runtime-neutral API/transport |
| Goal | Plug-and-play persistent memory | Infrastructure for every session to follow OptChat memory semantics |

## Relationship

OptMem proves that a small binary-tree memory tool is useful and practical. `opt_impl` borrows the durable-memory intuition but follows the newer OptChat direction:

> the chat/session history itself is the memory.

This means `opt_impl` is closer to an agent harness memory layer than a note-taking helper.

## Why Not Just Use OptMem?

OptMem is excellent when:

- The agent reliably remembers to write notes.
- You want low-friction setup.
- You are comfortable with memories being curated summaries rather than full history.
- You do not need every tool call/result preserved and zoomable.

`opt_impl` is needed if we want:

- automatic capture of every session regardless of working directory;
- verbatim event history for later forensic recall;
- a bounded session view generated from all prior interactions;
- daemon-level integration across Pi, Codex, Claude, Hermes, OpenCode, etc.;
- typed correctness around tree/view/zoom invariants;
- optional project overlays and structured workflow decisions.

## Design Constraint

`opt_impl` should not clone OptMem. If a feature is already solved well by OptMem, prefer compatibility or migration paths. The distinct value of `opt_impl` is full-session durable memory with OptChat semantics.
