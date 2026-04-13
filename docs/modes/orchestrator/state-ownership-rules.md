# State Ownership Rules

Use this rule set for shared values, references, and state handoff between orchestrators.

## Core Model

- The central state store is the canonical source of truth.
- The central store does not make domain decisions.
- The main orchestrator owns the shared state contract.
- Role-specific orchestrators make role-specific judgments.
- Role-specific orchestrators do not create competing canonical values.

## Ownership Model

### Central State Store

- stores canonical shared values
- stores versions, timestamps, and provenance
- serves snapshots for readers
- accepts validated patch updates

### Main Orchestrator

- defines which values are shared
- defines key names and schema
- defines update rules
- defines merge and conflict policy
- decides when a patch becomes canonical

### Worker Orchestrators

- read snapshots from the central store
- derive or transform values for their role
- submit updates as patches
- never treat local copies as the long-term source of truth

## Required Rules

- Shared values must be registered in the central state contract before use.
- Every shared value must declare its policy fields, not just its type.
- Workers must read from a snapshot, not from another worker's private output.
- Workers must write back patch-shaped updates, not ad hoc full rewrites.
- If the snapshot version is stale, reread and recompute before commit.
- If a field has a clear owner, only that owner may directly modify it.
- Snapshot version and owner should also be present in debug logs for write attempts.

## Policy Fields

Each shared field should declare at least:

- `owner`
- `mutable`
- `allowedWriters`
- `writeMode`
- `conflictPolicy`

The actual values are project- or flow-specific.
The scaffold rule is that the policy must be explicit.

## Write Pattern

```text
read snapshot
-> derive role-specific result
-> prepare patch
-> validate against state contract
-> commit to central store
```

## Conflict Rule

- Do not silently merge two different meanings for the same key.
- When in doubt, preserve the previous canonical value and fail the patch loudly.
- Promote repeated conflicts into a schema or ownership fix, not a local workaround.

## Good Shared Values

- run id
- host target
- artifact version
- selected scenario id
- normalized input references
- stage status

## Avoid

- each orchestrator inventing its own copy of the same reference value
- storing local temporary calculations as canonical shared state
- allowing multiple orchestrators to redefine the meaning of the same field
- hidden mutation through side files with no version marker
