# Context Routing

Many docs exist in this repo, but agents should not load all of them every run.

This routing model exists to keep context small and token-efficient.

## Rule

- Always load `base` docs.
- Load one agent adapter (`codex` or `claude`).
- Load one workload pack (`start`, `implement`, `bugfix`, `review`, `orchestration`, `secrets`, `token-audit`).
- If the user calls a named mode such as `ux-ui-mode`, `ux/ui-mode`, or `secure-mode`, load that mode's docs before adding extra context.
- Add extra files only when blocked.

## Why

- Prevents "all-doc ingestion" behavior.
- Keeps runs focused and cheaper.
- Improves consistency because packs are repeatable.

## Quick Use

PowerShell:

```powershell
.\scripts\select-context-pack.ps1 -Agent codex -Pack implement
```

If you want a compact prompt block:

```powershell
.\scripts\select-context-pack.ps1 -Agent claude -Pack bugfix -AsPromptBlock
```

## Pack Meanings

- `start`: project/task kickoff with clear scope and stop rules
- `implement`: normal MVP implementation work
- `bugfix`: narrow, regression-safe debugging flow
- `review`: risk-focused review context
- `orchestration`: orchestrator runtime and harness verification design/maintenance
- `secrets`: project-scoped token/env handling
- `token-audit`: optimize token usage and prompt discipline

## Mode Overlay

Use modes as a narrow overlay on top of the base pack, not as a replacement for planning discipline.

- `ux-ui-mode`: UX/UI routing and quality-guard-first context
- `secure-mode`: security-sensitive coding and secrets handling
- `performance-mode`: lag, bottleneck, and stability optimization
- `orchestrator-mode`: orchestrator runtime, state contract, host wrapper, and version-naming work
- `harness-mode`: harness scenario, assertion, and verification-loop work
- `failure-pattern-mode`: repeated issue logging and prevention
