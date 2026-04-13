# Project Context

_Generated automatically by scripts/powershell/context/build-project-context.ps1 at 2026-04-09 17:33:14._

## Project

- Name: start-scaffold
- Summary: Fill this with a one-line product summary.

## Server Guide

### api-server

- When to use: Use for API and data logic tasks.
- Start command: `npm run dev:api`
- Healthcheck: GET /health
- Notes: Replace with your real server details.

### web-server

- When to use: Use for UI and interaction tasks.
- Start command: `npm run dev:web`
- Healthcheck: Open home route in browser
- Notes: Replace with your real server details.

## Data Routes

### Read current user profile

- Root file: `src/data/index.ts`
- Entry points:
  - `src/features/profile/useProfile.ts`
- Notes: Replace with your real data path.

## Critical Files

- `AGENTS.md`: global operation rules
- `docs/token-ops-standard.md`: token discipline standard

## Session Defaults

- Preferred agent: codex
- Default context pack: implement
- Must confirm before scope expansion: True

## Auto-Detected Hints

### Server Candidate Files
- none detected

### Package Scripts
- none detected

## Compact Hand-off Note

- If you start a new chat, read docs/project-context.compact.md first.
- Keep this file updated whenever server/data roots change.

