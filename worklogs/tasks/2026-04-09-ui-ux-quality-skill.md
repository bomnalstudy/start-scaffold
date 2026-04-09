# Orchestration Plan

## Project / Task

- UI/UX quality skill for frontend output

## User Problem

- Generated UI often feels amateur, overcrowded, visually inconsistent, or hard to use, especially when the agent optimizes for features over user-friendly presentation.

## Original Goal

- Create a reusable skill or equivalent guardrail that helps Codex produce cleaner, more user-friendly, more visually polished UI/UX by default.

## User Value

- Reduces ugly or confusing frontend output and makes generated components feel more production-ready without repeated manual correction.

## Priority

- Primary KPI (must): Time saved
- Secondary KPI (optional): Quality that reduces rework

## MVP Scope

- Research current public UI/UX quality guidance and relevant open-source references.
- Synthesize the guidance into a reusable skill focused on frontend quality.
- Keep the skill concise and operational rather than turning it into a general design textbook.

## Non-Goal

- Build a full design system.
- Rewrite existing product UI in this session.
- Enforce pixel-perfect brand design without project-specific assets.

## Generic Requirement

- Framework-agnostic where possible, but practical for React/frontend code generation in this repository style.

## Stop If

- The proposed skill becomes too broad to be practical during normal coding sessions.
- The guidance depends on copyrighted or proprietary design material we cannot package safely.

## Pattern

- Feature Delivery Pipeline

## Roles

### Planner

- Input:
- Output:

### Builder

- Input:
- Output:

### Reviewer

- Input:
- Output:

### Verifier

- Input:
- Output:

### Recorder

- Input:
- Output:

## Scope

- Included:
- Excluded:

## Risks

- Advice may become vague unless tied to concrete failure modes such as overflow, contrast, emoji overuse, and feature overload.
- A quality skill can drift into subjective taste unless it prioritizes usability and readability over style preference.

## Done When

- We have a concrete skill structure and guidance for improving generated UI quality.
- The skill addresses the specific failure modes the user named.
- The result is grounded in public references rather than only intuition.

## Verification

- Review the skill against the user’s reported failure modes.
- Verify the skill stays concise enough to be usable in normal sessions.

## Why Stop Now

- Once the skill captures the most common visual and UX failure modes with practical rules, we can iterate later instead of overbuilding the first version.

## Rollback

- Remove the new skill files if the guidance proves too generic or too heavy for day-to-day use.
