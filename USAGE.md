# Using the playbook: worked examples

Every example shows what you type and what should happen. Commands assume a clone of the playbook at `~/code/agentic-playbook`. A project that keeps a copy for Cursor or Copilot has the same files in `.playbook/`.

---

## 0. Add the plugin (once per machine)

From a local clone (recommended; `git pull` updates it):

```bash
git clone https://github.com/seancabalse/agentic-playbook.git ~/code/agentic-playbook
cd ~/code/agentic-playbook && git checkout all
claude plugin marketplace add "$PWD"
claude plugin install playbook@agentic-playbook --scope user
```

Or straight from GitHub: `/plugin marketplace add seancabalse/agentic-playbook#all`, then `/plugin install playbook@agentic-playbook`.

- Skills are `/playbook:<name>` (e.g. `/playbook:start-task ACME-42`). Agents and the session hook work by themselves.
- Check what it adds: `claude plugin details playbook@agentic-playbook` shows 23 skills, 8 agents and 2 hooks, at about 1.1k tokens per session for the skill and agent descriptions.
- Update: `git pull` in the clone (or `claude plugin update playbook@agentic-playbook` for a GitHub install), then start a new session.
- **For a team repo**: commit `.claude/settings.json` from the playbook's `templates/claude-settings.json`. Everyone who trusts the repo is offered the plugin.

The examples below work the same with the plugin (`/playbook:…`) or with a copied install (`/…`).

---

## 1. A new Nx + TypeScript project (React web + Node API)

```bash
npx create-nx-workspace@latest acme --preset=ts
cd acme
~/code/agentic-playbook/scripts/playbook.sh project . --stack nx-monorepo,react-web,node-service --tracker jira
```

You get `AGENTS.md` (core rules, an empty project section, three stack add-ons, the Jira tracker section), `CLAUDE.md` (`@AGENTS.md`) and `.claude/settings.json` (worktrees start from your branch). Claude Code reads the skills, agents, principles and templates from the plugin. Add `--tools plugin,agents,cursor,copilot` if the team also uses Cursor or Copilot: then you also get their files and a `.playbook/` copy for them.

Then, in Claude Code:

```
/playbook:bootstrap-project nx-monorepo,react-web,node-service
```

