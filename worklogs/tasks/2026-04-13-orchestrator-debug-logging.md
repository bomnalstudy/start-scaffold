# Orchestration Plan

## Project / Task

- Add orchestrator debug logging rules and connect the host wrapper to a stable debug event shape.

## User Problem

- Orchestrator debugging and pattern tracing can drift without stable log fields, making failures harder to connect and prevent.

## Original Goal

- Prevent separate errors in debugging and pattern linkage by standardizing orchestrator debug logs.

## User Value

- Makes host and state issues traceable across runs.
- Gives failure-pattern work better evidence before adding new prevention rules.

## Priority

- Primary KPI (must): Quality that reduces rework
- Secondary KPI (optional): Time saved

## MVP Scope

- Add a debug logging rule doc for orchestrator-mode.
- Add an example debug log event.
- Let the host wrapper optionally append structured debug log entries.

## Non-Goal

- Build a full logging backend.
- Add secret-heavy or verbose tracing.
- Instrument every orchestrator path in this pass.

## Generic Requirement

- Keep logs structured and correlation-friendly.
- Avoid logging secrets.

## Stop If

- Logging work starts spreading into unrelated runtime instrumentation.
- The log shape becomes too noisy to use during normal debugging.

## Pattern

- Structured Debug Trace

## Roles

### Planner

- Input: current wrapper and orchestrator docs
- Output: minimum useful log shape

### Builder

- Input: wrapper scripts and docs
- Output: log rule, example, optional debug write path

### Reviewer

- Input: log fields and wrapper behavior
- Output: consistency check

### Verifier

- Input: wrapper dry-run and session guard
- Output: debug-log and plan/worklog validation

### Recorder

- Input: logging decisions
- Output: worklog

## Scope

- Included: `docs/modes/orchestrator/`, `templates/`, `scripts/`, `worklogs/`
- Excluded: full telemetry system, external sinks

## Risks

- The log shape could become noisy if too many optional fields are treated as required.
- Future runtime code could still bypass the wrapper and skip the structured logs.

## Done When

- Orchestrator-mode has a debug logging rule.
- The host wrapper can write structured debug entries when asked.

## Verification

- Run the host wrapper in dry-run mode with a debug log path.
- Run session guard checks on the task and worklog.

## Why Stop Now

- A stable log contract is enough to support the next implementation layer without overbuilding telemetry.

## Rollback

- Remove the optional debug log output if it proves noisy or misleading.
