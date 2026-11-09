---
name: bootstrap-project
description: "Set up the playbook in a new or existing repository: AGENTS.md, ADR 0001, the living docs, CI and owner tasks. Run only when the user asks."
argument-hint: "[stack overlays, e.g. nx-monorepo,react-web,node-service]"
disable-model-invocation: true
---

# Bootstrap a project

Stacks: $ARGUMENTS

## 1. Understand the project

- Read the repo (README, package manifests, existing docs, CI) or, for a new project, the brief or PRD. Infer the stacks from the manifests ("Stack inference" at the end of this file), and list the stack files that exist: `${CLAUDE_PLUGIN_ROOT}/stacks/`.
- Ask the owner, in one batch, only what you can't infer: what it is and for whom, the tracker (Linear, Jira, GitHub Issues, or another one) and how agents reach it (MCP server, CLI), the tenant unit, the target platforms, hosting preferences, and any compliance needs.

## 2. Install the playbook files

You're running from the installed plugin, so the project needs **no copy of the playbook** for Claude Code.

1. Run the installer from the plugin: `"${CLAUDE_PLUGIN_ROOT}/scripts/playbook.sh" project <repo> --stack <stacks> --tracker <linear|jira|github>`. The default `--tools plugin,agents` builds `AGENTS.md` from the playbook plus the stacks and the tracker section, writes `CLAUDE.md`, and sets `worktree.baseRef` in `.claude/settings.json`.
2. Add `cursor` or `copilot` to `--tools` only if the team uses those tools. They read files in the repo, so the installer then also copies the playbook into `.playbook/` (committed, and never a plugin source).
3. **Never** register a project's `.playbook/` as a plugin (`claude plugin marketplace add ./.playbook`, or `extraKnownMarketplaces` pointing at it). Plugin sources are per machine: it would replace the machine-wide install for every project. If the repo has one from an older install, the installer warns: remove it, and the copy too unless Cursor or Copilot needs it.

Project changes to a playbook file go in `.playbook/local/<same path>` (the `customize` skill). For a tracker with no file in `trackers/`, write the "Tracker" section by hand from the GitHub one, covering access, ids and linking, the status mapping, where the docs live, and the editing notes.

## 3. Fill `AGENTS.md`

- Keep sections 1–4 (Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution) as they are. Adapt sections 5–7 only where the project needs to, and tell the owner what changed.
- Fill section 8, "This project":
  - What it is, and the tracker with doc links.
  - Stack and docs URLs for the installed versions.
  - Commands, verified by running each one.
  - Layout, environments, and the tenant unit.
- Keep the chosen stack overlays; delete the lines that don't apply, and add project-specific traps.
- If an `AGENTS.md` already existed, merge into it: the project's rules win over the playbook defaults; note conflicts for the owner.
- `CLAUDE.md` contains `@AGENTS.md`.

## 4. Decisions and docs

- **ADR 0001: stack** (`write-adr`), with the options considered. More ADRs for the other hard choices already made (auth, data, hosting).
- **Tracker docs**, from `${CLAUDE_PLUGIN_ROOT}/templates/`:
  - Decision Log (seeded with the bootstrap decisions).
  - Architecture & Data Model.
  - Developer Runbook.
  - PRD (from the brief, with open questions listed).
- Link them from `AGENTS.md`.

## 5. Safety rails

- Worktrees: `.gitignore` has `.claude/worktrees/`; `.claude/settings.json` sets `"worktree": { "baseRef": "head" }` so agents' worktrees start from the current branch; `.worktreeinclude` (from `${CLAUDE_PLUGIN_ROOT}/templates/worktreeinclude`) lists the gitignored files a worktree needs to run the app and tests.
- `.gitignore` covers env files, generated folders, build output, local design files and keys.
- CI runs lint, typecheck, unit tests and the dependency audit (plus DB and integration tests if there's a backend), with pinned tool versions.
- Secrets plan: the names needed per environment, and the owner sets each value (give the exact commands; never handle the values).
- Branch protection on the default branch (owner task if you lack permission).
- Squash merging only, with merged branches deleted (`principles/10-delivery-ci-release.md` #3; owner task if you lack permission): `gh repo edit --enable-squash-merge --enable-merge-commit=false --enable-rebase-merge=false --squash-merge-commit-message pr-title-description --delete-branch-on-merge`.

## 6. Owner tasks

File tickets with step-by-step instructions for accounts, billing, DNS and credentials, labelled as owner tasks.

## 7. Report

What's set up, what's verified (the commands ran green), the open questions, and the owner tasks.

## Stack inference

Suggest these stacks from what the repo contains, then confirm them with the owner:

- `nx.json` → `nx-monorepo`.
- `package.json` with React for the browser (`react-dom`, Next.js, Remix or React Router, Vite with React) → `react-web`.
- `package.json` with a Node server (Express, Fastify, NestJS, Hono) → `node-service`.
- `pyproject.toml`, `uv.lock` or `requirements*.txt` → `python`, plus `python-fastapi` (FastAPI in the dependencies) or `python-django` (Django in the dependencies, or `manage.py`). Starter config: `${CLAUDE_PLUGIN_ROOT}/templates/python/pyproject.toml`.
