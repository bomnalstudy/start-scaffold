# Runtime Environment Patterns

This document defines the two supported environment patterns for this scaffold.

The scaffold currently ships in a PowerShell-first form.
That means the first pattern is implemented now, and the second pattern is the recommended expansion path when a project needs native WSL/Linux ergonomics.

## Pattern 1: `powershell-bridged`

- Purpose: run the same scaffold from Windows or WSL by routing execution through PowerShell.
- Runtime:
  - Windows: `powershell.exe` or `pwsh`
  - WSL/Linux: `pwsh`
- Best when:
  - the repository already uses `.ps1` as the main automation layer
  - the team wants one shared automation path for Claude and Codex
  - Windows remains a first-class environment
- Current status:
  - this is the scaffold's active default pattern

### Rules

- Treat PowerShell scripts as the canonical automation entrypoints.
- On WSL/Linux, call scripts with `pwsh -NoProfile -File`.
- Git hooks should prefer `pwsh` and only fall back to `powershell.exe` when available.
- Docs should avoid Windows-only absolute paths unless the path is truly Windows-specific.

### Pros

- one automation language
- less duplication across host environments
- lower migration cost from the current scaffold

### Limits

- not bash-native
- requires `pwsh` on WSL/Linux
- shell examples must be translated for Linux-friendly usage

## Pattern 2: `native-wsl-linux`

- Purpose: support a Linux-first or WSL-first team without making PowerShell the only operational layer.
- Runtime:
  - WSL/Linux: `bash` or `sh` native entrypoints first
  - Windows: optional wrappers or `pwsh` compatibility layer
- Best when:
  - the project is deployed, tested, and developed mainly on Linux
  - CI and production scripts are already shell-first
  - the team wants low-friction WSL usage without PowerShell dependency
- Current status:
  - core Linux-native entrypoints exist under `scripts/bash/`
  - full parity with every PowerShell flow is not complete yet
  - use this as a supported partial runtime, with clear parity boundaries

### Rules

- Keep orchestration logic portable and separate from shell-specific wrappers.
- Add native `bash` entrypoints only for stable, high-value flows.
- Avoid maintaining two large logic implementations that drift.
- Shared logic should live in reusable modules or data files, while shell layers stay thin.
- If a Linux-native path is introduced, document parity boundaries with the PowerShell path.

### Pros

- better Linux and WSL ergonomics
- lower shell friction for Linux-first teams
- easier alignment with Linux CI and container workflows

### Limits

- higher maintenance cost
- greater drift risk if both PowerShell and bash flows evolve separately
- requires stricter interface contracts between wrappers and shared logic

## Selection Rule

- Default to `powershell-bridged` unless the project has a clear Linux-first requirement.
- Choose `native-wsl-linux` only when the team is willing to maintain Linux-native entrypoints deliberately.
- Do not half-migrate. A mixed state with unclear ownership causes the most confusion.

## Upgrade Path

When moving from `powershell-bridged` toward `native-wsl-linux`, prefer this order:

1. identify the highest-value entrypoints
2. define stable arguments and output contracts
3. keep shell wrappers thin
4. verify behavior parity with harness checks
5. document the supported environment pattern in the project README

## Suggested Script Layout

Use this layout when the repository starts separating runtime concerns more explicitly:

- `scripts/shared/`
  - shared helpers, detection, contracts, and reusable logic
- `scripts/powershell/`
  - PowerShell-specific wrappers and launchers
- `scripts/bash/`
  - bash or sh wrappers for Linux-first projects

Keep the real logic as centralized as possible.
Avoid cloning the same orchestration behavior into both `powershell/` and `bash/`.
