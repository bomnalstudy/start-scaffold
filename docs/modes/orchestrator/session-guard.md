# Session Guard

`session-guard` is the anti-drift checkpoint for vibe-coding sessions.

It does not change model internals. It enforces operating discipline around:

- original goal retention
- minimal MVP scope
- explicit stop conditions
- worklog-based direction checks

## Why It Exists

AI coding sessions usually fail by:

- solving local errors while forgetting the original user problem
- widening scope until the session never ends
- shipping narrow fixes that only work for one test path

`session-guard` blocks these patterns early.

## Commands

Preflight (plan-only):

```powershell
.\scripts\run-orchestration.ps1 -Pipeline session-guard -PlanPath .\worklogs\tasks\YYYY-MM-DD-task.md
```

Checkpoint (plan + worklog):

```powershell
.\scripts\run-orchestration.ps1 -Pipeline all -PlanPath .\worklogs\tasks\YYYY-MM-DD-task.md -WorklogPath .\worklogs\YYYY-MM-DD-task-log.md
```

Close gate (explicit stop rationale):

```powershell
.\scripts\run-session-guard-checks.ps1 -PlanPath .\worklogs\tasks\YYYY-MM-DD-task.md -WorklogPath .\worklogs\YYYY-MM-DD-task-log.md -Mode close
```

## What Is Checked

Plan checks:

- required sections are present and non-empty
- `MVP Scope` is not too wide
- `Stop If` is specific enough

Worklog checks (checkpoint/close):

- drift signals are documented
- prevention actions are documented
- direction alignment is documented
- next tasks exist

Close-only check:

- direction section explains why this is a valid stopping point

## Usage Rule

If an error is reported, do not keep coding.
Fix the plan/worklog first, then rerun the gate.
