---
name: failure-pattern-mode
description: Narrow the session to repeated-problem tracking and prevention in this repository. Use when the user asks to record recurring failures, stop the same mistake from repeating, extract lessons from worklogs, or add lightweight prevention rules.
---

# Failure Pattern Mode

Read first:

1. `docs/modes/shared/agent-modes.md`
2. `docs/modes/failure-pattern/vibe-coding-failure-prevention.md`
3. `docs/modes/failure-pattern/journaling.md`
4. `docs/modes/failure-pattern/pattern-template.md`
5. the relevant worklogs and task plans

Focus on:

- recurring failures
- triggers and root causes
- enforcement shape
- escalation rules
- reusable log format

## Decision Rule

- Do not force a pattern when the evidence is weak.
- If no repeated or high-confidence pattern exists, explicitly say `No actionable failure pattern found`.
- Treat one-off mistakes as observations unless recurrence risk is clearly high.
- Only promote a problem into a failure pattern when prevention is likely to save more time than it costs.

## Workflow

1. Review the recent task plans, worklogs, and warnings.
2. Decide whether there are any actionable patterns at all.
3. If there are none, report that clearly and stop.
4. If there are patterns, pick only 1 to 3 repeated or high-cost patterns.
5. For each pattern, define:
   - trigger
   - early signal
   - prevention rule
   - enforcement target
   - escalation path
6. Prefer the lightest enforcement that will actually prevent recurrence:
   - document rule
   - task/worklog template
   - code-rules check
   - git hook
7. Escalate a warning into a stronger check only when the same pattern keeps repeating.

## Output Shape

If patterns exist, report them in this order:

- pattern
- trigger
- early signal
- prevention rule
- enforcement
- escalation
- next check

If no pattern exists, report:

- `No actionable failure pattern found`
- reason
- what to keep observing

## Avoid

- long retrospective summaries without operational changes
- recording too many patterns at once
- jumping to a git hook when a doc or workflow rule would be enough
- inventing a pattern just to produce output

Do not turn this into a heavy postmortem process unless explicitly requested.
