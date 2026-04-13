# Stale Snapshot Reject Harness

Use this when a worker orchestrator must fail safely on an outdated snapshot version.

## Target

- central state contract patch validation

## Why It Needs Protection

- stale writes can overwrite canonical values with outdated assumptions

## Harness Level

- Script Harness

## Scenario

- `harness.stale-snapshot-reject.v1.yaml`

## Preconditions

- central store snapshot version is `v2`
- worker reads an older snapshot version such as `v1`
- worker prepares a patch against the older version

## Actions

1. submit patch with stale snapshot version
2. validate patch against the state contract

## Assertions

- patch is rejected
- canonical state is unchanged
- failure output includes `snapshotVersion`, `owner`, and `errorCode`
- debug log contains a stale snapshot event

## Failure Output Format

- Scenario:
- Step:
- Expected:
- Actual:

## Notes

- promote this into a concrete script harness as soon as the first real patch-apply flow exists
