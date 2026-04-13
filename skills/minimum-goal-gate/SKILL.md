---
name: minimum-goal-gate
description: Run the shared minimum-goal workflow for either Claude or Codex. Use when starting a task, running a checkpoint, or closing a session with explicit stop rationale while keeping one unified skill family.
---

# Minimum Goal Gate

Use this skill to enforce the repository workflow with minimal command typing and one shared naming family.

## Commands

Start:

```powershell
.\scripts\skill-minimum-goal.ps1 -Agent codex -Stage start -TaskName "<task name>" -Pack start
```

```powershell
.\scripts\skill-minimum-goal.ps1 -Agent claude -Stage start -TaskName "<task name>" -Pack start
```

Checkpoint:

```powershell
.\scripts\skill-minimum-goal.ps1 -Agent codex -Stage checkpoint -PlanPath <plan path> -WorklogPath <worklog path>
```

```powershell
.\scripts\skill-minimum-goal.ps1 -Agent claude -Stage checkpoint -PlanPath <plan path> -WorklogPath <worklog path>
```

Close:

```powershell
.\scripts\skill-minimum-goal.ps1 -Agent codex -Stage close -PlanPath <plan path> -WorklogPath <worklog path>
```

```powershell
.\scripts\skill-minimum-goal.ps1 -Agent claude -Stage close -PlanPath <plan path> -WorklogPath <worklog path>
```

Prompt-only block:

```powershell
.\scripts\skill-minimum-goal.ps1 -Agent codex -Stage checkpoint -PlanPath <plan path> -WorklogPath <worklog path> -PrintPromptOnly
```

## Operating Rule

- Always run `start` before coding.
- Run `checkpoint` at major checkpoints only.
- Always run `close` before ending session.
- If a gate fails, pause implementation and fix plan/worklog first.
- Prefer this shared family over the older `claude-speed-*` and `codex-speed-*` names.
