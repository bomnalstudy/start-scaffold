---
name: minimum-goal-start
description: Start a minimum-goal task workflow for either Claude or Codex. Use when beginning a new task and needing plan/worklog creation plus initial guard checks without splitting by host.
---

# Minimum Goal Start

Run:

```powershell
.\scripts\skill-minimum-goal.ps1 -Agent codex -Stage start -TaskName "<task name>" -Pack start
```

or

```powershell
.\scripts\skill-minimum-goal.ps1 -Agent claude -Stage start -TaskName "<task name>" -Pack start
```

Rule:

- Run this before implementation.
- Choose the agent with `-Agent codex` or `-Agent claude`.
