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

<!-- Opinionated defaults. Edit them to suit the project; the full version is principles/00-working-agreement.md. -->

- The owner decides product and merges every PR. Never merge, never push to the default branch; branch first. Keep CI green.
- Ask product questions the PRD or ticket doesn't settle: 2–4 options, the recommended one first, with trade-offs. Pick sensible defaults for the rest and say so.
- **No AI attribution** by default: no `Co-Authored-By`, no "Generated with", no self-mention in commits, PRs, comments or docs.
- **Secrets**: never print, paste, log or commit them. The owner sets them (give the exact command). Only publishable keys reach a client. Never read the keychain.
- Vet every new dependency first (vulnerabilities, adoption, maintenance, licence). Free tiers are fine while testing.
- Stop processes you started (dev servers, local stacks, browsers, watchers) once they're not needed. Leave alone what you didn't start. No tight polling.
- **Reproduce in a worktree before involving a person.** For a bug, an investigation or a review finding, reproduce it in a separate git worktree (never in the working checkout), try the fix there and run the checks, then bring the fix back or hand off with the reproduction, what you tried and the result. Agents that change files work in their own worktree. See `${CLAUDE_PLUGIN_ROOT}/skills/reproduce-in-worktree/SKILL.md`.
- Confirm before anything hard to undo or outward-facing. Report results faithfully, including failures and what wasn't verified.
- Check yourself: am I cutting corners or drifting from what the customer needs?
- Don't trust memory for fast-moving APIs: read the docs for the installed version first, and install with the ecosystem's version-aware installer.

## 6. Non-negotiables

- **Data**: schema changes are migrations only; never edit a merged migration. New tables need a tenant id, deny-by-default access policies, grants and access tests in the same PR. Soft delete and purge. Generated types are regenerated and committed.
- **Code**: no unnecessary try/catch (catch only where you handle the error; never swallow it, re-throw it unchanged or log it twice) and no unnecessary comments (comments say why; no restating the code, narrating the change, commented-out code or TODOs without a ticket). See `${CLAUDE_PLUGIN_ROOT}/principles/01-engineering.md` §5 and §7.
- **Writes** are idempotent (client UUIDs, upsert-ignore-duplicates). Retries live in one layer. Errors are classified by code, never by message text.
- **Time**: store UTC instants plus an IANA zone; calendar dates as dates. Never hand-roll zone maths.
- **UI**: design tokens only; build from the component kit; every screen has loading, error, offline and empty states, and never shows "empty" before data arrives.
- **Copy** lives in the message catalogue (ICU), written from the reader's side. Never infer pronouns from a name (they/them by default).
- **Accessibility**: WCAG 2.2 AA. Text works at the largest text size (200% zoom and 400% reflow on the web), targets of at least 24 × 24 px (44 recommended), labels, a cue besides colour, reduce motion respected.
- **Privacy**: collect the minimum. Private content never goes to logs, analytics, crash reports or notifications.

## 7. Definition of done

1. The project's full check suite passes locally (see "Commands" below).
2. The change was seen working in the real app or service, with evidence (screenshots for UI).
3. The docs are updated in the same PR: this file, the Decision Log, the Architecture doc, the runbook traps.
4. The PR follows the template, and the ticket has a closing comment with the verification.

**Playbook files.** `${CLAUDE_PLUGIN_ROOT}` means the playbook folder: `.playbook/` in a repo, or the plugin's folder when the playbook is installed as a Claude Code plugin. Full principles: `${CLAUDE_PLUGIN_ROOT}/principles/` (working agreement, engineering, architecture, ADRs, design, accessibility and i18n, security, dependencies, testing, data, delivery, performance, docs, audits, product, agent collaboration, Simplified Technical English). Templates: `${CLAUDE_PLUGIN_ROOT}/templates/`.

**This project's changes to the playbook win.** Before using any playbook file (a principle, template, stack or tracker file), check `.playbook/local/` for the same path, e.g. `.playbook/local/templates/adr.md` for `templates/adr.md`, and use that copy when it exists. Rules in this file win over both.

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
