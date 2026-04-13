# Review Rules

Use these rules when `code-refactor-mode` is reviewing code before changing it.

## Review First

- Review for maintainability, readability, and safe change boundaries before refactoring.
- Prefer findings that explain future cost, not only current discomfort.
- Name the problem in concrete terms such as duplication, hidden ownership, wide branching, oversized file, or mixed responsibilities.

## Focus Areas

- duplicated logic with drifting behavior risk
- mixed responsibilities in one file or function
- naming that obscures ownership or intent
- large switch or branching paths that hide separate behaviors
- wrappers or aliases that only preserve old names and no longer add value
- dead or low-value files that still create maintenance choices

## Refactor Safety

- Refactoring should preserve intended behavior unless the task explicitly includes behavioral cleanup.
- Prefer refactors that can be explained as rename, extract, move, split, simplify, or remove.
- Stop when the reviewable unit is healthier; do not turn one cleanup into a rewrite campaign.
