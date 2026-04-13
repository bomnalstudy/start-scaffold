# Code Refactor Guide

`code-refactor-mode` is the dedicated mode for review-driven refactoring.

Use it when the goal is not only to change code, but to make the codebase easier to review, safer to evolve, and less likely to keep accumulating mixed responsibilities.

## Primary Goal

- Improve maintainability without casually changing behavior.
- Review the target area before refactoring it.
- Prefer small, evidence-backed improvements over broad rewrites.

## Working Order

1. review the target code and name the real problems
2. identify the smallest safe refactor boundary
3. move or simplify code without changing intended behavior
4. clean obvious dead weight conservatively
5. re-run focused checks and stop

## Typical Triggers

- oversized or mixed-responsibility files
- repetitive copy-paste logic
- review friction caused by tangled naming or branching
- stale wrappers, empty folders, or dead aliases
- code-rules warnings tied to maintainability
