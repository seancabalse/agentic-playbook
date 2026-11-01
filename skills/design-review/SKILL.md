---
name: design-review
description: "Review a UI change for UX, visual quality and use of the design system, from screenshots. Use for each UI change."
argument-hint: "[screen, component or PR]"
---

# Design review

> Playbook files named here: when the project has its own copy at `.playbook/local/<same path>`, use that copy instead.

Scope: $ARGUMENTS

Read: the design source the ticket links (if any), the component kit, the tokens module, and the diff. Principles: `${CLAUDE_PLUGIN_ROOT}/principles/04-design-and-ux.md` and `05-accessibility-i18n.md`.

## Check

1. **Tokens and kit**: no hard-coded colours, fonts, spacing, curves or durations. Kit components are used where they exist, and any new pattern is added to the kit with a preview.
2. **States**: loading (a skeleton in the content's shape), error (friendly, with retry), offline (calm, cached data visible), empty (invites action). Nothing flashes "empty" before data arrives.
3. **Copy**: every string is in the catalogue, in the product's voice, written from the reader's side; names and pronouns come from data. Errors and limits are mapped by code. Destructive actions confirm with their consequence.
4. **Interaction**: selected states have a non-colour cue; targets are at least 24 × 24 CSS px (44 recommended); feedback on press; no dead ends (every sheet and screen has a way back).
5. **Motion**: meaningful, uses the token curves through the motion hook, gentle or reduced mode respected, nothing continuous on the main screen.
6. **Layout**: wraps and stacks at 200% zoom; reflows at 320 CSS px; works at tablet and desktop widths; text in fixed art scales with it and its information is in an accessible name.
7. **Fidelity**: matches the design source (spacing, hierarchy, illustration style). Deviations are deliberate and noted.

## Evidence

Look at real screenshots (ask for them, or capture them via `verify-feature`): the default state, each other state, the largest text size, and the narrowest width. Review what's on screen, not just the code.

## Output

Findings ranked by customer impact, each with a screenshot reference or a file:line and a suggested fix. List what's good too, so it stays that way.
