# File Growth Guard

This document defines the scaffold behavior for preventing oversized files from silently reaching commit and push.

## Goal

- Catch file growth before it turns into a dirty, hard-to-review, hard-to-push repository state.

## Rules

- Staged source files are blocked at commit time if they exceed 500 lines.
- Staged source files are also blocked if they already exceed 300 lines and the current commit adds 40 or more lines.
- Pushes re-run repository code-rules checks so oversized files are harder to ignore.

## Why

- Large files are harder to review and split later.
- Growth should be interrupted while the change is still local and fresh.
- Push-time friction is easier to prevent than to recover from after multiple commits.

## Current Enforcement

- `scripts/hook-pre-commit.ps1`
- `scripts/hook-pre-push.ps1`
- `scripts/run-code-rules-checks.ps1`
