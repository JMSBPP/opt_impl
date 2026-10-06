# opt_impl

Standalone daemon/library for OptChat-style durable memory across AI agent sessions.

The goal is to make every agent session, regardless of working directory or runtime,
start with continuity from an append-only, zoomable memory tree rather than from an
empty or project-local context.

Primary references:
- Victor Taelin, “OptChat: an endless chat where the AI remembers everything”
- TypeSafe AI, “Introducing System One Models & Jev”

See `.spec/mission_statement.md` for the project mission and initial design stance.
