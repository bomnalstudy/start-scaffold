# 2026-04-13 Minimum Goal Skill Unification

## Original Goal

- Merge the split Claude/Codex speed skill family into a shared `minimum-goal-*` naming family that still works for both agents.

## MVP Scope

- Add shared `minimum-goal-start`, `minimum-goal-checkpoint`, `minimum-goal-close`, and `minimum-goal-gate` skills.
- Add a shared `skill-minimum-goal.ps1` runner.
- Keep existing Claude/Codex wrappers and skill names working as compatibility aliases.

## Non-Goal

- Remove every old skill immediately.
- Solve host slash indexing or global install in the same change.

## Done When

- Shared minimum-goal skill files exist.
- The shared runner supports both `codex` and `claude`.
- Existing split wrappers still work through the shared runner.

## Generic Requirement

- Keep the workflow identical across both agents unless a repository rule truly differs.

## Stop If

- The rename starts requiring host-specific slash registry work.
- The compatibility layer would break current command usage.
