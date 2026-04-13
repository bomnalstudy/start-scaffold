---
name: code-refactor-mode
description: Narrow the session to code review and maintainability-focused refactoring work in this repository. Use when the user asks to review code quality, reduce duplication, split mixed responsibilities, clean stale aliases, or refactor without destabilizing behavior.
---

# Code Refactor Mode

Read first:

1. `AGENTS.md`
2. `docs/modes/shared/agent-modes.md`
3. `docs/modes/shared/file-design-rules.md`
4. `docs/modes/code-refactor/code-refactor-guide.md`
5. `docs/modes/code-refactor/review-rules.md`
6. `docs/modes/code-refactor/refactor-patterns.md`
7. `docs/modes/code-refactor/cleanup-rules.md`
8. `docs/modes/code-refactor/reference-patterns-and-tooling.md`
9. `docs/modes/secure/file-growth-guard.md`
10. the current task plan and worklog

If cleanup or dead-weight removal is part of the task, run:

```powershell
.\scripts\find-code-refactor-candidates.ps1
```

Focus on:

- maintainability-focused code review
- duplication and drift risk
- mixed responsibilities
- review-friendly split boundaries
- stale aliases, empty folders, and conservative cleanup
- behavior-preserving refactors

Do not turn this mode into a broad rewrite or architecture redesign unless the task explicitly asks for it.
