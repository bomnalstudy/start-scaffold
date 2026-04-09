# Orchestrator Debug Guide

We verify two questions separately:

1. Is it automatically affecting our workflow?
2. Is it behaving as intended?

## 1) Workflow Auto-Impact Check

The orchestrator cannot directly rewrite model internals.
It affects real work by gating the workflow scripts.

Run:

```powershell
.\scripts\debug-orchestrator.ps1
```

What this confirms:

- `start-task` automatically runs `session-guard` preflight and blocks empty plans.
- you cannot move to checkpoint/close with empty worklog sections.

If this passes, your day-to-day script path is being controlled.

## 2) Intended Behavior Check

The same command also executes behavior tests:

- preflight fails on empty template
- preflight passes after minimal required sections are filled
- checkpoint fails with empty worklog
- checkpoint passes with required worklog sections
- close mode passes when stop rationale is present

Use `-KeepFiles` if you want to inspect generated sample files:

```powershell
.\scripts\debug-orchestrator.ps1 -KeepFiles
```

## Recommended Cadence

- Before coding:
  - `.\scripts\run-orchestration.ps1 -Pipeline session-guard -PlanPath <task-plan>`
- During coding:
  - `.\scripts\run-orchestration.ps1 -Pipeline all -PlanPath <task-plan> -WorklogPath <worklog>`
- Before ending:
  - `.\scripts\run-session-guard-checks.ps1 -PlanPath <task-plan> -WorklogPath <worklog> -Mode close`
