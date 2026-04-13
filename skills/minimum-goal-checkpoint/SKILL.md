---
name: minimum-goal-checkpoint
description: Run the shared minimum-goal checkpoint workflow for either Claude or Codex. Use at major checkpoints to validate scope, code rules, and worklog alignment.
---

# Minimum Goal Checkpoint

Run:

```powershell
.\scripts\skill-minimum-goal.ps1 -Agent codex -Stage checkpoint -PlanPath <plan path> -WorklogPath <worklog path>
```

or

```powershell
.\scripts\skill-minimum-goal.ps1 -Agent claude -Stage checkpoint -PlanPath <plan path> -WorklogPath <worklog path>
```

Rule:

- Use at major checkpoints, not every turn.
