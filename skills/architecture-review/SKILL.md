---
name: architecture-review
description: "Review a design or a change for structural fit: tenancy, access, data flow, sync and coupling. Use before a large feature or for a structural change."
argument-hint: "[feature, PR, or 'system']"
---

# Architecture review

> Playbook files named here: when the project has its own copy at `.playbook/local/<same path>`, use that copy instead.

Scope: $ARGUMENTS

Read first: the relevant ADRs, the Architecture & Data Model doc, `AGENTS.md`, and for a PR the diff plus the code it touches. Principles: `${CLAUDE_PLUGIN_ROOT}/principles/02-architecture.md` and `09-data-and-migrations.md`.

## Check

1. **Fit with decisions**: does it follow the ADRs? If it departs from one, is that intended (and then a new ADR is needed)?
2. **Tenancy and access**: every new row and object is scoped to the tenant; access is enforced at the data layer with tests; server-only values are fetched online.
3. **Boundaries**: one client per service; layers depend one way; no reaching into another feature's internals; shared rules have one home.
4. **Data flow**: query keys scoped by tenant and by user; writes are idempotent with client ids; offline writes go through the durable queue if the product needs it; there's a single retry layer; live updates invalidate; nothing shows "empty" before data arrives.
5. **Time**: UTC instants plus zones, calendar dates as dates, the shared time module, and entry in the zone where the event happens.
6. **Lifecycle**: soft delete and purge, files follow rows, server-stamped fields, idempotent and re-plannable jobs.
7. **Product hooks**: entitlement checks on costly creates, configuration as data, privacy by construction.
8. **Performance shape**: no always-on work, budgets known, heavy work off the UI thread.
9. **Evolution**: old clients keep working through the migration; the change is reversible or forward-fixable.

## Output

- **Verdict**: fits / fits with changes / needs an ADR first.
- **Findings**, ranked: each with the concrete risk (scenario → consequence), the principle it breaks, and the suggested change. No style preferences.
- **Decisions needed**: for the owner (product) or for an ADR (technical).
- Offer to file the findings as tickets.
