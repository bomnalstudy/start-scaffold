# Debug Logging Rule

Use explicit debug logs for orchestrator execution, state handoff, and failure-pattern tracing.

## Why

- debugging breaks when run correlation is missing
- state conflicts are hard to inspect without snapshot and owner metadata
- repeated failures are easier to promote into prevention rules when logs share a stable shape

## Rule

- Log orchestrator debug events in a structured format.
- Do not rely on ad hoc console text as the only debug trail.
- Every debug event must be traceable to one run id and one action.

## Required Fields

- `timestamp`
- `runId`
- `stage`
- `owner`
- `action`
- `host`
- `status`
- `snapshotVersion`
- `artifactVersion`
- `message`

## Optional Fields

- `patchKeys`
- `inputRefs`
- `scenarioId`
- `errorCode`
- `details`

## Logging Moments

- before host invocation
- after host invocation
- before patch commit
- after patch commit
- when snapshot version is stale
- when conflict rejection happens

## Failure-Pattern Connection

- When a recurring orchestrator issue appears, point the failure-pattern entry at the matching debug log fields first.
- Prefer improving log shape before adding guess-heavy prevention rules.

## Avoid

- logging secrets or raw credentials
- logging different field names for the same event type
- hiding correlation ids inside freeform text only
