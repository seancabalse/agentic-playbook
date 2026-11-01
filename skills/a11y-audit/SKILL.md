---
name: a11y-audit
description: "Audit a screen or a release for WCAG 2.2 AA accessibility. Use for each new screen and before a release."
argument-hint: "[screens or 'app']"
---

# Accessibility audit

> Playbook files named here: when the project has its own copy at `.playbook/local/<same path>`, use that copy instead.

Scope: $ARGUMENTS

Principles: `${CLAUDE_PLUGIN_ROOT}/principles/05-accessibility-i18n.md`. Report shape: `${CLAUDE_PLUGIN_ROOT}/templates/audit-report.md`.

## Static pass (code)

- Every interactive element has a role and a label (plus a hint where useful); decorative art is hidden; people and things are named fully.
- No raw strings; plurals and selects in ICU; no concatenated sentences; no pronoun inferred from a name.
- Selected, error and required states aren't colour-only. Text and UI contrast comes from the tokens (4.5:1 for text, 3:1 for large text and UI).
- Text is sized in relative units; text in fixed art scales with the art and is mirrored in an accessible name; rows wrap; button rows stack at narrow widths and high zoom.
- Targets are at least 24 × 24 CSS px (44 recommended), or padding extends the hit area.
- Animations respect reduce motion, including entering animations, which never leave content at opacity 0.
- Semantic elements, labelled form fields, focus management on dialogs and route changes, no `tabindex > 0`, skip link; axe has no violations.

## Live pass (browser)

1. The largest text size: 200% zoom (1.4.4), and reflow at 320 CSS px (400% zoom, 1.4.10). Screenshot each screen and look for clipping, overlap, truncation and sideways scrolling.
2. Screen reader: NVDA (Windows) or VoiceOver (macOS). Swipe through each screen: order, labels, roles, state announcements, nothing unreachable.
3. Reduce motion on: nothing moves continuously, and nothing is invisible.
4. Keyboard: Tab through everything, focus is visible, no traps, Escape closes dialogs.
5. Reset every setting you changed.

## Output

A dated audit doc with findings per WCAG criterion: severity, screen, evidence (screenshot), fix. Each finding becomes a ticket labelled accessibility. Include "checked and fine" so the next audit can compare.
