# Access Control Review Rules

Use this when code reads or writes user-scoped objects, file references, records, or routes.

## Core Rule

- Authentication is not enough.
- Every object access should also verify authorization for that specific object or action.

## High-Risk Cases

- user profile reads by id
- file or report access by name or id
- record update or delete by path or body id
- hidden form fields that carry object identifiers
- URL or body parameters that select resources

## Review Questions

- Does the code trust a client-supplied identifier too early?
- Is the lookup scoped to the current user or current permission set?
- Is a repeated authz check copied around instead of centralized?
- Could changing one id or file reference expose another user's data?

## Preferred Fix Pattern

- add an ownership or authorization guard helper
- import the guard into the entrypoint
- scope object lookup to the current user or allowed resource set

## Avoid

- trusting `id`, `userId`, `accountId`, `file`, or similar values without an authz check
- using sequential ids as if they were authorization
- exposing internal object references as if randomness alone solves access control
