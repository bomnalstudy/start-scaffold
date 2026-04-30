# File Line Threshold Log

## What Changed

- Clarified that 300+ lines is a watch threshold, not a split requirement.
- Kept 500+ lines as the actual split threshold for non-generated files without clear exceptions.
- Renamed the 300-line checker warning from `line-budget-warning` to `line-budget-watch`.

## Why

The intended rule is that files under 500 lines can remain valid when responsibility is clear. Files over 300 lines should be monitored, but not split automatically.

## Verification

- Ran `.\scripts\run-code-rules-checks.ps1`; it passed with 0 errors and 0 warnings.

## Remaining Risk

- Mixed-responsibility files under 500 lines can still be poor design, so responsibility checks remain relevant.
