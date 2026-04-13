---
name: minimum-goal-close
description: Run the shared minimum-goal close workflow for either Claude or Codex. Use before ending a task or session so the stop rationale and next tasks are recorded.
---

# Minimum Goal Close

Run:

```powershell
.\scripts\skill-minimum-goal.ps1 -Agent codex -Stage close -PlanPath <plan path> -WorklogPath <worklog path>
```

or

```powershell
.\scripts\skill-minimum-goal.ps1 -Agent claude -Stage close -PlanPath <plan path> -WorklogPath <worklog path>
```

Rule:

- Always run before ending session.
