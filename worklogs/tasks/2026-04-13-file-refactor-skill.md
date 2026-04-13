# Orchestration Plan

## Project / Task

- Create a repo-local file refactoring skill based on the global file design rules

## User Problem

- The repository now has global file design and growth rules, but there is no dedicated skill that turns those rules into a repeatable refactoring workflow for already-existing files.

## Original Goal

- Create a reusable file refactoring skill that helps the agent restructure existing files to match the repository's global file design rules.

## User Value

- Makes refactoring large or mixed-responsibility files more repeatable.
- Reduces the chance that the agent notices a design problem but does not know how to act on it cleanly.

## Priority

- Primary KPI (must): Time saved
- Secondary KPI (optional): Quality that reduces rework

## MVP Scope

- Add one repo-local skill focused on file refactoring against the repository's global file design rules.
- Keep it concise, workflow-oriented, and useful for real file cleanup tasks.
- Reuse existing docs instead of duplicating them.

## Non-Goal

- Build automated refactor scripts.
- Create a mode-specific version for every domain.
- Rewrite existing files in this session just to test the skill.

## Generic Requirement

- The skill should work across frontend, scripts, and orchestrator-related files.
- The skill should reference existing repository rules instead of restating them in full.

## Stop If

- The skill starts duplicating too much of `AGENTS.md` or `file-design-rules.md`.
- The workflow becomes so generic that it no longer helps with actual refactoring decisions.

## Pattern

- Feature Delivery Pipeline

## Roles

### Planner

- Input: existing file design rules and current skill patterns
- Output: minimal skill scope and structure

### Builder

- Input: `skills/`, `AGENTS.md`, shared design docs
- Output: new repo-local refactoring skill

### Reviewer

- Input: new skill text
- Output: trigger clarity and overlap review

### Verifier

- Input: task/worklog
- Output: focused session guard validation

### Recorder

- Input: assumptions and resulting skill
- Output: session worklog

## Scope

- Included: `skills/`, `worklogs/`
- Excluded: new automation scripts, codebase-wide refactors

## Risks

- The skill may overlap too much with global rules if it is too descriptive.
- The skill may stay too abstract if it does not include a practical split workflow.

## Done When

- A repo-local file refactoring skill exists.
- The skill clearly explains when to use it and how to refactor files against the global rules.
- The skill is concise enough to use in normal coding sessions.

## Verification

- Run session guard checks on the task and worklog.
- Review the skill for trigger clarity and actionable steps.

## Why Stop Now

- Once the skill exists and points clearly to the repository's file design rules, we can validate it on real refactoring tasks instead of overbuilding it upfront.

## Rollback

- Remove the new skill if it proves redundant with the global rules or too vague to be useful.
