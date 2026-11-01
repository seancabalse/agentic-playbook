---
name: capture-screenshots
description: "Capture screenshots of each state, size and setting as evidence for a PR. Use for each UI change."
argument-hint: "[ticket id] [screens or flows]"
---

# Capture screenshots

> Playbook files named here: when the project has its own copy at `.playbook/local/<same path>`, use that copy instead.

Request: $ARGUMENTS

Drivers and their traps: `${CLAUDE_PLUGIN_ROOT}/principles/08-testing-qa.md` → "Drivers". Ready-made scripts: `${CLAUDE_PLUGIN_ROOT}/templates/testing/`.

## 1. Decide the matrix (keep it to what the change touches)

| | Default | Add when it matters |
| -- | -- | -- |
| **States** | the populated default | loading, error, offline, empty |
| **Sizes** | 375 px mobile and 1280 px desktop | 320 px (reflow), 768 px tablet, 200% zoom |
| **Settings** | light, normal motion | dark (`colorScheme`), reduced motion |

## 2. Capture

- **Web, with Playwright**: copy `templates/testing/playwright.config.ts` and `screenshots.spec.ts` (if the project has no equivalent), list the routes and states, and run `npx playwright test screenshots.spec.ts`. To explore before scripting, use the agent's browser tools (the built-in browser, Claude in Chrome or the Playwright MCP server), then put the steps in the spec so they're repeatable.
- **Zoom**: 200% browser zoom on a 1280 px window is a 640 CSS px viewport (add `deviceScaleFactor: 2` for sharp text), and 400% is 320 px. Capture those viewports.
- **Name the files** `<screen>-<state>-<variant>.png` (`settings-export-progress-zoom200.png`) and put them in `screenshots/<ticket>/`, which is gitignored.

## 3. Check every image

Open each one and look:
- Is it the right screen and state?
- Is any text clipped or overlapping?
- Is a dev overlay or a loading spinner covering it?
- Is a system dialog in the way?

A blank or half-drawn image usually means the page hadn't finished loading, a request was blocked, or the capture ran mid-animation: fix the cause and recapture. Never ship an image you haven't looked at.

## 4. Hand over

- List the files with one line each (what it shows) in your handoff.
- `ship-pr` publishes them: `templates/testing/push-screenshots.sh <PR> <files…>` pushes to a `screenshots` branch, never the default branch.
- Reset every setting you changed (zoom, colour scheme, reduced motion), and stop what you started.
