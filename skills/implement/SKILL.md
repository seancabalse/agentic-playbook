---
name: implement
description: "Build a planned change in small, test-first steps, with the layer checklists and a self-review. Use when you write product code."
argument-hint: "[ticket id or plan step]"
---

# Implement

> Playbook files named here: when the project has its own copy at `.playbook/local/<same path>`, use that copy instead.

Work: $ARGUMENTS

`AGENTS.md` is the law: the project's rules win over anything here. Principles: `${CLAUDE_PLUGIN_ROOT}/principles/01-engineering.md` (how code is written), `02-architecture.md`, `04-design-and-ux.md`, `05-accessibility-i18n.md`, `06-security-privacy.md`, `08-testing-qa.md`, `09-data-and-migrations.md`.

## Before the first line

1. **Have a plan with checks** (`start-task`). If there isn't one, write the short version now: steps, and a verify for each.
2. **Know the product intent**: the acceptance criteria, the requirement ids, and the owner decisions already made. If a customer-visible behaviour isn't settled (a wording, a limit, what happens on delete, who sees what), **stop and ask**. Don't invent product.
3. **Read before writing**: the code you'll change, its tests, and the nearest existing example of the same kind of change. Follow that pattern.
4. **Check the docs for the installed version** of any API you'll call. Memory isn't a source.
5. **Order the work bottom up**: data → server → client data → UI → docs. Each step leaves the project green.

## The loop, per step

1. **Test first where it fits**: a failing test for a bug, a unit test for a rule, a DB test for a policy. For UI, decide what you'll look at.
2. **Write the least code** that passes it, matching the surrounding style, names and comment density. Comments explain why.
3. **Run the step's check, then the related suite.** Never move on while red. Paste failures; don't paper over them.
4. **Stay in scope.** Touch only what the step needs. Note anything else you find, and file it later.

## Layer checklists

**Data** (`09`)
- [ ] A migration, never an edit to a merged one; types regenerated
- [ ] Tenant id; deny-by-default policies; grants (column grants where needed); can/can't tests per role
- [ ] Constraints and size caps in the DB; triggers for cross-row or role rules
- [ ] Soft delete plus purge coverage; files follow rows
- [ ] Realtime: published or not, with a column list if any column is secret
- [ ] Content tables are included in the data export

**Server / API / functions** (`06`, the stack add-on)
- [ ] Validate at the boundary (types, sizes, enums); derive the tenant from the session, never from the client
- [ ] Idempotent creates (a client id or an idempotency key); a stable error code for each failure, mapped on the client
- [ ] Rate limits where abuse is possible; no content in logs or notifications
- [ ] Jobs are idempotent, record their outcome, and can be re-planned

**Client data** (`02`)
- [ ] Query keys scoped by tenant, and by user for "me" queries
- [ ] Writes are idempotent (client UUID) through the project's write path (an outbox if offline matters)
- [ ] One retry layer; errors classified by code; live updates invalidate
- [ ] Entitlement or plan checks before costly creates, with a friendly limit message

**UI** (`04`, `05`)
- [ ] Kit components and tokens only; no hard-coded colours, fonts, curves or strings
- [ ] Loading, error (retry), offline and empty states through the shared gate; never "empty" before data arrives
- [ ] Copy in the catalogue, from the reader's side; names and pronouns from data
- [ ] Labels, roles and hints; targets at the minimum size in `05`; a cue besides colour; works at the largest text size; reduce motion respected
- [ ] Destructive actions confirm with their consequence

## The product check (before calling it built)

Walk the change as each person who meets it:
- **The first-time user**, and the empty account.
- **The other person or tenant member**: what do they see, and when (realtime, push)?
- **The unhappy paths**: offline, the app killed mid-action, slow network, a server error, a limit reached, no permission.
- **Time**: someone in another zone, near midnight, on a leap day.
- **Lifecycle**: delete, leave, sign out, a second device, an old app version talking to the new server.

Anything that behaves in a way the customer wouldn't expect is either fixed now (in scope) or raised as a question or ticket. Never left silent.

## Finish the build

1. **Full check suite** from `AGENTS.md` (lint, typecheck, unit tests, plus DB and integration tests when data changed). All green.
2. **Self-review the whole diff** (`git diff <base>...`):
   - Every line traces to the task, with no debug code and no secrets.
   - Nothing your change left unused remains.
   - No speculative abstraction.
   - **No unnecessary try/catch**: each catch handles the error (retry, user-facing state, context and re-throw, or cleanup); nothing is swallowed, re-thrown unchanged, or logged twice (`${CLAUDE_PLUGIN_ROOT}/principles/01-engineering.md` §7).
   - **No unnecessary comments**: none that restate the code, narrate the change, keep commented-out code, or are TODOs without a ticket (§5).
3. **Note what the release needs**: a new build, an env var, a migration deploy, an owner action.
4. **Note rules to record**: new helpers or conventions for `AGENTS.md`, and decisions for the Decision Log (`docs-upkeep` writes them).
5. **Don't push or open a PR**: that's `ship-pr`, on the owner's word. As a delegated agent in your own worktree (`product-engineer`), commit there on its own branch so the orchestrator can review and bring it in; in the main session, leave committing to `ship-pr`.
6. **Hand off** (`${CLAUDE_PLUGIN_ROOT}/templates/handoff.md`):
   - The changes by file; the checks you ran, with their results.
   - Decisions you took, and questions you hit.
   - What verification should focus on (the riskiest path, the states, the screens to capture).
   - Anything still running.
