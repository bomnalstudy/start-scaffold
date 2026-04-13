# Host Wrapper Rule

Use one stable host invocation layer for orchestrator execution.

## Why

- host targets change over time
- host-specific branching spreads quickly
- duplicated invocation logic causes drift and inconsistent error handling

## Rule

- Do not let each orchestrator call hosts in its own way.
- Put host selection, normalization, and invocation behind one shared wrapper layer.
- The main orchestrator and worker orchestrators should call the wrapper, not raw host branches.

## Responsibilities of the Host Wrapper

- normalize host names and aliases
- resolve the selected host target
- validate required host parameters
- apply shared retry and timeout defaults
- emit a stable invocation result shape
- emit a stable debug log event shape

## Recommended Shape

```text
shared/host/
  invoke-host.*
  resolve-host.*
  host-types.*
```

## Invocation Contract

Inputs:

- host key
- action name
- normalized payload
- run metadata

Outputs:

- success or failure
- normalized result payload
- host metadata
- error shape with stable fields
- debug event fields that match `docs/modes/orchestrator/structured-debug-logging-rule.md`

## Avoid

- host-specific branching copied into domain orchestrators
- different timeout or retry defaults per orchestrator without an explicit exception
- returning different result shapes for the same logical action

## Escalation Rule

If host variance keeps forcing local exceptions:

1. fix the wrapper first
2. update the host contract
3. only then update orchestrators that depend on the wrapper
