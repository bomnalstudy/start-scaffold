---
name: claude-speed-close
description: Run Claude close gate to end session safely with stop rationale and next tasks. Use before ending a task/session.
---

# Claude Speed Close

Run:

```powershell
.\scripts\skill-claude.ps1 -Stage close -PlanPath <plan path> -WorklogPath <worklog path>
```

Rule:

- Always run before ending session.
