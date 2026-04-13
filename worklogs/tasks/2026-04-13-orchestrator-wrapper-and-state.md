# Orchestration Plan

## Project / Task

- Add the first concrete host-wrapper script skeleton and a central state contract example for orchestrator-mode.

## User Problem

- The orchestrator rules are defined, but there is not yet a shared wrapper entry point for host invocation or a concrete state contract example to anchor implementation.

## Original Goal

- Turn the orchestrator-mode design rules into lightweight implementation scaffolds.

## User Value

- Gives later orchestrator code a stable host entry point.
- Makes shared value ownership concrete before parallel orchestrators start writing conflicting state.

## Priority

- Primary KPI (must): Quality that reduces rework
- Secondary KPI (optional): Time saved

## MVP Scope

- Add a shared host-wrapper PowerShell skeleton with normalized input and output shape.
- Add a concrete example state contract file.
- Keep runtime adapter execution intentionally minimal unless explicitly wired later.

## Non-Goal

- Build the full orchestrator runtime.
- Implement real host-specific adapters.
- Add new hooks or automated enforcement in this pass.

## Generic Requirement

- Keep the wrapper output stable and easy to inspect.
- Keep the state contract explicit about ownership and patch rules.

## Stop If

- The wrapper starts turning into a full orchestration runtime.
- Host-specific logic begins to spread beyond the shared wrapper boundary.

## Pattern

- Shared Wrapper Skeleton

## Roles

### Planner

- Input: orchestrator foundation docs and current scripts
- Output: minimal implementation targets

### Builder

- Input: scripts and template paths
- Output: wrapper skeleton and contract example

### Reviewer

- Input: new files
- Output: shape and scope check

### Verifier

- Input: task/worklog and dry-run command
- Output: session guard plus wrapper dry-run validation

### Recorder

- Input: implementation notes
- Output: worklog

## Scope

- Included: `scripts/`, `templates/`, `worklogs/`
- Excluded: real adapter execution, harness scenarios

## Risks

- A generic wrapper can drift if it is too abstract to use.
- Future adapters could bypass the wrapper unless the boundary stays explicit.

## Done When

- A shared host-wrapper script exists with normalized dry-run output.
- A central state contract example exists for future orchestrator flows.

## Verification

- Run the host wrapper in dry-run mode.
- Run session guard checks on the task and worklog.

## Why Stop Now

- The user asked for a starting point, and the skeleton is enough to anchor the next implementation step without overbuilding.

## Rollback

- Remove the wrapper skeleton and contract example if they prove misleading.
