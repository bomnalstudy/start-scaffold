# PowerShell Entrypoints

This folder is reserved for PowerShell-first wrapper entrypoints when the scaffold grows beyond a single-root `scripts/` layout.

Current repository status:

- the main PowerShell entry scripts still live at `scripts/*.ps1`
- shared runtime helpers now live under `scripts/shared/`
- future PowerShell-only launchers should move here gradually instead of forcing one large migration

Keep wrappers thin and move reusable logic into `scripts/shared/` when possible.
