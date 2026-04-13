# Refactor Patterns

Use these patterns when choosing how to reshape code safely.

## Preferred Patterns

- rename unclear symbols to make ownership obvious
- extract small pure helpers from mixed logic
- split entry flow from helpers in scripts
- split render, state, API, and transform concerns into colocated files
- replace duplicated inline logic with one shared helper when semantics truly match
- remove or archive dead aliases after confirming a stable replacement exists

## Preferred Scope

- one target file or one tightly related file set at a time
- one primary maintainability problem at a time
- one cleanup pass for dead weight only after active references are checked

## Avoid

- large abstraction jumps not justified by the current code
- replacing concrete readable code with indirection for its own sake
- mixing security, product, and refactor changes unless the task explicitly needs all three
