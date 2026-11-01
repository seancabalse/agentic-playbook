# Agentic Playbook

An engineering playbook for AI coding agents. It gives Claude Code, Codex, Cursor and GitHub Copilot one shared set of rules, principles, templates, skills and agents, so that agent-driven work follows the same careful process in every project: clarify the requirements, plan with checks, build test-first, verify in the running product, review, and document.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## Contents

- [What's included](#whats-included)
- [Branches](#branches)
- [Requirements](#requirements)
- [Quick start](#quick-start)
- [Installing into a project](#installing-into-a-project)
- [Using it as a Claude Code plugin](#using-it-as-a-claude-code-plugin)
- [Using it with other tools](#using-it-with-other-tools)
- [Customising](#customising)
- [Skills and agents](#skills-and-agents)
- [Worktrees and human review](#worktrees-and-human-review)
- [Keeping up to date](#keeping-up-to-date)
- [Contributing](#contributing)
- [License](#license)

## What's included

| Path | Contents |
| -- | -- |
| `AGENTS.md` | The default project instructions. Sections 1–4 (Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution) are fixed; sections 5–7 (working agreement, non-negotiables, definition of done) are defaults you can adapt; section 8 is filled in per project. |
| `principles/` | 17 principle documents: engineering, architecture, ADRs and decisions, design and UX, accessibility and i18n, security and privacy, dependencies and supply chain, testing and QA, data and migrations, delivery and release, observability, documentation, audits, product and planning, agent collaboration, and Simplified Technical English (ASD-STE100). |
| `templates/` | ADR, decision log, architecture, runbook, PRD, requirements brief, ticket, PR description, handoff, threat model, release checklist, audit report, testing templates, and Claude Code settings (`claude-settings.json`, `worktreeinclude`). |
| `stacks/` | Stack-specific rules appended to a project's `AGENTS.md`. Which stacks exist depends on the branch. |
| `trackers/` | How agents use the issue tracker: Linear, Jira (with Confluence), or GitHub Issues and Projects. |
| `skills/` | 22 skills: repeatable procedures such as `start-task`, `implement`, `verify-feature`, `security-audit` and `ship-pr`. |
| `agents/` | 8 subagents: product owner, product engineer, architect, QA verifier, code reviewer, security auditor, design reviewer and docs keeper. |
| `hooks/` | Claude Code hooks: one tells agents where the playbook and the project's overrides are; one blocks AI attribution and secrets in commits and PRs. |
| `scripts/playbook.sh` | The installer. |
| `USAGE.md` | Worked examples. |

## Branches

`main` is generic. Its default stack is a Node.js and TypeScript backend with a React web frontend. Each other branch is `main` plus the rules, templates and skill sections for one platform or language.

| Branch | Use it for | Stacks (`--stack`) |
| -- | -- | -- |
| `main` | Any project; Node.js + TypeScript backend, React web frontend | `node-service`, `react-web`, `nx-monorepo` |
| `mobile` | iOS and Android apps with Expo / React Native | `main`'s, plus `expo-react-native` |
| `python` | Python services and tools | `main`'s, plus `python`, `python-fastapi`, `python-django` |
| `supabase` | Supabase / Postgres backends | `main`'s, plus `supabase-postgres` |

Each branch has a `BRANCH.md` with its extra prerequisites. To combine branches (for example, a React Native app with a Supabase backend), merge one into the other in your fork: `git checkout mobile && git merge supabase`. Branches add sections at the end of shared files, so a conflict means keeping both sections.

## Requirements

- **git**, **bash** and **rsync** (macOS and Linux; on Windows, use WSL).
- **Claude Code** for the plugin, skills and agents ([install guide](https://docs.claude.com/en/docs/claude-code/overview)). Other agents (Codex, Cursor, GitHub Copilot, Gemini CLI) read the generated `AGENTS.md` and rule files.
- An issue tracker that your agent can reach: Linear or Jira through their MCP servers, or GitHub through the `gh` CLI.
- **Node.js (LTS)** to run the Playwright screenshot templates on `main`. Branches list their own tools in `BRANCH.md`.

## Quick start

```bash
# 1. Get the playbook (or fork it first to keep your own changes).
git clone https://github.com/seancabalse/agentic-playbook.git
cd agentic-playbook
git checkout main            # or: mobile, python, supabase

# 2. See what's available on this branch.
./scripts/playbook.sh list

# 3. Install it into a project.
./scripts/playbook.sh project ~/code/my-app --stack node-service,react-web --tracker github
```

Then open the project in Claude Code and run `/bootstrap-project`. It asks what it can't infer, fills section 8 of `AGENTS.md`, verifies each command it records, writes ADR 0001 for the stack, and creates the living docs in your tracker.

## Installing into a project

`scripts/playbook.sh project <dir>` writes:

| File | Purpose | Commit it? |
| -- | -- | -- |
| `.playbook/` | A copy of this playbook. It also works as a Claude Code plugin. | Yes |
| `AGENTS.md` | Built from `.playbook/AGENTS.md`, then the chosen stacks and the tracker section. | Yes |
| `CLAUDE.md` | `@AGENTS.md`, so Claude Code loads the same rules. | Yes |
| `.claude/settings.json` | Turns on the playbook plugin from `./.playbook` and starts agent worktrees from your current branch (`--tools plugin`, the default). | Yes |
| `.claude/skills/`, `.claude/agents/` | Copies of the skills and agents, only with `--tools claude` (no plugin). | Yes |
| `.cursor/rules/` | The skills as Cursor rules. | Yes |
| `.github/copilot-instructions.md`, `.github/prompts/` | Copilot instructions and prompt files. | Yes |

Options:

| Option | Default | Effect |
| -- | -- | -- |
| `--stack a,b` | none | Stack sections to append to `AGENTS.md` (see `./scripts/playbook.sh list`). |
| `--tracker linear\|jira\|github` | none | The tracker section to append. For another tracker, copy `trackers/github.md` and fill in the same headings. |
| `--tools plugin\|claude,agents,cursor,copilot` | `plugin,agents,cursor,copilot` | Which files to write. Choose `plugin` (Claude Code loads the skills from `.playbook/`) or `claude` (copies in `.claude/`), never both: both would load every skill twice. |
| `--force` | off | Replace files that exist. `.playbook/local/` is never replaced. |

The installer never overwrites a file without `--force`. If the project already has an `AGENTS.md`, it writes `AGENTS.playbook.md` for you to merge; your project's rules win. With the plugin, each person runs `claude plugin marketplace add ./.playbook` once per machine from the repository root, then starts a new session.

Other targets:

```bash
./scripts/playbook.sh user       # skills and agents for every project on this machine (~/.claude)
./scripts/playbook.sh prompts    # plain prompt files for any chat assistant (dist/prompts/)
```

## Using it as a Claude Code plugin

The repository is a Claude Code plugin and its own marketplace. Skills appear as `/playbook:<name>`; agents and the session hook load automatically.

```text
/plugin marketplace add seancabalse/agentic-playbook
/plugin install playbook@agentic-playbook
```

- **A branch**: `/plugin marketplace add seancabalse/agentic-playbook#python` (or `#mobile`, `#supabase`).
- **Your fork**: use `<you>/agentic-playbook`.
- **A project's committed copy**: from the project root, run `claude plugin marketplace add ./.playbook` once per machine, and commit `.claude/settings.json` with the plugin enabled (see `templates/claude-settings.json`).
- **Updates**: `claude plugin update playbook@agentic-playbook`. Publishers bump `version` in `.claude-plugin/plugin.json`.

Validate a change with `claude plugin validate .`, and try it without installing with `claude --plugin-dir .`.

## Using it with other tools

| Tool | Always-on rules | Procedures |
| -- | -- | -- |
| Claude Code | `CLAUDE.md` → `AGENTS.md` | Skills (`/name`, or `/playbook:name` from the plugin) and subagents |
| Cursor | `AGENTS.md` | `.cursor/rules/<skill>.mdc`, applied when relevant or with `@name` |
| GitHub Copilot | `.github/copilot-instructions.md` | Prompt files: `/name` in Copilot Chat |
| Codex, Gemini CLI, others | `AGENTS.md` | "Read `.claude/skills/<name>/SKILL.md` and follow it." |
| Any chat assistant | Paste `AGENTS.md` | `dist/prompts/<skill>.md` after `./scripts/playbook.sh prompts` |

## Customising

The playbook stays general. A project adapts it in three places:

| Change | Where |
| -- | -- |
| Rules for this project only | `AGENTS.md`, section 8 "This project". |
| A playbook default for this project (a template, principle, stack or tracker file) | `.playbook/local/<same path>`. This copy wins everywhere. Run `/customize` (`/playbook:customize`) to make it, or copy the file by hand. |
| The defaults for every project you start | Your fork of this repository. |

Sections 1–4 of `AGENTS.md` stay the same in every project. Sections 5–7 are defaults: change them in the project's `AGENTS.md` when the project needs something different.

## Skills and agents

**Skills that start only when you type them**, because they commit, open PRs, change the project's playbook or run a long pipeline: `ship-pr`, `deliver-feature`, `bootstrap-project`, `customize`.

**Skills that agents load by themselves** when the task matches (you can also type them):

| Skill | Purpose |
| -- | -- |
| `refine-requirements` | Clarify a vague request with the owner, round by round, and write a requirements brief in ASD-STE100. |
| `start-task` | Gather context, state assumptions, ask product questions, and plan with a check per step. |
| `implement` | Build in small, test-first steps with per-layer checklists and a customer-journey check. |
| `fix-bug` | Reproduce, write a failing test, find the root cause, fix, and record the lesson. |
| `reproduce-in-worktree` | Reproduce a bug or review finding in an isolated git worktree and try the fix there before a person is involved. |
| `verify-feature` | Walk the acceptance criteria in the running product, including error and edge states. |
| `capture-screenshots` | Capture states × sizes × settings as evidence for a PR. |
| `handoff` | Write or resume a handoff between agents, sessions or people. |
| `docs-upkeep` | Keep `AGENTS.md`, the decision log, the architecture doc and the runbook current. |
| `write-adr`, `log-decision` | Record hard-to-reverse choices and everyday decisions. |
| `architecture-review`, `design-review`, `a11y-audit` | Structural, UX and accessibility reviews. |
| `security-audit`, `threat-model` | Security reviews and threat models with proven findings. |
| `vet-dependency` | Vet a package before adding it: advisories, adoption, release age, licence. |
| `release-readiness` | The audit before a production release. |

**Agents**, which Claude Code delegates to when the task matches, or when you ask:

| Agent | Role |
| -- | -- |
| `product-owner` | Product owner, project owner and project manager: clarifies requirements and scope, in ASD-STE100. |
| `product-engineer` | The only agent that writes code: builds the plan and applies review fixes, in its own worktree. |
| `architect` | Designs features and drafts ADRs. |
| `qa-verifier` | Runs the product, walks the acceptance criteria and captures screenshots. |
| `code-reviewer`, `security-auditor`, `design-reviewer` | Independent, read-only reviews. |
| `docs-keeper` | Keeps the repository and tracker documentation in step, in its own worktree. |

`/deliver-feature <ticket>` runs the whole pipeline: requirements, plan, build, verification, parallel reviews, fixes and docs. It stops before shipping, so a person decides when to open the PR (`/ship-pr`). See `principles/15-agent-collaboration.md`.

## Worktrees and human review

Agents never experiment in your working checkout.

- **Agents that change files** (`product-engineer`, `docs-keeper`) run in their own git worktree (`isolation: worktree`) and commit there on their own branch. The orchestrating session reviews the diff and runs the checks in that worktree before it brings the work into the feature branch.
- **Bugs and review findings are tried before a person is asked.** An agent reproduces the problem in a worktree, with a failing test or a script, tries the smallest fix and runs the full checks there (`reproduce-in-worktree`). A person (human in the loop) gets the reproduction, what was tried and the result, not a guess. Reviewers stay read-only in the shared checkout and prove findings in their own throwaway worktree.

Set up a project for this (`/bootstrap-project` does it):

| File | Setting | Why |
| -- | -- | -- |
| `.claude/settings.json` | `"worktree": { "baseRef": "head" }` | Claude Code branches agent worktrees from the default branch unless this is set. With it, they start from the branch you're on. |
| `.worktreeinclude` | Copy `templates/worktreeinclude` | Gitignored files a worktree needs to run the app and tests, such as `.env`. Never list secrets a worktree doesn't need. |
| `.gitignore` | `.claude/worktrees/` | Claude Code keeps its worktrees there. |

## Guardrails

The plugin's hooks enforce two rules from the working agreement, so they don't depend on an agent remembering them:

| Hook | Blocks | Turn off or adjust |
| -- | -- | -- |
| AI attribution | `Co-Authored-By: Claude…`, "Generated with Claude…" in `git commit` and `gh pr create/edit` | Create `.playbook/local/allow-ai-attribution` |
| Secrets in commits | Staged `.env` and key files, private keys, and AWS, GitHub, Slack, Stripe, Anthropic, OpenAI and Supabase secret tokens | List allowed paths in `.playbook/local/secret-scan-allow` |

A blocked command shows the file, the line and the kind of secret, never its value. The hooks cost no context tokens.

## Keeping up to date

- **Your fork**: `git remote add upstream https://github.com/seancabalse/agentic-playbook.git`, then `git pull upstream main` (or the branch you use).
- **A project**: run the installer again with `--force` and review the diff. `.playbook/local/` is kept.
- **The plugin**: `claude plugin update playbook@agentic-playbook`.

## Contributing

Issues and pull requests are welcome.

- Generic changes go to `main`. Platform or language changes go to their branch. `main` is merged into each branch regularly.
- Keep rules short, concrete and testable. Every rule should say what to do, not only what to avoid.
- Before you open a PR, run `bash -n scripts/playbook.sh` and `claude plugin validate .`, and try an install with `./scripts/playbook.sh project <temp dir>`.
- Bump `version` in `.claude-plugin/plugin.json` when skills, agents or hooks change.

## License

[MIT](LICENSE) © 2026 Sean Cabalse