What it should do:
1. Ask, in one batch: what Acme is and for whom, the Jira project and how agents reach it (Atlassian MCP or `acli`), its status names, the tenant unit ("organisation"), hosting, and compliance needs.
2. Fill "## 8. This project" in `AGENTS.md`, running each command it lists (`nx affected -t lint test build typecheck`, …) to prove it.
3. Write `docs/adr/0001-stack.md` with the options it considered.
4. Create the Decision Log, Architecture, Runbook and PRD as Confluence pages (or `docs/` if there's no Confluence), link them, and record Jira's status mapping in the Tracker section.
5. Set up CI with pinned tool versions, and list the secrets you need to set (with `gh secret set` commands for you to run).
6. File owner tickets (domain, accounts) and report what's verified.

---

## 2. Adopting it in an existing repo

```bash
~/code/agentic-playbook/scripts/playbook.sh project ~/code/shop --stack react-web,node-service --tracker linear
#   AGENTS.md exists: merge AGENTS.playbook.md into it (project rules win)
```

```
Merge AGENTS.playbook.md into AGENTS.md. Keep every existing project rule; add the playbook core sections that are missing; list any conflicts for me instead of choosing. Then delete AGENTS.playbook.md.
```

If you added Cursor or Copilot, decide whether `.playbook/` is shared (commit it) or personal (add it to `.git/info/exclude`). Never register it as a Claude Code plugin: that would replace the plugin for every project on your machine.

---

## 3. The daily loop

```
/start-task ACME-42
```
Claude reads the ticket, `AGENTS.md`, related decisions and the code, then replies with assumptions, any product questions (options, recommendation first) and a plan:

```
1. Add invoices.status + policy → verify: DB tests (can/can't per role)
2. API: PATCH /invoices/:id (zod schema, idempotent) → verify: unit + integration
3. UI: status chip + loading/error/offline/empty → verify: component tests
4. Verify in the browser → verify: criteria walked, screenshots at 200% zoom
```

…it builds step by step with `implement` (or you say "use the product-engineer agent for step 2"), then:

```
/verify-feature ACME-42
```
→ a pass / fail / not verified table with screenshots, then the dev server and database are stopped.

```
Use the code-reviewer agent on this branch's diff against main.
```
→ only findings with a concrete failure scenario, ranked.

```
/ship-pr ACME-42
```
→ checks run; docs updated (`docs-upkeep`); a commit with no AI attribution; the PR from the template with real results and screenshots; the ticket moved to the tracker's review status with a handoff comment. You review and merge.

---

## 4. A hard decision

```
/write-adr How should we send background jobs: Postgres-backed queue, BullMQ on Redis, or a hosted queue?
```
Claude reads the existing ADRs and the PRD, checks each option's current docs, and asks you the business trade-off (cost vs ops). Then it writes `docs/adr/0004-…md` as Proposed, logs a pointer in the Decision Log, adds the implied rules to `AGENTS.md`, and files the "now we must" tickets. If numbers are missing ("can Postgres handle our volume?"), it proposes a time-boxed spike instead of guessing.

Smaller choices:

```
/log-decision Owner decision: free plan keeps 30 days of history; paid keeps everything.
```

---

## 5. A risky feature: sharing and files

```
/threat-model ACME-77 public share links for invoices
```
→ assets, attackers, entry points, a STRIDE table, and mitigation tickets that each name the test proving them.

```
Use the security-auditor agent to audit the ACME-77 branch.
```
→ findings with exploit scenarios, proven by a failing access test or an exact request. Secrets it finds are reported by location, never printed.

---

## 6. Before a release

```
/release-readiness 1.2.0
```
Claude copies the checklist into a dated doc and works through it: CI, `verify-feature offline`, `verify-feature layout`, `a11y-audit app`, `security-audit project`, the dependency audit, migrations, backups, release notes and the rollback plan. Every line gets evidence or a ticket. You get **Ready / Not ready** and the list of owner tasks.

---

## 7. Fixing a bug

```
/fix-bug At 200% zoom the Pay button on the checkout page is hidden under the footer (ACME-128)
```
→ a reproduction, then the verified root cause, then a failing test (or manual repro steps when the platform can't be automated), then a minimal fix verified in the app. A runbook trap row and an `AGENTS.md` rule are added if a rule was missing.

---

## 8. The whole pipeline, with agent handoffs

```
/deliver-feature ACME-42
```

1. **start-task** posts the plan on the ticket. If there are product questions it asks you and **stops** until you answer.
2. For structural work the **architect** agent returns a design handoff. If an ADR is needed, Claude drafts it and **stops** for you to accept it.
3. The **product-engineer** agent builds it, following `implement`: test first, the layer checklists, the customer-journey check. It returns a handoff listing its changes and the checks it ran. If a customer-visible behaviour isn't settled it stops with a question instead of guessing. Claude, as tech lead, reads the whole diff and re-runs the checks itself.
4. The **qa-verifier** agent runs the app, walks the criteria, captures screenshots, and returns a handoff with evidence paths. Claude opens one screenshot to confirm it before moving on.
5. **code-reviewer**, plus **security-auditor** (for auth, data or files) and **design-reviewer** (for UI), run in parallel and read-only, each returning ranked findings.
6. The product engineer fixes the confirmed findings, Claude re-checks the diff, and qa-verifier re-checks what changed (at most 2 loops).
7. The **docs-keeper** agent updates `AGENTS.md`, the Decision Log, Architecture and the Runbook wherever the Tracker section says they live.
8. Claude posts a summary handoff on the ticket and **stops**. You run `/ship-pr`, review, and merge.

A handoff looks like this (shape in `templates/handoff.md`):

```
## Handoff: qa-verifier → orchestrator · ACME-42 · 2026-10-27 06:05 UTC
Goal: invoices show a status chip; loading/error/offline/empty states
State: partial
Evidence: `npx playwright test e2e/invoices.spec.ts` → 6 passed;
  screenshots/ACME-42/invoices-error-mobile.png (Try again visible)
Findings: 1. Medium · chip text clipped at 200% zoom · invoices-default-desktop-zoom.png · Confirmed
Next: orchestrator fixes the clip (wrap the chip row), then qa-verifier re-checks the zoom shot
Don't: re-seed the DB; the fixtures are already loaded
Still running: nothing
```

## 9. Stopping halfway, or switching tools

```
/handoff write ACME-42
```
→ the branch is pushed if you want it to be, a handoff comment lands on the ticket, and running processes are stopped or listed.

Next day, in a new session (or in Codex or Cursor with "follow the handoff skill"):

```
/handoff resume ACME-42
```
→ Claude reads the latest handoff and the branch, **re-runs the key checks**, says if anything no longer holds, and carries on with "Next".

## 10. Screenshots for a PR

**Web (Playwright):**

```bash
cp .playbook/templates/testing/playwright.config.ts .
mkdir -p e2e && cp .playbook/templates/testing/screenshots.spec.ts e2e/
# edit the shots list: routes + how to put each in its state (page.route mocks)
TICKET=ACME-42 npx playwright test screenshots.spec.ts
```
→ `screenshots/ACME-42/<screen>-<state>-<mobile|desktop|desktop-dark>.png`

Or just say "capture screenshots for ACME-42: settings default, error, and at 200% zoom": `capture-screenshots` picks the driver from the stack. Other platforms add their own drivers through their stack file.

Claude looks at every image (a blank one usually means the page hadn't finished loading). `/ship-pr` then publishes them:

```bash
.playbook/templates/testing/push-screenshots.sh 57 screenshots/ACME-42/*.png
```
→ the images go to the `screenshots` branch, and the script prints the `![…](…?raw=true)` lines for the PR.

## 11. Outside Claude Code

- **Cursor**: it reads `AGENTS.md` itself. Skills are agent-requested rules: say "follow the ship-pr rule", or type `@ship-pr` to attach it.
- **GitHub Copilot (VS Code)**: `.github/copilot-instructions.md` applies to chat; run a skill as a prompt file with `/start-task` in Copilot Chat (it asks for `task`).
- **Codex, Gemini CLI and other agents** read `AGENTS.md`. Point them at a skill: "Read `.claude/skills/security-audit/SKILL.md` and follow it for this branch."
- **ChatGPT, Claude.ai and other chats**: build the prompts (`playbook.sh prompts`), paste `dist/prompts/write-adr.md`, replace `[your task]`, and attach `AGENTS.md` and the principle files it names. Role prompts are in `dist/prompts/agents/`.

---

## 12. Making it yours

**For one project** (the playbook stays general; the project's copy wins):

```
/playbook:customize templates/pr-description.md add a "Rollout" section with the feature flag and the rollback step
```

It copies the default to `.playbook/local/templates/pr-description.md`, makes the change, notes why at the top, checks which skills read it (`ship-pr`), and logs the decision. From the next session, `ship-pr` uses your template; the session hook lists the override. Delete the file to go back to the default.

Other examples:
- `/playbook:customize stacks/node-service.md we log with winston, not pino`
- `/playbook:customize principles/10-delivery-ci-release.md releases need two approvals`
- A rule only this project has (no playbook file involved): add it to `AGENTS.md` → "This project" instead.

**For yourself, everywhere:**

- **The working agreement** (no attribution, secrets, processes…) lives in `principles/00-working-agreement.md` and section 5 of `AGENTS.md`; sections 1–4 (Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution) stay as they are. Change them in the playbook repo, bump the plugin version and push. Copied installs need a reinstall with `--force`.
- **Without the plugin, on this machine**: `playbook.sh user`, then add `@~/.claude/playbook/principles/00-working-agreement.md` to `~/.claude/CLAUDE.md` so every Claude Code session follows it.
- **A stack you use a lot** (Go, Flutter, Rails, …): copy a `stacks/*.md` file (`node-service.md` is a good model), write operational bullets (commands, traps, conventions), add starter files under `templates/<stack>/` if useful, and pass it with `--stack`.
- **Another tracker** (Azure Boards, Shortcut, Notion, …): copy `trackers/github.md`, fill in access, ids and linking, the status mapping, where the docs live and the editing notes, and pass it with `--tracker`.

---

## 13. A vague request: the product owner

You have an idea, not a ticket:

```
/playbook:refine-requirements Customers should be able to share an invoice with their accountant.
```

What it should do, in ASD-STE100 (Simplified Technical English):

1. **Read first**: the PRD, the Decision Log, the invoice code, and the current export feature. It does not ask what these answer.
2. **Bring the domain knowledge**: for example, a sent invoice keeps its number and amounts; an accountant needs to read many invoices but not change them; a shared link must expire.
3. **Ask, round by round**, with the recommended option first:

   > **Question 1.** Who can open a shared invoice?
   > - **Only a person who signs in with the invited email address (recommended).** The invoice contains billing data. The workspace knows who opened it.
   > - Any person with the link. This is faster, but a forwarded link shows the invoice to other people.
   >
   > **Question 2.** How long does a link stay valid? …

4. **Write the brief** from `templates/requirements-brief.md`: goal, users, domain facts and assumptions, scope in and out, requirements R1…, acceptance criteria A1… ("When the link has expired, the app does not show the invoice."), quality, risks, decisions, open questions.
5. **Agree and record**: you agree, it posts the brief on the ticket and logs the decisions. Then `start-task` plans the build.

In `/deliver-feature`, the **product-owner** agent does the same work. A subagent cannot ask you questions directly. So it returns the questions to the main session, which asks you and runs it again with your answers, until the brief is ready.

---

## 14. A frontend and a backend: a workspace

The `shop` project has `shop-web` (Nx, React) and `shop-api` (Nx, Node), and a `refs/` folder of API specs. Put them in one folder and set it up as a workspace:

```bash
mkdir -p ~/code/shop/refs && cd ~/code/shop          # put the API specs in refs/
git clone <shop-web url> && git clone <shop-api url>
~/code/agentic-playbook/scripts/playbook.sh workspace .
#   Is ~/code/shop the workspace (main) repository, where the lead session runs? (y/n) [y]:
#   It isn't a git repository yet. Run git init? (y/n) [y]:
#   Tracker (linear, jira, github or none)? [none]: jira
#   Is refs/ reference material that agents read but never change? (y/n) [y]:
#   Is shop-api/ (a git repository) part of the project? (y/n) [y]:
#     Its role (frontend, backend or other)? [backend]:
#     How many agent sessions will work in it? [1]: 2
#     Its stacks, comma-separated (see: playbook.sh list)? [nx-monorepo,node-service]:
#     shop-api/ has no AGENTS.md. Set it up with the playbook now? (y/n) [y]:
#   Is shop-web/ (a git repository) part of the project? (y/n) [y]:
#   …
```

The folders come in alphabetical order. To pipe the answers in instead, give them in this order.

Fill in section 8 of `~/code/shop/AGENTS.md`, run `/playbook:bootstrap-project` in `shop-web/` and `shop-api/`, then start the sessions from the "Sessions" table, each in its own terminal:

```bash
claude -n lead                                   # in ~/code/shop
cd shop-api && claude -n shop-api-1
cd shop-api && claude -n shop-api-2 -w shop-api-2
cd shop-web && claude -n shop-web-1
```

In the lead session:

```
/playbook:lead SHOP-31 Customers can save a cart and come back to it
```

What it should do:
1. Read the workspace records and check which sessions are running (and give you the start command for any that isn't).
2. Plan the work across the repositories, and ask you the product questions.
3. Write the contract first (`POST /carts/{id}/save`: the payload, the errors, and which side owns it) in `docs/workspace/DECISIONS.md`.
4. Send `shop-api-1` the endpoint, and `shop-web-1` the screen against a stub of the contract, each as one self-contained message.
5. When a handoff arrives, log it in `docs/workspace/HANDOFFS.md`, re-run its key check in a throwaway worktree, update `STATUS.md`, and route the next step (for example, "the endpoint is on `SHOP-31-save-cart`; switch the screen from the stub").
6. Run the end-to-end check with both branches, record the result in `STATUS.md`, post a summary on the ticket, and stop for you to review and merge each PR.

The members follow the playbook as usual in their repositories. Their session-start message tells them the lead's name, and `handoff write` sends their handoff to the lead as well as posting it on the ticket.
