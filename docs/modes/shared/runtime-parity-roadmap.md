# Runtime Parity Roadmap

This document tracks how far `native-wsl-linux` has reached compared with the existing PowerShell-first scaffold.

The goal is not blind duplication.
The goal is practical parity with thin shell wrappers and shared logic whenever possible.

## Current Rule

- Prefer moving validation and normalization logic into `scripts/shared/`.
- Keep `scripts/bash/` and future `scripts/powershell/` entrypoints thin.
- Upgrade parity by workflow group, not by random script order.

## Parity Levels

- `done`
  - Linux-native entrypoint exists and has been exercised successfully.
- `partial`
  - some shared logic exists, but the Linux-native entrypoint or behavior parity is incomplete.
- `pending`
  - no Linux-native parity yet.

## Current Matrix

### Core Workflow

- `select-context-pack`
  - status: `done`
  - native entrypoint: `scripts/bash/select-context-pack.sh`
- `run-code-rules-checks`
  - status: `done`
  - native entrypoint: `scripts/bash/run-code-rules-checks.sh`
- `run-session-guard-checks`
  - status: `done`
  - native entrypoint: `scripts/bash/run-session-guard-checks.sh`
- `run-token-ops-checks`
  - status: `done`
  - native entrypoint: `scripts/bash/run-token-ops-checks.sh`
- `run-worklog-checks`
  - status: `done`
  - native entrypoint: `scripts/bash/run-worklog-checks.sh`
- `run-orchestration`
  - status: `done`
  - native entrypoint: `scripts/bash/run-orchestration.sh`
- `start-task`
  - status: `done`
  - native entrypoint: `scripts/bash/start-task.sh`
- `skill-minimum-goal`
  - status: `done`
  - native entrypoint: `scripts/bash/skill-minimum-goal.sh`

### Operational Workflow

- `init-project`
  - status: `pending`
- `install-git-hooks`
  - status: `partial`
  - note: hooks support `pwsh` on WSL, but native bash install flow is not separate yet
- `find-code-refactor-candidates`
  - status: `pending`
- `archive-to-graveyard`
  - status: `pending`
- `run-harness-checks`
  - status: `done`
  - native entrypoint: `scripts/bash/run-harness-checks.sh`

### Advanced Runtime

- `invoke-host-wrapper`
  - status: `pending`
- `apply-orchestrator-state-patch`
  - status: `pending`
- `debug-orchestrator`
  - status: `pending`
- `load-project-secrets`
  - status: `pending`
- `export-project-secrets`
  - status: `pending`
- `import-project-secrets`
  - status: `pending`

## Next Upgrade Order

1. `find-code-refactor-candidates`
2. `archive-to-graveyard`
3. `init-project`
4. `load-project-secrets` / `export-project-secrets` / `import-project-secrets`
5. orchestrator advanced runtime scripts

## Stop Rule

- Do not mark a script `done` until the Linux-native entrypoint has been run at least once.
- If parity requires duplicating large logic in both shells, pause and move more logic into `scripts/shared/` first.
