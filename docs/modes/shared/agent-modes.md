# Agent Modes

This document defines the lightweight chat-driven mode system for this scaffold.

The goal is not to replace the chat product or vendor auth flow.
The goal is to narrow context on demand so the agent reads only the most relevant rules, docs, and checks for the active topic.

## Naming Rule

- Mode names use the format `*-mode`.
- Keep names short, domain-based, and easy to call in chat.
- Current standard modes:
  - `ux-ui-mode`
  - `secure-mode`
  - `performance-mode`
  - `orchestrator-mode`
  - `harness-mode`
  - `failure-pattern-mode`

## Core Behavior

When a mode is active, the agent should:

1. read the matching documents first
2. avoid loading unrelated docs unless blocked
3. follow the mode-specific output shape
4. run the most relevant focused verification before stopping

This is a context-control system, not a hidden automation layer.

## Mode Definitions

### `ux-ui-mode`

- Purpose: finish or review user-facing UX/UI work with the right surface rules.
- Read first:
  - `docs/modes/ux-ui/ui-ux-product-rules.md`
  - `docs/modes/shared/agent-skills.md`
  - relevant UX/UI task plan / worklog
- Prefer:
  - `frontend-quality-guard` when the surface is still unclear
  - `web-ui-quality-guard` for browser-first work
  - `app-ui-quality-guard` for app-first work
- Must record:
  - surface as `web`, `app`, `shared`, or `non-UI`
  - chosen quality guard
  - primary UX concern
- Avoid loading first:
  - secrets or performance docs unless the task clearly needs them

### `secure-mode`

- Purpose: strengthen security posture during coding and review high-risk changes safely.
- Read first:
  - `AGENTS.md`
  - `docs/modes/secure/coding-rules.md`
  - `docs/modes/secure/multi-machine-secrets.md`
  - `secure-secrets/README.md`
- Focus on:
  - secrets handling
  - auth-sensitive changes
  - high-risk change review gates
  - safe defaults and prevention-first checks
- Avoid loading first:
  - UI polish docs unless the task is also user-facing

### `performance-mode`

- Purpose: reduce lag, bottlenecks, and instability in the app.
- Read first:
  - performance-related task plan / worklog
  - `docs/modes/orchestrator/orchestration-patterns.md` when pipeline flow affects performance
  - `docs/modes/harness/harness-guide.md` when validation behavior is part of the bottleneck
- Focus on:
  - app responsiveness
  - bottleneck isolation
  - queueing, caching, throttling
  - traffic distribution as one tool inside broader performance work
  - failure isolation and graceful degradation
- Avoid narrowing the mode to traffic distribution only.

### `orchestrator-mode`

- Purpose: work on orchestrator runtime, pipeline rules, host wrappers, state contracts, and version naming discipline.
- Read first:
  - `docs/modes/orchestrator/orchestrator-structure.md`
  - `docs/modes/orchestrator/state-ownership-rules.md`
  - `docs/modes/orchestrator/host-wrapper-rule.md`
  - `docs/modes/orchestrator/version-naming-rules.md`
  - `docs/modes/orchestrator/structured-debug-logging-rule.md`
  - `docs/modes/orchestrator/state-patch-flow.md`
  - `docs/modes/orchestrator/orchestration-patterns.md`
  - `docs/modes/orchestrator/session-guard.md`
  - relevant plan/worklog files
- Focus on:
  - folder and responsibility boundaries
  - central state ownership
  - host wrapper stability
  - debug log correlation
  - snapshot and patch flow
  - version naming rules
  - handoff clarity between stages
  - pipeline-safe file/output naming
- Must treat version naming as a first-class concern for generated artifacts.

### `harness-mode`

- Purpose: work on harness scenario design, assertions, verification loops, and regression-safe validation.
- Read first:
  - `docs/modes/harness/harness-guide.md`
  - `docs/modes/harness/harness-scenario-rules.md`
  - `docs/modes/harness/stale-snapshot-harness-template.md`
  - `templates/harness-spec.md`
  - relevant plan/worklog files
- Focus on:
  - harness level choice
  - scenario naming rules
  - assertion clarity
  - failure output readability
  - repeatable validation loops

### `failure-pattern-mode`

- Purpose: record repeated failure patterns and add prevention hooks.
- Read first:
  - `docs/modes/failure-pattern/vibe-coding-failure-prevention.md`
  - `docs/modes/failure-pattern/journaling.md`
  - relevant worklogs and task plans
- Focus on:
  - repeated mistakes
  - likely triggers
  - lightweight prevention rules
  - reusable logging format
- Avoid turning the mode into a broad postmortem process unless explicitly requested.

## Suggested Chat Pattern

Use short mode language in chat, for example:

- `use ux-ui-mode for this`
- `use ux/ui-mode for this`
- `switch to secure-mode`
- `organize this in orchestrator-mode`
- `use harness-mode for this`

Then the agent should narrow context before implementation.

## Implementation Notes

- Docs primarily used by a mode should live under `docs/modes/<mode>/`.
- Docs reused by multiple modes should live under `docs/modes/shared/`.
- See `docs/modes/README.md` for the folder rule.
- Global file-structure guidance lives in `docs/modes/shared/file-design-rules.md`.
- Connect this mode system to `docs/context-routing.md` and future skill wrappers.
- Prefer one active mode at a time for MVP tasks.
- If two modes are both needed, state the primary mode and only borrow the smallest necessary rules from the secondary mode.
- Repo-local skill entry points live under `skills/ux-ui-mode`, `skills/secure-mode`, `skills/performance-mode`, `skills/orchestrator-mode`, `skills/harness-mode`, and `skills/failure-pattern-mode`.
