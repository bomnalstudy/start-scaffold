# Orchestration Plan

## Project / Task

- Harden the orchestrator state contract so shared fields require explicit write policies.

## User Problem

- Shared field ownership rules are in place, but the contract does not yet force per-field policy declarations strongly enough.

## Original Goal

- Make the scaffold enforce policy-driven shared state fields rather than relying on vague defaults.

## User Value

- Makes central state governance more reusable across different projects and flows.
- Prevents undeclared or weakly declared fields from slipping into shared state.

## Priority

- Primary KPI (must): Quality that reduces rework
- Secondary KPI (optional): Time saved

## MVP Scope

- Extend the contract example with explicit policy fields.
- Update the patch script to validate immutable and allowed-writer rules.
- Update the docs to describe policy-driven contracts.

## Non-Goal

- Define one universal field policy for every project.
- Add full schema validation for every nested field.

## Generic Requirement

- Keep the policy layer generic and project-agnostic.
- Make validation outcomes explicit and machine-readable.

## Stop If

- The policy rules start hardcoding project-specific field semantics.
- The patch script starts requiring deep nested schema knowledge instead of top-level field policy checks.

## Pattern

- Policy-Driven State Contract

## Roles

### Planner

- Input: existing state contract and patch flow
- Output: policy-hardening scope

### Builder

- Input: contract, script, docs
- Output: stronger policy enforcement

### Reviewer

- Input: policy shape and validation behavior
- Output: genericity and clarity check

### Verifier

- Input: dry-run patch checks and session guard
- Output: validation result

### Recorder

- Input: policy decisions
- Output: worklog

## Scope

- Included: `templates/`, `scripts/`, `docs/modes/orchestrator/`, `worklogs/`
- Excluded: field-by-field deep schema engine

## Risks

- The policy layer could still be too loose if top-level ownership is the only enforced boundary.
- Over-hardening too early could make experimentation awkward.

## Done When

- Shared field policies are explicit in the example contract.
- Patch validation rejects undeclared, immutable, and writer-disallowed updates.

## Verification

- Run a valid dry-run patch.
- Run a stale rejection check.
- Run session guard checks on the task and worklog.

## Why Stop Now

- This improves the scaffold’s governance layer without locking it to any one project schema.

## Rollback

- Revert the policy fields if the contract shape needs a different abstraction later.
