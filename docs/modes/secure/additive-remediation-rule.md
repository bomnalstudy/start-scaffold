# Additive Remediation Rule

Use this rule when secure-mode fixes a vulnerability in existing code.

## Goal

- reduce security risk without casually breaking working behavior

## Preferred Fix Style

- Prefer adding a new helper, wrapper, validator, sanitizer, or guard file.
- Import the new file into the current code path.
- Keep direct in-place rewrites narrow unless the unsafe code cannot be contained any other way.

## Good Additive Fixes

- `redact-sensitive-fields.*`
- `validate-external-url.*`
- `sanitize-html-content.*`
- `authz-guard.*`
- `safe-storage.*`
- `validate-file-path.*`

## Why

- easier to review
- easier to roll back
- lower chance of accidentally breaking unrelated behavior
- easier to reuse when the same issue appears elsewhere

## Acceptable Direct Changes

- replacing one obviously unsafe sink with a safe helper call
- removing raw secret logging
- tightening a constant or default that has a clear safe value

## Avoid

- broad refactors in the name of security
- mixing a vulnerability fix with unrelated cleanup
- rewriting multiple flows when a wrapper or helper would contain the risk

## Secure Review Output

When secure-mode reports a fix, prefer this shape:

- vulnerability
- evidence
- likely impact
- additive fix path
- direct code change scope
- follow-up checks
