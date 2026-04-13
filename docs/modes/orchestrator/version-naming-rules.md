# Version Naming Rules

Use explicit version labels for orchestrator and harness artifacts so pipeline stages do not confuse near-identical files or outputs.

## Naming Goals

- show owner clearly
- show artifact type clearly
- show version clearly
- keep names sortable

## Standard Shape

```text
<owner>.<artifact>.<version>.<ext>
```

Examples:

- `main-orchestrator.state-contract.v1.json`
- `prompt-orchestrator.input-snapshot.v2.json`
- `harness.scenario-login.v1.yaml`
- `shared-host.invoke-result.v3.json`

## Owner Segment

Use the producing unit, not a vague team name.

Examples:

- `main-orchestrator`
- `secure-orchestrator`
- `ux-ui-orchestrator`
- `harness`
- `shared-host`

## Artifact Segment

Use the artifact purpose, not the implementation detail.

Examples:

- `state-contract`
- `input-snapshot`
- `handoff-packet`
- `scenario-login`
- `invoke-result`

## Version Segment

- Use `v<number>` for human-facing artifact versions.
- Increment the version when the schema, expected fields, or handoff semantics change.
- Do not bump the version for timestamp-only or run-only differences.

## Handoff Rule

The same version label must appear consistently in:

- file names
- generated output metadata
- plan or worklog references when that artifact is important to the task
- handoff documentation between orchestrators or harness stages

## Folder Rule

- Separate versions by filename, not by deeply nested version folders, unless an external tool requires the folder split.
- Keep different artifact types in different folders when they serve different pipeline stages.

## Avoid

- generic names like `result-final.json`
- mixing version and timestamp in a way that hides the actual schema version
- reusing `v1` after changing meaning
- placing unrelated artifact types in one dump folder
