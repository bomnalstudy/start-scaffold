# Harness Observability Rules

Use these rules so harnesses produce evidence that is easy to debug and compare across runs.

## Core Principle

- A harness should prove behavior with stable evidence, not just a pass/fail boolean.

## Required Evidence

- scenario name
- step name
- expected result
- actual result
- run id when available
- output or log snippet when relevant and safe

## Capture Rules

- Capture stdout and stderr for script harnesses when failures are possible.
- Capture structured logs when the target system already emits them.
- Prefer stable machine-readable fields over freeform console text.

## Good Evidence Targets

- structured debug logs
- normalized JSON outputs
- explicit status codes
- stable assertion fields

## Avoid

- comparing huge raw blobs when a few stable fields are enough
- using private internal variable names as the main assertion surface
- mixing sensitive values into harness failure output
