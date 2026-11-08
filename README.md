# Agentic Playbook

An engineering playbook for AI coding agents. It gives Claude Code, Codex, Cursor and GitHub Copilot one shared set of rules, principles, templates, skills and agents, so that agent-driven work follows the same careful process in every project: clarify the requirements, plan with checks, build test-first, verify in the running product, review, and document.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## Contents

- [What's included](#whats-included)
- [Branches](#branches)
- [Requirements](#requirements)
- [Quick start](#quick-start)
- [Choosing how to install](#choosing-how-to-install)
- [Install for every project on this machine](#install-for-every-project-on-this-machine)
- [Install from GitHub](#install-from-github)
- [Set up a project](#set-up-a-project)
- [A workspace with several repositories](#a-workspace-with-several-repositories)
- [Keeping long-running branches current](#keeping-long-running-branches-current)
- [Using it with other tools](#using-it-with-other-tools)
- [Customising](#customising)
- [Skills and agents](#skills-and-agents)
- [Worktrees and human review](#worktrees-and-human-review)
- [Guardrails](#guardrails)
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
| `skills/` | 24 skills: repeatable procedures such as `start-task`, `implement`, `verify-feature`, `security-audit` and `ship-pr`. |
| `agents/` | 8 subagents: product owner, product engineer, architect, QA verifier, code reviewer, security auditor, design reviewer and docs keeper. |
| `hooks/` | Claude Code hooks: one tells agents where the playbook and the project's overrides are, and in a workspace who the lead is; one blocks AI attribution and secrets in commits and PRs; one warns when the branch falls behind the team branch, or a rebase onto it would conflict. |
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
| `all` | One install for every kind of project | all of the above |

Each branch has a `BRANCH.md` with its extra prerequisites. `all` merges every branch, so one machine-wide install serves projects on different stacks; its additions are in clearly labelled sections ("Mobile (iOS and Android)", "Python", "Supabase"). To combine only some branches in your fork, merge one into another (`git checkout mobile && git merge supabase`); branches add sections at the end of shared files, so a conflict means keeping both sections.

## Requirements

- **git**, **bash** and **rsync** (macOS and Linux; on Windows, use WSL).
- **Claude Code** for the plugin, skills and agents ([install guide](https://docs.claude.com/en/docs/claude-code/overview)). Other agents (Codex, Cursor, GitHub Copilot, Gemini CLI) read the generated `AGENTS.md` and rule files.
- An issue tracker that your agent can reach: Linear or Jira through their MCP servers, or GitHub through the `gh` CLI.
- **Node.js (LTS)** to run the Playwright screenshot templates on `main`. Branches list their own tools in `BRANCH.md`.

## Quick start

```bash
# 1. Clone the playbook (or your fork) and pick a branch.
git clone https://github.com/seancabalse/agentic-playbook.git
cd agentic-playbook
git checkout all             # or: main, mobile, python, supabase

# 2. Install it for every project on this machine.
claude plugin marketplace add "$PWD"
claude plugin install playbook@agentic-playbook --scope user
```

Then open any project in Claude Code (start a new session) and run `/playbook:bootstrap-project`. It asks what it can't infer, writes or completes the project's `AGENTS.md` (with section 8 filled in and each command verified), writes ADR 0001 for the stack, sets up worktrees, and creates the living docs in your tracker.

## Choosing how to install

| Way | Best for | How it updates |
| -- | -- | -- |
| [Every project on this machine](#install-for-every-project-on-this-machine), from a local clone (**recommended**) | One person, many projects | `git pull` in the clone |
| [From GitHub](#install-from-github), without a clone | Trying it, a team, or following a branch with no local edits | `claude plugin update` |
| [Set up a project](#set-up-a-project) | Every project: `AGENTS.md`, worktree settings, and files for Codex, Cursor and Copilot | Run the installer again |

Claude Code always gets the playbook from the plugin, installed once per machine. A project never registers its own copy as a plugin: plugin sources belong to the machine, not the project, so a project's `.playbook/` registered as `agentic-playbook` replaces your install for **every** project. If the session-start message says the plugin is read from some project's `.playbook/`, follow [Keeping up to date](#keeping-up-to-date) to point it back.

## Install for every project on this machine

```bash
git clone https://github.com/seancabalse/agentic-playbook.git ~/code/agentic-playbook
cd ~/code/agentic-playbook
git checkout all
claude plugin marketplace add "$PWD"
claude plugin install playbook@agentic-playbook --scope user
```

- Claude Code reads the plugin directly from the clone. Skills appear as `/playbook:<name>` in every project, and the agents and hooks load automatically.
- To update, run `git pull` in the clone and start a new session.
- Your own changes for all your projects go in your fork. Changes for one project go in that project's `.playbook/local/` (see [Customising](#customising)).
- In each project, run `/playbook:bootstrap-project` once. The project needs no copy of the playbook.

## Install from GitHub

The repository is a Claude Code plugin and its own marketplace:

```text
/plugin marketplace add seancabalse/agentic-playbook
/plugin install playbook@agentic-playbook
```

- **A branch**: `/plugin marketplace add seancabalse/agentic-playbook#all` (or `#mobile`, `#python`, `#supabase`).
- **Your fork**: use `<you>/agentic-playbook`.
- **Updates**: `claude plugin update playbook@agentic-playbook`. Publishers bump `version` in `.claude-plugin/plugin.json`.
- **For a whole team**: commit `.claude/settings.json` from `templates/claude-settings.json`. Everyone who trusts the repository is offered the plugin from GitHub. Someone who installed from a clone or a fork should decline it, or it replaces their source on their machine.

Validate a change with `claude plugin validate .`, and try it without installing with `claude --plugin-dir .`.

## Set up a project

`/playbook:bootstrap-project` runs this for you. By hand, from a clone:

```bash
./scripts/playbook.sh project ~/code/my-app --stack node-service,react-web --tracker github
```

It writes:

| File | Purpose | Commit it? |
| -- | -- | -- |
| `AGENTS.md` | Built from the playbook's `AGENTS.md`, then the chosen stacks and the tracker section. | Yes |
| `CLAUDE.md` | `@AGENTS.md`, so Claude Code loads the same rules. | Yes |
| `.claude/settings.json` | Starts agent worktrees from your current branch (`--tools plugin`, the default). It never registers a plugin source. | Yes |
| `.playbook/` | A copy of the playbook, only with `cursor`, `copilot` or `claude`: those tools read files in the repository. It is not a plugin. | Yes |
| `.claude/skills/`, `.claude/agents/` | Copies of the skills and agents, only with `--tools claude` (no plugin). | Yes |
| `.cursor/rules/` | The skills as Cursor rules, only with `cursor`. | Yes |
| `.github/copilot-instructions.md`, `.github/prompts/` | Copilot instructions and prompt files, only with `copilot`. | Yes |

Options:

| Option | Default | Effect |
| -- | -- | -- |
| `--stack a,b` | none | Stack sections to append to `AGENTS.md` (see `./scripts/playbook.sh list`). |
| `--tracker linear\|jira\|github` | none | The tracker section to append. For another tracker, copy `trackers/github.md` and fill in the same headings. |
| `--tools plugin\|claude,agents,cursor,copilot` | `plugin,agents` | Which files to write. Choose `plugin` (Claude Code uses the installed plugin) or `claude` (copies in `.claude/`, for machines without the plugin), never both: both would load every skill twice. |
| `--force` | off | Replace files that exist. `.playbook/local/` is never replaced. |

The installer never overwrites a file without `--force`. If the project already has an `AGENTS.md`, it writes `AGENTS.playbook.md` for you to merge; your project's rules win. If `.claude/settings.json` registers `./.playbook` as a plugin source (an older install), it warns you to remove it.

Other targets:

```bash
./scripts/playbook.sh user       # copies of the skills and agents in ~/.claude, without the plugin
./scripts/playbook.sh prompts    # plain prompt files for any chat assistant (dist/prompts/)
```

### When to run `/playbook:bootstrap-project`

The machine-wide install and the project setup do different jobs, and you need both:

- **The plugin** (machine-wide, [Choosing how to install](#choosing-how-to-install)) gives Claude Code the skills, agents, hooks, principles and templates. Install it once per machine. Without it, `/playbook:bootstrap-project` doesn't exist.
- **The project setup** (`/playbook:bootstrap-project`, or `playbook.sh project` by hand) writes the files that one repository commits. Run it once per repository.

| Situation | What to do |
| -- | -- |
| A new project | Create the scaffold first (`create-nx-workspace`, `create-expo-app`, `uv init`, …), then run the skill. It infers the stacks from the manifests and runs each command it lists in `AGENTS.md`. In an empty folder, give it the brief or PRD; it can't verify commands until they exist. |
| An existing repository without an `AGENTS.md` | Run the skill once. |
| An existing repository with an `AGENTS.md` | Run the skill once. The installer writes `AGENTS.playbook.md` beside yours and the skill merges it: your project's rules win, and it lists the conflicts for you. |
| A repository from an older install that registers `./.playbook` as a plugin | Remove that registration first ([Keeping up to date](#keeping-up-to-date)), then run the skill. |
| A repository that is already set up | Don't run it again. To take new `AGENTS.md` rules after a playbook update, run `playbook.sh project <repo>` without `--force` and merge `AGENTS.playbook.md`. `--force` replaces `AGENTS.md`, section 8 included. |
| A teammate's clone of a set-up repository | Don't run it. The teammate installs the plugin on their machine; the committed `AGENTS.md`, `CLAUDE.md` and `.claude/settings.json` do the rest. |
| A machine that can't install the plugin | Run `playbook.sh project <repo> --tools claude,agents` from a clone. It copies the skills and agents into the repository, so the skill is then `/bootstrap-project`, without the `playbook:` prefix. Don't also install the plugin: every skill would load twice. |

## A workspace with several repositories

When one project spans several repositories, such as a frontend and a backend, put them in a **workspace**: a folder that is its own git repository (the main repository), with each project repository cloned inside it and any reference material beside them.

```text
shop/                  ← the workspace repository; the lead session runs here
├── AGENTS.md          ← sections 1–7 of the playbook, and section 8 for the workspace
├── docs/workspace/    ← the lead's records: epics/, STATUS.md, HANDOFFS.md, DECISIONS.md
├── backend/           ← its own git repository, ignored by the workspace
├── frontend/          ← its own git repository, ignored by the workspace
└── refs/              ← reference material: read, never changed
```

Set it up from a clone of the playbook (on Windows, in Git Bash):

```bash
~/code/agentic-playbook/scripts/playbook.sh workspace ~/code/shop
```

It asks, one question at a time (Enter keeps the answer in brackets):

1. Whether this folder is the workspace repository, and whether to run `git init` if it isn't one yet.
2. The tracker.
3. For each folder, in alphabetical order:
   - **A git repository**: whether it's part of the project, its role (frontend, backend or other), and its stacks (suggested from its manifests). If it has no `AGENTS.md`, whether to set it up now (the same as `playbook.sh project`).
   - **Any other folder**: whether it's reference material.

It writes `AGENTS.md` (with the members, the session names and start commands, and the workspace rules), `CLAUDE.md`, `docs/workspace/`, `.claude/settings.json`, and `.gitignore` entries for the member repositories. Run it again at any time: it never replaces a file without `--force`, and never replaces the records.

Then:

1. Fill in section 8 of the workspace's `AGENTS.md`, and run `/playbook:bootstrap-project` in each member repository.
2. Start the lead at the root: `claude -n lead`.
3. Give the lead an epic (`/playbook:lead KEY-10`, or a description). It asks the product questions, and where to keep the task briefs: in the tracker as sub-tasks of each story, or as Markdown files in `docs/workspace/tasks/`. It divides the epic into **stories** (changes a user can see, which can span repositories; it reuses the stories already in the tracker) and each story into **tasks** (one PR in one repository). It agrees the contracts between the repositories and writes a complete brief for each task.
4. The lead works one story at a time where it can, and tests each story across the repositories as soon as its tasks are done, so you can review it early. For each task, the lead gives you the command for a **new** session, such as `cd backend && claude -n backend-KEY-13 "/playbook:start-task KEY-13"`. When the lead has checked the task's handoff, it tells you to close that session. With the CLI, you can let the lead start and stop these sessions itself (see below). When two sessions work in one repository at the same time, the second one gets its own worktree (`-w`).

### Why a new session for each task

A long session sends its whole conversation again with each message, so it uses more tokens as it grows. A session for one task starts with only the rules and that task's brief, and closes when the task is done. Nothing is lost, because the context is in files, not in the sessions:

- the epic file (`docs/workspace/epics/<epic>.md`): the stories and tasks, their order, the contracts and the notes later tasks need;
- each task's brief: the epic in one sentence, its story and the story's acceptance criteria, the task's acceptance criteria, the full contracts and what earlier tasks delivered;
- `STATUS.md`, `HANDOFFS.md` and `DECISIONS.md`.

### Keeping the lead's context small

When the context of the lead becomes large, its work becomes worse, and the lead cannot see this. Thus, the lead obeys fixed rules. It does not use its opinion to decide.

- **The lead does not read diffs or test output.** A `code-reviewer` subagent examines each handoff. It compares the diff with the scope and the contracts, predicts the conflicts, and runs the checks in a temporary worktree. It replies in 15 lines or fewer, with 300 characters or fewer in each line. A subagent also runs the cross-repository checks.
- **The lead starts again at fixed points**: when a story is done, and after 5 handoffs. First, it writes a **Lead checkpoint** in the epic file: the replies that it waits for, your open questions and the next steps. Then it commits the records and tells you to start a new lead. Close the lead, and run `claude -n lead "/playbook:lead KEY-10"`. For a lead in the background, run `claude stop <id>`, then start it again with `--bg`. You do not have to wait until no member works. The new lead asks the running members to send their handoffs again. Keep the name `lead`, because the members send their handoffs to that name.
- **Start a new lead. Do not use `/compact`.** A new lead reads files that were written on purpose. A summary keeps only the data that it selects.
- **After an automatic compaction**, the session-start hook tells the lead that its summary can be wrong. The lead reads the records again before it routes a task. A member reads its brief again, or asks the lead to send it again.
- **A member session gets fixes for two rounds only.** At the third round, or after its context is compacted, the lead continues the task in a new session.
- **A member does not do work that is not in its brief.** It writes the work in its handoff. If the work is small, in the same repository and for the same story, the lead adds it to the brief. If not, the lead makes a new task.
- **The lead divides a task before it starts** if the task has a data migration and other changes, or makes one contract and uses a different contract that is not complete, or has more than approximately 400 changed lines.

A task that needs another session later, for review comments or a failed check, keeps its sub-task and its branch. The lead adds the last handoff to the brief, and the new session starts in the branch's existing worktree.

### Scout tasks, effort levels, open decisions and delivery

- **Scout tasks.** If an unknown stops the plan of a story, the lead makes a scout task first. Examples: an area of the code that nobody understands, a risk, or a choice between approaches. A scout session investigates and sends a report, with no PR. The lead saves it in `docs/workspace/scouts/`. A report can recommend work, but only you give approval. The lead puts the findings in the briefs of the build tasks, so that they do not investigate again.
- **Effort levels.** The lead gives each task an effort level: `low` for a small task with a clear path, `medium` or `high` for a usual task, `xhigh` for an unclear design or a scout task. It never uses `max` unless you ask. The start command includes `--effort <level>`. In the desktop app, type `/effort <level>` in the new session.
- **Open decisions.** The lead writes each question for you in `STATUS.md`, "Open decisions", with the options and the recommended option first. A decision closes only when you answer. Then the lead records it in `DECISIONS.md`. The lead asks only decisions, and writes progress in `STATUS.md`. When you come back, or when a new lead starts, it asks the open decisions one at a time, starting with the one that stops the most work.
- **Delivery.** Section 8 of `AGENTS.md` has a **Delivery** line: PR (the default), or local merge. With a local merge, `ship-pr` opens no PR. It gives you the commands to squash-merge the branch locally.

### Letting the lead start the sessions (CLI)

By default you start each task's session with the command the lead gives you. If the lead runs in the Claude Code CLI, it can start and stop them itself, in the background. It asks you when it plans the epic, and you set the maximum number of member sessions at a time.

Before you say yes:

- **Trust each member repository once.** Open a normal session in `backend/`, `frontend/` and so on, and accept the trust question. A background session can't show it.
- **The sessions run in auto mode** (`--permission-mode auto`), because a background session can't answer a permission prompt either. Auto mode lets a safety check approve actions instead of asking you. The lead never uses `bypassPermissions`.
- **Keep every session on one side.** On Windows, run the lead and all members in the CLI inside WSL, or all natively; WSL and native Windows sessions can't message each other. The Claude Desktop app can't be started this way, so with Desktop you keep starting the sessions yourself.

The lead starts each one like this (the parentheses keep the lead's own shell at the workspace root), and records the short id it prints:

```bash
(cd backend && claude --bg -n backend-KEY-13 --permission-mode auto --effort high "/playbook:start-task KEY-13")
```

You can also run the lead itself in the background. Claude Code lets a background session write only in a worktree. The lead must write its records at the workspace root, so the setup writes `"worktree": { "bgIsolation": "none" }` in the workspace's `.claude/settings.json`. This changes only the workspace repository, which holds only the records. The member repositories keep the guard. The lead never makes or enters a worktree for itself.

To watch or step in, use `claude agents` (the list), `claude attach <id>` and `claude logs <id>`. When a task is done, the lead runs `claude stop <id>`, which keeps the conversation; it never runs `claude rm`. If a session stops at a permission or trust question, the lead tells you to open it with `claude attach <id>`. If a member asks a product question, the lead passes it to you and sends your answer back.

### Moving sessions that are already running to this flow

A plugin update doesn't change sessions that are already running: each keeps the version it started with until you restart it. So nothing breaks, and you can switch at a clean point. Don't stop a session in the middle of a task.

**The simplest route:** if none of the work is urgent, finish the current epic with the old sessions, and use the new flow from the next epic.

**To switch an epic that is in progress** (for example, a lead with three backend and three frontend sessions):

1. **Sort the member sessions.** Ask the old lead which tasks are nearly done and which are half started or not broken down well.
   - Nearly done: let them finish under the old flow, open their PRs and close. Moving them costs more than it saves.
   - Everything else: move it with the steps below.

2. **Bring each remaining member to a safe stop.** In each of those sessions, type:

   > Stop at the next clean point. Commit your work on your branch, push it, and write `/playbook:handoff write` to the lead. Include what is done, what remains, and your worktree path.

   Commit and push before you close the session. When you close a session that was started with `-w`, Claude Code can offer to remove its worktree. When the branch is pushed, nothing is lost, whatever you answer.

3. **Let the old lead record everything.** When all the handoffs have arrived, ask it:

   > Record every handoff in HANDOFFS.md and update STATUS.md with each branch, commit and worktree path. Commit the records.

   Then close the old lead.

4. **Update the plugin and start a new lead** (`claude -n lead`; in the desktop app, a new session with `/rename lead`). Give it:

   > /playbook:lead KEY-10. This epic is already in progress under the old flow. Don't plan it from scratch. Build docs/workspace/epics/KEY-10.md from STATUS.md, HANDOFFS.md and the pushed branches. Treat the work on each existing branch as one task, and add the remaining work as new tasks under the right stories. Write a brief for each task that continues a branch, with the branch, its commit and the last handoff. Ask me where to keep the briefs.

   Don't ask it to split branches that already exist. Splitting a half-built branch into neat tasks costs more than it saves. The new breakdown only needs to cover work that isn't written yet.

5. **Replace the old member sessions one task at a time.** When the lead gives a task a new session, close the old session of that task first, then start the new one. For a task that continues a branch, start the new session in that branch's existing worktree, without `-w`:

   ```bash
   cd backend/.claude/worktrees/backend-2 && claude -n backend-KEY-13 "/playbook:start-task KEY-13"
   ```

   Git lets a branch be checked out in only one worktree at a time, so reusing the old worktree is simpler than making a new one. The session-start message works inside worktrees. New tasks get new sessions, with the commands the lead gives you.

6. **Clean up.** When a task's PR is merged, remove its worktree, for example `git -C backend worktree remove .claude/worktrees/backend-2`.

Members send their handoffs to the lead, and the lead routes the next step. The sessions talk through Claude Code's [cross-session messages](https://code.claude.com/docs/en/cross-session-messaging.md), which need no setup. Run them all on the same machine; on Windows, all natively or all inside WSL, because the two can't message each other. The roles and rules are in `principles/15-agent-collaboration.md`, "Across repositories".

## Keeping long-running branches current

On a busy team branch (`main` or `dev`, with many commits a day), a branch that an agent works on for hours falls behind, and the conflicts grow while it works. The playbook catches this early:

- **A hook warns the session** (it never changes the branch). At session start, it says when the branch is behind the team branch. Before each `git commit` and `git push`, it warns only when a rebase would conflict (and names the files), or when the branch is 50 or more commits behind. It predicts conflicts in memory with `git merge-tree`, fetches at most every 2 minutes in the background, waits at most 5 seconds for it, and never waits for a password. A branch stacked on another task's unmerged branch is compared with that branch instead.
- **The `sync-branch` skill brings the branch up to date**: fetch, predict conflicts, rebase (with `rerere`, so a resolution is reused next time, which the agent re-checks), resolve the conflicts that are clearly within the task, run the full checks, and update a branch that's already pushed with `--force-with-lease --force-if-includes`. It syncs only committed work (no `--autostash`, because worktrees share one stash), never pushes a new branch, and rebases with `--onto` once a stacked base has been merged. A conflict that needs a decision about someone else's change makes it abort the rebase, leave the branch as it was, and ask you (or the lead) with both sides and a recommendation.
- **Skills run it at the right points**: `start-task` on an existing branch, `handoff` before pushing, and `ship-pr` before the PR. In a workspace, the lead also checks each handed-off branch against the team branch and against the other branches in progress in the same repository, and tells both sessions when they will conflict.

Set the team branch once per clone (all its worktrees share it). Without it, the hook and the skill use the remote's default branch, then `main` or `master`. Conflict prediction needs git 2.38 or later (check with `git --version`, notably on older WSL distributions):

```bash
git config playbook.integrationBranch dev
```

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
| `sync-branch` | Keep a task branch current with the team branch (main or dev): predict conflicts, rebase, resolve the clear ones or stop, run the checks, push with `--force-with-lease`. |
| `reproduce-in-worktree` | Reproduce a bug or review finding in an isolated git worktree and try the fix there before a person is involved. |
| `verify-feature` | Find the impact of the change, run only the tests that it can affect, and walk the acceptance criteria in the running product, with the error and edge states. |
| `capture-screenshots` | Capture states × sizes × settings as evidence for a PR. |
| `handoff` | Write or resume a handoff between agents, sessions or people. |
| `lead` | Lead a workspace of several repositories: divide an epic into stories and tasks, agree the contracts, give each task a new session with a complete brief, route the handoffs, and keep the records. |
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
| `qa-verifier` | Finds the impact of the change and runs only the tests that it can affect. Runs the product, walks the acceptance criteria and captures screenshots. |
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

**Merging.** PRs are squash-merged: one commit per PR on the team branch, titled from the PR, while the branch keeps its small commits for review. Set the repository to allow only that and to delete merged branches (`/bootstrap-project` lists it as an owner task):

```bash
gh repo edit --enable-squash-merge --enable-merge-commit=false --enable-rebase-merge=false --squash-merge-commit-message pr-title-description --delete-branch-on-merge
```

**Screenshots.** `/ship-pr` won't open a PR that changes anything a person sees (components, screens, styles, copy, images, email or notification templates) without screenshots from `capture-screenshots`. A PR with no visible change says why instead.

## Guardrails

The plugin's hooks enforce two rules from the working agreement, so they don't depend on an agent remembering them:

| Hook | Blocks | Turn off or adjust |
| -- | -- | -- |
| AI attribution | `Co-Authored-By: Claude…`, "Generated with Claude…" in `git commit` and `gh pr create/edit` | Create `.playbook/local/allow-ai-attribution` |
| Secrets in commits | Staged `.env` and key files, private keys, and AWS, GitHub, Slack, Stripe, Anthropic, OpenAI and Supabase secret tokens | List allowed paths in `.playbook/local/secret-scan-allow` |

A blocked command shows the file, the line and the kind of secret, never its value. The hooks cost no context tokens.

A third hook only warns: when a branch falls behind the team branch, or a rebase onto it would conflict (see [Keeping long-running branches current](#keeping-long-running-branches-current)). It adds one line to the context, and only when it warns.

## Keeping up to date

- **A machine-wide install**: `git pull` in the clone, then start a new session.
- **Your fork**: `git remote add upstream https://github.com/seancabalse/agentic-playbook.git`, then `git pull upstream <branch>`.
- **A plugin installed from GitHub**: `claude plugin update playbook@agentic-playbook`.
- **A project's committed copy** (Cursor, Copilot): run the installer again with `--force` and review the diff. `.playbook/local/` is kept.
- **The plugin points at a project's `.playbook/`** (an older install registered it): remove `extraKnownMarketplaces` for `./.playbook` and its `enabledPlugins` entry from that project's `.claude/settings.json`, then run `claude plugin marketplace remove agentic-playbook`, add your clone (or `seancabalse/agentic-playbook`) again, and `claude plugin install playbook@agentic-playbook --scope user`.

## Contributing

Issues and pull requests are welcome.

- Generic changes go to `main`. Platform or language changes go to their branch. `main` is merged into each branch regularly.
- Keep rules short, concrete and testable. Every rule should say what to do, not only what to avoid.
- Before you open a PR, run `bash -n scripts/playbook.sh` and `claude plugin validate .`, and try an install with `./scripts/playbook.sh project <temp dir>`.
- Bump `version` in `.claude-plugin/plugin.json` when skills, agents or hooks change.

## License

[MIT](LICENSE) © 2026 Sean Cabalse
