# Token Ops Research Notes

This note captures the research basis for the repository's token-efficiency standard.

## Key Findings

## 1) OpenAI prompt caching rewards stable prompt prefixes

What matters:

- static/repeated content should be placed first
- dynamic/user-specific content should come later
- cache usage can be tracked via `cached_tokens`

Why this matters for us:

- fixed task headers and templates reduce repeated cost
- changing wording every turn hurts cache hit potential

Source:

- https://platform.openai.com/docs/guides/prompt-caching

## 2) Anthropic provides token-efficient tool use modes (model dependent)

What matters:

- token-efficient tool use can reduce output token usage
- support depends on model and feature constraints

Why this matters for us:

- we should keep tool responses compact and structured
- feature availability must be checked per active Claude model

Source:

- https://docs.anthropic.com/pt/docs/agents-and-tools/tool-use/token-efficient-tool-use

## 3) Aider emphasizes controlled repo context, not "everything in context"

What matters:

- repo map can overwhelm weaker models
- context breadth should be tuned intentionally (for example `--map-tokens`)

Why this matters for us:

- default to narrow context
- expand context only when blocked

Source:

- https://aider.chat/docs/faq.html

## 4) Continue shows practical selective-context patterns in OSS workflows

What matters:

- context is chosen by providers (`@File`, `@Code`, `@Diff`, etc.)
- targeted context beats broad raw context for routine tasks

Why this matters for us:

- we should pass only relevant files/snippets/diffs
- we should avoid full codebase dumps in normal runs

Source:

- https://docs.continue.dev/customize/custom-providers

## Standardization Decision

Based on these sources, this repository standardizes on:

- stable prompt headers
- minimal scoped context
- single-objective runs
- strict MVP-first closure
- explicit stop conditions

Formal rules are defined in:

- `docs/token-ops-standard.md`
