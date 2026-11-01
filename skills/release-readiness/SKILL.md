---
name: release-readiness
description: "Audit a release before production: checks, security, accessibility, performance and rollback. Use before each production release."
argument-hint: "[version]"
---

# Release readiness

> Playbook files named here: when the project has its own copy at `.playbook/local/<same path>`, use that copy instead.

Version: $ARGUMENTS

Copy `${CLAUDE_PLUGIN_ROOT}/templates/release-checklist.md` into a dated tracker doc, then work through it. **Every line gets evidence or a ticket.**

1. **Scope**: list the milestone's requirements and tickets. Each is done, or deferred with an owner decision.
2. **Quality**: CI on the release commit; run `verify-feature offline` and `verify-feature layout`; run `a11y-audit app`. Measure performance on real mid-range hardware against the budgets (if no device is available, say so and mark it **not verified**).
3. **Security**: `security-audit project` since the last release; dependency audit; secret scan; the privacy notice matches what is collected.
4. **Data and infrastructure**: migrations applied to prod by the pipeline; the live client is compatible; backups on, and a restore tested; jobs, functions and alerts configured for prod.
5. **Shipping**: version and build bumped; release notes in customer language; rollback plan.
6. **Owner tasks**: list anything only the owner can do (credentials, DNS, signing, approvals), with steps.

## Output

**Ready / Not ready**, the blocking items with tickets, the non-blocking items, and what wasn't verified. Don't mark anything ready that wasn't checked.
