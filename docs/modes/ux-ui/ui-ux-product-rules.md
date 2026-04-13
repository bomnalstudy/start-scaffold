# UI UX Product Rules

This document defines the repository-level baseline for frontend UI and UX quality.

All AI agents in this repository must follow these rules when working on user-facing UI.

## When This Applies

Apply these rules for:

- web pages
- responsive web apps
- app-like touch-first screens
- component design or redesign
- UI polish or UX cleanup
- frontend review tasks

## Required Skill Routing

When the task is frontend UI or UX work:

1. Decide whether the target is web, app, or both.
2. Use the matching quality guard:
   - `web-ui-quality-guard` for browser-first UI
   - `app-ui-quality-guard` for app-first UI
   - `frontend-quality-guard` only as a routing layer when the surface is still unclear
3. Keep the final implementation aligned with the rules below even if the skill is not explicitly named by the user.

## Shared Rules

These rules apply to both web and app UI:

- Make the primary task obvious quickly.
- Reduce feature overload before adding polish.
- Build hierarchy with layout and typography before decoration.
- Keep body text readable and contrast strong.
- Prefer recognition over recall: keep important context and actions visible when they matter.
- Use progressive disclosure instead of dumping all controls into one view.
- Keep the component language coherent across the same surface.
- Do not add emojis by default in product UI.
- Do not let interfaces feel clever at the expense of usability.

## Typography Rules

- Use no more than two font families by default.
- Keep body text in readable regular or medium weights; avoid very thin weights for normal UI reading.
- Build hierarchy with size, weight, spacing, and layout before using color as the main differentiator.
- Keep type scale intentional: headings should step clearly, body sizes should stay consistent, and helper text should remain readable.
- Avoid decorative type choices unless the product surface clearly supports them.

## Color Rules

- Start from a restrained palette: neutrals first, then one primary accent plus semantic colors for success, warning, and error.
- Do not use multiple accent colors at equal visual weight on the same surface.
- Use color to support hierarchy, not replace it.
- Keep normal text contrast strong enough to stay readable; use at least WCAG-level minimum contrast for text and critical UI.
- Reserve saturated colors for actions, status, or focused emphasis rather than broad decoration.

## Icon Rules

- Do not use emoji as product UI icons.
- Prefer outline or wireframe-style icon systems with consistent stroke and sizing.
- Do not mix unrelated icon families on one surface.
- Use icons to support scanning, not to decorate every label or row.
- If no project-specific icon system exists, prefer a consistent outline set such as `Lucide` or a similar wireframe family.

## Layout And Overflow Rules

- Do not let cards, chips, tables, dialogs, or CTA groups drift outside the viewport without a deliberate scrolling pattern.
- Treat narrow widths and small screens as part of the first design pass.
- Important content and actions should still work at `320 CSS px` width without horizontal overflow.
- Keep interactive targets comfortably usable; align with WCAG minimum target-size guidance for important controls.
- Long labels, helper text, empty states, and error states should not break layout when they wrap.

## Reference-First Workflow

- Before implementing a new UI direction, gather 3 to 5 reference images or product examples first.
- Use references to extract patterns, not to copy layouts blindly.
- Summarize what you are borrowing:
  - typography mood
  - spacing density
  - icon style
  - CTA emphasis
  - card/list structure
- Prefer references from strong product UI, not novelty shots or purely decorative concept art.

## Shared Anti-Patterns

Block these by default:

- feature dumping instead of prioritization
- unreadable text from weak contrast or tiny sizing
- decorative clutter replacing hierarchy
- emoji-first or gimmick-first UI
- components leaving the viewport or clipping badly
- mixing too many visual styles in one product surface
- platform-inappropriate interaction patterns
- emoji used as interface icons
- accent-color overload without hierarchy
- overscaled hero sections or cards that force important actions below the fold without reason

## Web Rules

Use these for browser-based products:

- Users should be able to scan the page before reading deeply.
- Secondary actions must not compete with the primary action.
- Empty, loading, error, and success states are part of the design.
- Use width constraints for reading comfort.
- Treat responsiveness as part of the initial solution, not cleanup.
- Keep keyboard focus visible and interaction states distinct.
- Do not rely on hover-only disclosure for critical content.

## Web Anti-Patterns

- dashboard filled with equally loud cards
- page header with too many buttons
- tiny text in dense cards
- tables or filter bars pushing past viewport width
- weak or missing loading/empty/error states
- web UI that imitates a phone screen instead of using browser strengths

## App Rules

Use these for app-first UI:

- Each screen should have one dominant purpose.
- Primary actions should be reachable and obvious.
- Respect safe areas, insets, system bars, sheets, and bottom surfaces.
- Controls should be comfortably tappable and adequately spaced.
- Use platform-appropriate navigation patterns.
- Avoid crowding content at screen edges.
- Keep glanceable content short, grouped, and readable.

## App Anti-Patterns

- app screen that looks like a webpage stacked into a phone frame
- bottom actions too cramped or too close to unsafe edges
- tiny tap targets
- too many cards or actions on one screen
- floating controls competing with the main task
- modal or sheet flows that confuse back navigation

## Source Basis

These rules are grounded in public, established guidance rather than agent preference alone:

- Apple Human Interface Guidelines
- Android / Material adaptive and touch guidance
- W3C WCAG 2.2 accessibility guidance
- Nielsen Norman Group usability heuristics
- public icon-system consistency guidance such as Lucide and Material Symbols references

Use the specialized skill reference files for deeper source notes and links.
