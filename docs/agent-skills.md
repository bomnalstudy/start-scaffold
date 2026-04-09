# Agent Skills (Codex + Claude)

Use these wrappers to run gates and print a compact prompt block in one command.

## Why

- less command typing during chat
- same workflow for Codex and Claude
- speed-first MVP flow with explicit stop rules

## Codex Skill

Start:

```powershell
.\scripts\skill-codex.ps1 -Stage start -TaskName "my task" -Pack start
```

Checkpoint:

```powershell
.\scripts\skill-codex.ps1 -Stage checkpoint -PlanPath .\worklogs\tasks\2026-04-09-my-task.md -WorklogPath .\worklogs\2026-04-09-my-task-log.md
```

Close:

```powershell
.\scripts\skill-codex.ps1 -Stage close -PlanPath .\worklogs\tasks\2026-04-09-my-task.md -WorklogPath .\worklogs\2026-04-09-my-task-log.md
```

## Claude Skill

Start:

```powershell
.\scripts\skill-claude.ps1 -Stage start -TaskName "my task" -Pack start
```

Checkpoint:

```powershell
.\scripts\skill-claude.ps1 -Stage checkpoint -PlanPath .\worklogs\tasks\2026-04-09-my-task.md -WorklogPath .\worklogs\2026-04-09-my-task-log.md
```

Close:

```powershell
.\scripts\skill-claude.ps1 -Stage close -PlanPath .\worklogs\tasks\2026-04-09-my-task.md -WorklogPath .\worklogs\2026-04-09-my-task-log.md
```

## Prompt-Only Mode

If you only want a reusable prompt block without running checks:

```powershell
.\scripts\skill-codex.ps1 -Stage checkpoint -PlanPath <plan> -WorklogPath <log> -PrintPromptOnly
```

## MVP Rule

- Always run `start`
- Run `checkpoint` only at major checkpoints (speed-first mode)
- Always run `close` before ending session
