# Failure Pattern Template

Use this template when a repeated issue should become a concrete prevention rule.

If no repeated or high-confidence pattern exists, do not force one.
Record a short no-pattern result instead.

## Failure Pattern

- Pattern:
- Why it happened:
- Trigger:
- Early signal:
- Prevention Rule:
- Enforcement:
- Escalation:
- Next check:

## Notes

- `Pattern`: short name for the repeated problem
- `Why it happened`: likely cause, not just the symptom
- `Trigger`: the condition that tends to recreate the problem
- `Early signal`: warning sign before the full failure appears
- `Prevention Rule`: what should happen differently next time
- `Enforcement`: where the rule should live
  - `AGENTS.md`
  - shared docs
  - mode docs
  - task template
  - worklog template
  - code-rules script
  - pre-commit
  - pre-push
- `Escalation`: what to do if the same pattern appears again
- `Next check`: the next concrete validation point

## No Pattern Result

- Result: `No actionable failure pattern found`
- Reason:
- Keep observing:
