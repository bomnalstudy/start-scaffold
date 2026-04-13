# Harness Scenario Rules

Use explicit naming and validation rules for harness scenarios.

## Scenario Naming

Use this shape:

```text
harness.<scenario>.<version>.<ext>
```

Examples:

- `harness.host-wrapper-dry-run.v1.yaml`
- `harness.stale-snapshot-reject.v1.yaml`
- `harness.state-patch-accept.v1.yaml`

## Scenario Requirements

Every harness scenario should define:

- target
- why it needs protection
- level
- preconditions
- actions
- assertions
- failure output format

## Good Scenario Targets

- host wrapper normalization
- stale snapshot rejection
- patch validation
- handoff packet shape
- debug log required fields

## Assertion Rule

- Prefer stable external behavior over private internals.
- A failing assertion should say what scenario failed, at what step, and what mismatch happened.

## Escalation Rule

- If the same bug is fixed twice, add or strengthen the matching harness scenario.
- If a scenario becomes noisy, reduce scope before deleting it.
