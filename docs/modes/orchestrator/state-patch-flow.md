# State Patch Flow

Use this as the first concrete implementation path for shared state updates.

## Goal

- let worker orchestrators read a central snapshot
- reject stale writes
- allow only owner-scoped patch updates
- keep a stable debug trail for write attempts

## Files

- `templates/orchestrator-state-contract.example.json`
- `templates/orchestrator-state-snapshot.example.json`
- `templates/orchestrator-state-patch.example.json`
- `scripts/apply-orchestrator-state-patch.ps1`

## Patch Contract

Patch input must include:

- `runId`
- `snapshotVersion`
- `changes`

Patch changes use dotted paths:

- `workerOutputs.prompt-orchestrator.summary`
- `stageStatus.execute`

## Validation Rules

- reject if a patch key does not map to a declared shared field policy
- reject if a field is immutable
- reject if the current writer is not allowed for the field
- reject if `snapshotVersion` is stale
- reject if patch keys are outside the owner's allowed prefixes
- bump `snapshotVersion` after a successful apply
- write debug log entries for reject and apply outcomes

## Dry-Run Example

```powershell
.\scripts\apply-orchestrator-state-patch.ps1 `
  -ContractPath .\templates\orchestrator-state-contract.example.json `
  -StatePath .\templates\orchestrator-state-snapshot.example.json `
  -PatchPath .\templates\orchestrator-state-patch.example.json `
  -Owner prompt-orchestrator `
  -DryRun
```

## First Real Harness Targets

- `harness.stale-snapshot-reject.v1.yaml`
- `harness.state-patch-accept.v1.yaml`
