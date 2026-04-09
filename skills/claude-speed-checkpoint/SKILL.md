---
name: claude-speed-checkpoint
description: Run Claude checkpoint gate for speed-first workflow. Use at major checkpoints to validate scope, code rules, and worklog alignment.
---

# Claude Speed Checkpoint

Run:

```powershell
.\scripts\skill-claude.ps1 -Stage checkpoint -PlanPath <plan path> -WorklogPath <worklog path>
```

Rule:

- Use at major checkpoints, not every turn.
