# Context Routing

Many docs exist in this repo, but agents should not load all of them every run.

This routing model exists to keep context small and token-efficient.

## Rule

- Always load `base` docs.
- Load one agent adapter (`codex` or `claude`).
- Load one workload pack (`start`, `implement`, `bugfix`, `review`, `orchestration`, `secrets`, `token-audit`).
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
- `orchestration`: harness and orchestration design/maintenance
- `secrets`: project-scoped token/env handling
- `token-audit`: optimize token usage and prompt discipline
