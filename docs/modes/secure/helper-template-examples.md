# Helper Template Examples

Use these templates when secure-mode recommends an additive fix.

## Goal

- fix risky code by adding a focused helper and importing it
- avoid broad rewrites when a narrow wrapper or validator is enough

## Included Templates

- [redact-user-data.example.ts](/c:/Users/ghpjh/Desktop/project/start-scaffold/templates/redact-user-data.example.ts)
- [safe-auth-error.example.ts](/c:/Users/ghpjh/Desktop/project/start-scaffold/templates/safe-auth-error.example.ts)
- [validate-external-url.example.ts](/c:/Users/ghpjh/Desktop/project/start-scaffold/templates/validate-external-url.example.ts)
- [map-request-fields.example.ts](/c:/Users/ghpjh/Desktop/project/start-scaffold/templates/map-request-fields.example.ts)
- [authorize-owned-resource.example.ts](/c:/Users/ghpjh/Desktop/project/start-scaffold/templates/authorize-owned-resource.example.ts)

## Typical Use

- replace raw user identifier logging with `redactUserData`
- replace account-enumerating auth messages with `getSafeAuthErrorMessage`
- replace open-ended URL forwarding with `validateExternalUrl`
- replace wide request binding with `mapRequestFields`
- replace ad hoc ownership checks with `authorizeOwnedResource`

## Rule

- Copy the smallest relevant helper shape.
- Adapt names and types to the current project.
- Import the helper into the existing code path instead of rewriting the whole flow first.
