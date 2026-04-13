# Reference Patterns And Tooling

Use these references when deciding how to review and refactor code.

## Review References

- Google engineering practices are a useful reference for review tone, reviewer intent, and making maintainability concerns explicit.
- Sonar’s clean-code framing is a useful reference for maintainability-oriented issue language.

## Refactor References

- Martin Fowler’s refactoring guidance is a useful reference for behavior-preserving structural change.
- JetBrains refactoring docs are a useful reference for rename, extract, and reference-safe local transformations.

## Selection Rule

- Use repository rules first, then borrow only the smallest external pattern that helps explain the next safe change.
- Do not import a whole style system just because one refactor pattern looked appealing.
