# Orchestrator Structure

Use this document when designing or refactoring orchestrator and harness folders.

## Goals

- keep host invocation stable
- keep shared state ownership clear
- separate orchestration flow from domain logic
- make pipeline handoff paths readable and version-safe
- make cloned project structure visible through generated code flow maps before broad changes

## Top-Level Rule

- Split by orchestrator responsibility first.
- Split by reusable logic second.
- Do not mix entry scripts, shared state rules, and domain helpers in one folder unless the scope is tiny and temporary.

## Recommended Folder Shape

```text
orchestrators/
  main-orchestrator/
    entry/
    state-contract/
    handoff/
  <domain>-orchestrator/
    entry/
    readers/
    planners/
    writers/
  shared/
    host/
    state/
    versioning/
    logging/
  harness/
    scenarios/
    fixtures/
    assertions/
```

## Folder Responsibilities

### `main-orchestrator/`

- owns orchestration order
- owns shared state contract
- owns handoff rules
- does not absorb all domain logic

### `<domain>-orchestrator/`

- owns one role or domain slice
- reads central state snapshots
- computes role-specific decisions
- returns updates through the shared contract

### `shared/host/`

- host normalization
- host-specific wrappers
- one stable invocation path for all orchestrators

### `shared/state/`

- canonical state schema
- snapshot readers
- patch writers
- merge and version helpers

### `shared/versioning/`

- artifact naming helpers
- version stamp helpers
- handoff label formatting

### `harness/`

- reusable scenarios and fixtures
- validation rules for orchestrator handoff behavior
- pass/fail assertions separated from orchestration flow

### code flow map

- use `scripts/analyze-code-flow.ps1` to generate `docs/generated/code-flow.mmd` and `docs/generated/code-flow.json`
- treat the generated flow as an onboarding and navigation artifact for unfamiliar cloned projects
- keep static scan results separate from hand-authored architecture docs

## Avoid

- one giant orchestrator folder with entry flow, state logic, domain logic, harness logic, and reporting mixed together
- domain orchestrators writing arbitrary shared values without going through the shared contract
- host-specific branching copied into every orchestrator

## Refactor Trigger

Split the current structure when one of these appears:

- a folder contains both host wrapper code and domain decision logic
- the same shared value key is written from multiple places with different meaning
- harness scenarios depend on private internals instead of stable handoff outputs
- orchestrator files start mixing config parsing, dispatch, mutation, and reporting
