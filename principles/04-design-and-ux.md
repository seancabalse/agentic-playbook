# Design and UX principles

What people see and touch. The design is the product, so it gets the same rigour as the code.

## Source of truth

1. **Tokens, not values.** Colours, type, spacing, radii, shadows, motion curves and durations live in one tokens module. Components never hard-code them, and lint or review catches it.
2. **One component kit.** Build screens from shared components (buttons, cards, sheets, toasts, toggles, chips, form fields, the loading gate). New UI patterns join the kit with a preview page (`/dev/kit`, Storybook) before a second screen uses them.
3. **Design files stay outside the repo** when they're licensed or large (keep them gitignored). The repo holds the tokens and components that implement them; ADRs cite the design version.

## Every screen has four states besides "full"

4. **Loading**: a still skeleton in the content's shape, never a spinner over a blank page, and never an empty state before data arrives.
5. **Error**: friendly words, what to do next, and a Try again. Never a raw error or code.
6. **Offline**: a calm note that it's waiting for the connection; cached data still shows.
7. **Empty**: invites the first action, in the product's voice.

A shared gate component (`QueryGate`) decides between them from the query state, so screens don't each reinvent it.

## Words

8. **All copy lives in the message catalogue** (`en.json`, ICU messages), never inline. Lint rejects raw text in markup and on copy props (`title`, `label`, `placeholder`, accessibility labels).
9. **Write from the reader's side.** "Ana approved your invoice", "Your order arrives on Tuesday", not "Invoice status updated by user 2". Names and pronouns come from data, and pronouns are never inferred from a name (`05-accessibility-i18n.md`).
10. **Errors and limits map by code** to friendly messages ("You've reached 10 projects, the most the Free plan holds"), and every new server error code gets one.
11. **Ask before anything destructive** (delete, leave, sign out with unsent work) with a plain consequence: "Your teammates keep the workspace and are told that you left."

## Interaction

12. **Selected states have a cue besides colour**: a tick, an underline, a weight change.
13. **Targets are at least 24 × 24 CSS px** (WCAG 2.5.8), and 44 px is recommended for primary actions. When the drawing is smaller, extend the hit area with padding.
14. **Motion has meaning and an off switch.** It respects the OS's reduce-motion setting, offers a gentle mode, and never runs continuously on the main screen (`11-observability-performance.md`). Animate with the token curves, through one hook that swaps them under gentle or reduced motion.
15. **Text inside fixed-size art scales with the art**, not on its own (SVG text, or a fixed size), and its information is repeated in an accessible name.
16. **Layouts reflow.** A row with a title and side text wraps. A row with a button stacks the button under its text at narrow widths and high zoom. Check 320 CSS px wide, a tablet, a desktop, and 200% zoom.

## Review and evidence

17. **Every UI PR has screenshots** (`ship-pr` won't open one without them): before and after, plus 200% zoom and dark mode or reduced motion when they matter. Store them outside the default branch (for example a `screenshots` branch) and embed them in the PR.
18. **Check it in the real app**, in the browsers and on the platforms you ship, before calling it done. Device emulation is fine for layout but says little about performance.
