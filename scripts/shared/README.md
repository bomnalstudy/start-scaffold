# Shared Script Layer

This folder is for reusable logic that should not depend on one shell entrypoint.

Use it for:

- runtime and environment detection helpers
- shared parsing and normalization logic
- stable contracts that both PowerShell and future bash entrypoints can follow

Do not put large user-facing entry scripts here.
Keep this layer implementation-focused and wrapper-agnostic.
