# Orchestration Plan

## Project / Task

- Use external orchestration and harness references to find missing parts in the scaffold and strengthen the docs.

## User Problem

- The scaffold has strong local rules now, but it may still miss common reliability and harness patterns used in mature orchestration systems.

## Original Goal

- Find the most important missing orchestration and harness patterns from source-backed references and add them to the scaffold.

## User Value

- Reduces blind spots before deeper orchestrator and harness implementation begins.
- Grounds the scaffold in patterns used by durable workflow and testing systems.

## Priority

- Primary KPI (must): Quality that reduces rework
- Secondary KPI (optional): Time saved

## MVP Scope

- Review current source-backed references.
- Add missing orchestrator reliability rules.
- Add missing harness observability and fixture-isolation rules.
- Keep the changes doc-first.

## Non-Goal

- Rebuild the scaffold around any one external framework.
- Add a full workflow engine or test framework.
- Implement every researched pattern immediately in code.

## Generic Requirement

- Keep only high-signal patterns that fit the existing scaffold shape.
- Prefer operational guidance over abstract theory.

## Stop If

- The additions start turning into a broad survey document.
- The scaffold begins copying framework-specific concepts that do not fit the repo.

## Pattern

- Source-Backed Hardening

## Roles

### Planner

- Input: external docs plus current orchestrator/harness docs
- Output: missing-pattern shortlist

### Builder

- Input: shortlist
- Output: doc updates for reliability and harness evidence

### Reviewer

- Input: new rules
- Output: fit-to-scaffold review

### Verifier

- Input: task/worklog
- Output: session guard validation

### Recorder

- Input: chosen patterns and rationale
- Output: worklog

## Scope

- Included: `docs/modes/orchestrator/`, `docs/modes/harness/`, `worklogs/`
- Excluded: new runtime engines, dependency installs

## Risks

- Framework-specific ideas may not translate cleanly.
- The docs could become too abstract if the selected gaps are not concrete enough.

## Done When

- The scaffold documents the most useful missing reliability and harness patterns found in the research.

## Verification

- Review the new docs for overlap and practicality.
- Run session guard checks on the task and worklog.

## Why Stop Now

- The goal is to harden the scaffold’s design vocabulary first, not to over-implement the researched systems.

## Rollback

- Remove the new docs if they prove too abstract or off-target.
