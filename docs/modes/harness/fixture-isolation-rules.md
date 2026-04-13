# Fixture Isolation Rules

Use these rules when harness scenarios need reusable setup or test data.

## Core Principle

- Every scenario should be runnable in isolation with its own local state.

## Rules

- Keep setup explicit and reusable.
- Prefer small fixtures that compose rather than one giant shared setup.
- Isolate temp files, state snapshots, logs, and browser/session storage per scenario.
- Cleanup should be reliable even when the scenario fails.

## Scope Guidance

- use function-level isolation by default
- use broader shared setup only when the cost is high and cross-test leakage is controlled
- if a shared fixture exists, document why it is safe

## For This Scaffold

- temporary state files should be scenario-local
- temporary debug log files should be scenario-local
- harness scripts should clean up generated files unless inspection is explicitly requested

## Avoid

- scenarios that depend on outputs from earlier scenarios
- one shared temp file for unrelated checks
- cleanup logic that only runs on success
