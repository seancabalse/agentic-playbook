# Working in this repository

<!-- The playbook's default AGENTS.md. Sections 1–7 are the rules for every project: keep 1–4 as they are, and adapt 5–7 if the project needs to. Section 8 is this project's own rules. The installer appends the chosen stack and tracker sections after it. Projects own their copy: edit it freely. -->

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.
- Do not factor in development cost.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## 5. Working agreement

<!-- Defaults: edit them for the project. Details: ${CLAUDE_PLUGIN_ROOT}/principles/00-working-agreement.md. -->

- The owner decides product and merges every PR. Never merge or push to the default branch; branch first. Keep CI green.
- Ask product questions the ticket doesn't settle: 2–4 options, recommended first. Choose sensible defaults for the rest and say so.
- No AI attribution in commits, PRs, comments or docs (no `Co-Authored-By`, no "Generated with").
- Secrets: never print, paste, log or commit them, and never read the keychain; the owner sets them (give the exact command). Only publishable keys reach a client.
- Vet each new dependency first (`vet-dependency`); install with the ecosystem's version-aware installer.
- Reproduce bugs and review findings in a git worktree and try the fix there before you involve a person; agents that change files work in their own worktree (`reproduce-in-worktree`).
- Confirm before anything hard to undo or outward-facing. Report results faithfully, including failures and what you didn't verify.
- Read the docs for the installed version of a fast-moving API; don't trust memory.
- Stop the processes you started; leave alone what you didn't start. No tight polling. Ask yourself: am I cutting corners, or drifting from what the customer needs?

## 6. Non-negotiables

- **Data**: migrations only, never edit a merged one; each new table gets a tenant id, deny-by-default access, grants and access tests; soft delete and purge; regenerate types.
- **Code**: catch an error only where you handle it (never swallow, re-throw unchanged or log twice); comments say why, never what (principle 01 §5, §7).
- **Writes** are idempotent; retries live in one layer; classify errors by code, never by message.
- **Time**: UTC instants plus an IANA zone; calendar dates as dates; no hand-rolled zone maths.
- **UI**: design tokens and the component kit; loading, error, offline and empty states; never show "empty" before data arrives.
- **Copy**: in the message catalogue (ICU), from the reader's side; never infer pronouns from a name.
- **Accessibility**: WCAG 2.2 AA (largest text size, 24 px minimum targets, labels, a cue besides colour, reduced motion).
- **Privacy**: collect the minimum; no private content in logs, analytics, crash reports or notifications.

## 7. Definition of done

The full check suite passes; you saw the change work in the real product, with evidence; the docs are updated in the same PR; the PR follows the template and the ticket has the verification.

`${CLAUDE_PLUGIN_ROOT}` is the playbook folder (`.playbook/` in a repo, or the plugin's folder). Principles: `${CLAUDE_PLUGIN_ROOT}/principles/`; templates: `${CLAUDE_PLUGIN_ROOT}/templates/`. A project's copy at `.playbook/local/<same path>` wins over the playbook file, and this file wins over both.

## 8. This project

<!-- Fill these in during bootstrap; delete the hints. Keep each rule one bullet, with the path to the code that implements it. -->

- **What it is**: <one sentence: who it's for and what it does>. PRD: <link>.
- **Tracker**: <Linear / Jira / GitHub Issues / …>, project <name or link>. Access, ids, status mapping and where the docs live are in the "Tracker" section below (installed with `--tracker`; for another tracker, copy one from `.playbook/trackers/`). Living docs: Decision Log <link>, Architecture <link>, Runbook <link>, PRD <link>.
- **Stack** (see `docs/adr/0001-stack.md`): <framework + exact major version>, <backend>, <database>, <hosting>. Docs to check before using an API: <versioned docs URLs>.
- **Tenant unit**: <workspace / account / space>. Every content row has `<tenant>_id`.

### Commands

| Task | Command |
| -- | -- |
| Install | `<npm ci / pnpm i / …>` |
| Run locally | `<…>` |
| Lint | `<…>` |
| Typecheck | `<…>` |
| Unit tests | `<…>` |
| DB / integration tests | `<…>` |
| Generate types | `<…>` |
| Add a dependency | `<npm i / pnpm add / nx add / …> <pkg>` |

Before calling a task done: <list the commands above that must pass>.

### Layout

- `<src/app/>`: <routes / entry points>
- `<src/components/>`: the UI kit (preview at `<…>`)
- `<src/data/>`: the one client per service, queries, outbox
- `<db/migrations/>`, `<db/tests/>`
- `docs/adr/`: ADRs

### Environments

| Env | Where | Deployed by |
| -- | -- | -- |
| local | <…> | developer |
| dev | <…> | pipeline on merge |
| prod | <…> | manual pipeline run |

### Domain rules

<!-- One numbered subsection per feature area as it's built, e.g. "### 9. Auth", "### 10. Billing". Each bullet: the rule, then the code path. -->
