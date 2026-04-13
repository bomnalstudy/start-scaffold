# PowerShell Scripts

This folder groups PowerShell scripts by role.

Current repository status:

- stable compatibility entrypoints still live at `scripts/*.ps1`
- `scripts/powershell/<role>/` is the role map for browsing and staged migration
- shared cross-runtime logic should continue moving into `scripts/shared/`

Role folders:

- `bootstrap/`
- `cleanup/`
- `context/`
- `guards/`
- `harness/`
- `orchestrator/`
- `secrets/`
- `skills/`

Use `ROLE-MAP.md` for the current file-to-role mapping.
