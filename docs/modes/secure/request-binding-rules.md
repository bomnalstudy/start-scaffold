# Request Binding Rules

Use this when code maps request input into models, config objects, or persistence payloads.

## Core Rule

- Never bind all user input into a privileged object by default.

## Typical Risk

- request or form data contains fields the developer did not intend to expose
- a privileged flag, role, status, or internal field is accidentally writable

## Look For

- direct object spread from request or form data
- model creation from full request bodies
- update payloads built from unchecked client fields

## Preferred Fix Pattern

- create a small allowlisted DTO or mapping helper
- copy only the accepted fields into the new object
- keep sensitive or privileged fields out of that mapper by default

## Good Additive Fixes

- `map-request-fields.*`
- `safe-update-payload.*`
- `create-public-dto.*`

## Avoid

- `...req.body` or equivalent wide binding into privileged objects
- trusting hidden form fields for privilege-related values
- mixing public editable fields and internal state flags in one update shape
