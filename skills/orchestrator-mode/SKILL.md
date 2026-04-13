---
name: orchestrator-mode
description: Narrow the session to orchestrator runtime, state ownership, host wrapper, stage handoff, and pipeline-safe artifact structure work in this repository. Use when the user asks about orchestrator design, host wrapper behavior, state contract rules, version naming, or runtime-safe artifact structure.
---

# Orchestrator Mode

Read first:

1. `docs/modes/shared/agent-modes.md`
2. `docs/modes/orchestrator/orchestrator-structure.md`
3. `docs/modes/orchestrator/state-ownership-rules.md`
4. `docs/modes/orchestrator/host-wrapper-rule.md`
5. `docs/modes/orchestrator/version-naming-rules.md`
6. `docs/modes/orchestrator/structured-debug-logging-rule.md`
7. `docs/modes/orchestrator/state-patch-flow.md`
8. `docs/modes/orchestrator/reliability-patterns.md`
9. `docs/modes/orchestrator/orchestration-patterns.md`
10. `docs/modes/orchestrator/session-guard.md`
11. the current task plan and worklog

Focus on:

- version naming rules
- central state ownership
- host wrapper stability
- debug log correlation
- snapshot and patch flow
- checkpoint, replay, and retry boundaries
- folder and responsibility boundaries
- stage handoff clarity
- pipeline-safe artifact naming

Treat artifact version naming as a first-class concern.
