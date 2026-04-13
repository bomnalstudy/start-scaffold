# Harness Guide

Use harness-mode when the task is about scenario validation, repeatable assertions, or regression-safe verification loops.

## Purpose

- verify orchestrator and pipeline behavior
- capture repeatable scenario checks
- keep verification logic separate from orchestration logic
- protect critical cross-runtime flows such as secrets roundtrip and host/state contracts

## Harness Levels

### Prompt Harness

- lightweight checklist validation
- good for early design or manual verification

### Script Harness

- repeatable script-driven checks
- good when the same verification must run many times

### Test Harness

- integrated automated tests or end-to-end flows
- good when the scenario is stable and worth ongoing maintenance

## Core Pieces

- `scenario`
- `preconditions`
- `actions`
- `assertions`
- `failure output`

## Ownership Rule

- Harnesses verify behavior.
- Orchestrators perform behavior.
- Do not mix harness scenario definitions into orchestrator runtime files unless the scope is still tiny and temporary.

## Recommended Flow

1. define the scenario
2. define what failure must look like
3. pick the lightest harness level that still catches the bug
4. keep pass/fail output short and reusable

## Avoid

- tightly coupling harness logic to private implementation details
- using a harness file as a second orchestrator
- mixing scenario definition with production mutation logic
