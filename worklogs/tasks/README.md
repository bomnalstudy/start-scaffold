# Task Plans

This folder stores task-level orchestration plans created by `scripts/powershell/bootstrap/start-task.ps1`.

Expected flow:

1. create task plan from template
2. fill required sections (`Original Goal`, `MVP Scope`, `Non-Goal`, `Done When`, `Stop If`)
3. run orchestration checks before implementation

Example:

```powershell
.\scripts\powershell\bootstrap\start-task.ps1 -TaskName "auth mvp" -Agent codex -Pack start
.\scripts\run-orchestration.ps1 -Pipeline all -PlanPath .\worklogs\tasks\2026-04-08-auth-mvp.md
```

