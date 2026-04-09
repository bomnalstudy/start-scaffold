# Orchestration Plan

## Project / Task

- Vault password confirmation and recovery policy

## User Problem

- The encrypted `.env` bundle flow needs a safer passphrase UX and a clear path when the passphrase is forgotten.

## Original Goal

- Improve the project secret bundle flow so export confirms the passphrase and the repository documents what happens if the passphrase is forgotten.

## User Value

- Reduces mistakes during secret export and prevents false expectations about passphrase recovery.

## Priority

- Primary KPI (must): Time saved
- Secondary KPI (optional): Quality that reduces rework

## MVP Scope

- Add passphrase confirmation during export when the passphrase is entered interactively.
- Document that forgotten passphrases are treated as non-recoverable and require a new vault on the next export.
- Keep the current encryption format and import/export file locations unchanged.

## Non-Goal

- Build a full secret management service.
- Add cloud backup or escrow for passphrases.
- Refactor unrelated project bootstrap or hook scripts.

## Generic Requirement

- Keep the change limited to the secret export/import flow and its documentation.

## Stop If

- The recovery requirement implies storing passphrases or introducing a key escrow design.
- The requested UX requires a GUI or cross-platform prompt library outside the current PowerShell approach.

## Pattern

- Small Fix Pipeline

## Roles

### Planner

- Input:
- Output:

### Builder

- Input:
- Output:

### Reviewer

- Input:
- Output:

### Verifier

- Input:
- Output:

### Recorder

- Input:
- Output:

## Scope

- Included:
- Excluded:

## Risks

- Users may assume forgotten passphrases are recoverable unless the docs state the limitation clearly.
- Prompt changes must not break non-interactive usage through parameters or environment variables.

## Done When

- Interactive export rejects mismatched passphrase confirmation.
- Non-interactive export still works with `-Passphrase` or `SECRETS_PASSPHRASE`.
- Docs explain that forgotten passphrases do not unlock old vaults and the workflow is to create a new vault with a new passphrase.

## Verification

- Run export/import scripts with explicit passphrase and review the interactive prompt logic.
- Check documentation for the forgotten-passphrase guidance.

## Why Stop Now

- Once the export safeguard and recovery guidance are in place, the immediate usability risk is addressed without expanding scope.

## Rollback

- Revert the export prompt change and documentation update if the new prompt breaks the existing workflow.
