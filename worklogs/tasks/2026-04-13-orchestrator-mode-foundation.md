# Orchestration Plan

## Project / Task

- Define the first real orchestrator-mode foundation rules for structure, host invocation, state ownership, and artifact version naming.

## User Problem

- Orchestrator work has been drifting because host handling changes, shared values are interpreted differently, and orchestrator logic is not yet grouped by clear responsibility.
- The scaffold needs stable design rules before deeper orchestrator or harness implementation starts.

## Original Goal

- Turn orchestrator-mode into a practical design rule set for naming, folder structure, host wrappers, and shared state ownership.

## User Value

- Reduces orchestrator conflicts before code is written.
- Makes pipeline and harness work easier to reason about later.

## Priority

- Primary KPI (must): Quality that reduces rework
- Secondary KPI (optional): Time saved

## MVP Scope

- Add orchestrator-mode docs for structure, host wrapper rules, shared state ownership, and version naming.
- Update the orchestrator skill so it reads the new docs first.
- Keep this pass at the design-rule level rather than implementing the orchestrator itself.

## Non-Goal

- Build the full orchestrator runtime.
- Add a full harness implementation.
- Add automated enforcement beyond documentation updates in this pass.

## Generic Requirement

- Keep the rules readable enough to be used during normal coding sessions.
- Make ownership and naming rules explicit enough that future code can follow them without reinterpretation.

## Stop If

- The work starts expanding into a full runtime design or concrete host integration implementation.
- The naming rules become too abstract to use in real files and outputs.

## Pattern

- Design Rule Foundation

## Roles

### Planner

- Input: user requirements and current orchestrator skill/docs
- Output: focused rule set

### Builder

- Input: orchestrator docs and skill entry point
- Output: new mode-owned docs and updated read order

### Reviewer

- Input: new rule docs
- Output: consistency and scope review

### Verifier

- Input: task/worklog
- Output: session guard validation

### Recorder

- Input: rule decisions
- Output: worklog

## Scope

- Included: `docs/modes/orchestrator/`, `skills/orchestrator-mode/`, `worklogs/`
- Excluded: runtime scripts, hooks, harness code

## Risks

- Rules could still be too generic if they do not map cleanly to later code structure.
- Existing orchestrator docs include older material, so read order must stay clear.

## Done When

- Orchestrator-mode has concrete docs for structure, host wrappers, shared state ownership, and version naming.
- The skill points at those docs first.

## Verification

- Review the new docs for clarity and overlap.
- Run session guard checks on the task and worklog.

## Why Stop Now

- The user asked for design foundations first, and that can be closed before implementation.

## Rollback

- Remove the new docs and skill links if the structure proves misleading.
