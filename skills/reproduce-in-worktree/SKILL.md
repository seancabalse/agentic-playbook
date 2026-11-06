---
name: reproduce-in-worktree
description: "Reproduce a bug or a review finding in a git worktree, and try the fix there before you ask a person. Use for bugs, investigations and reviews."
argument-hint: "[bug, finding, PR or branch to investigate]"
---

# Reproduce and fix in a worktree

> Playbook files named here: when the project has its own copy at `.playbook/local/<same path>`, use that copy instead.

Subject: $ARGUMENTS

A worktree is a second checkout of the same repository in its own folder. You can install, break, test and fix there without touching the main checkout, other people's uncommitted work, or another agent's files. Use it to **try before you hand off**: a person should get a reproduced problem and an attempted fix, not a guess.

## 1. Create the worktree

1. Check the main checkout first (`git status`). Never stash, reset or commit someone else's work to make room.
2. Create it:
   - **In Claude Code**: ask to "work in a worktree" (the `EnterWorktree` tool; `ExitWorktree` leaves it), start a session with `claude --worktree <name>`, or delegate to an agent with `isolation: worktree`. Claude Code puts worktrees in `.claude/worktrees/` and branches them from the default branch, or from your current `HEAD` when the project sets `"worktree": { "baseRef": "head" }`.
   - **With git** (any tool): a bug on the default branch: `git worktree add .claude/worktrees/<topic> -b wt/<topic> origin/<default-branch>`. A branch or PR under review: `git fetch origin <branch>` (or `git fetch origin pull/<n>/head:pr-<n>` on GitHub), then `git worktree add .claude/worktrees/<topic> <branch or pr-n>`.
   - Make sure the worktree has the code you mean to test: the right branch or commit (`git -C <path> log -1`).
3. Set it up the project's way, from its `AGENTS.md` "Commands": install from the lockfile (`npm ci`, `uv sync`, …) and generate what's generated.
4. Local configuration: gitignored files (`.env`, local config) aren't in a new worktree. Claude Code copies the ones listed in the project's `.worktreeinclude`; otherwise copy only what the reproduction needs. Never print secrets, and never commit them.
5. Shared local services (a database container, a dev server port, an emulator) are shared with the main checkout. Use a separate port or database when the reproduction changes data, or say what you share.

## 2. Reproduce

1. Write the smallest **failing test** that shows the problem, next to the code it covers. If a test isn't possible (a device, a third-party UI), write a script or exact manual steps.
2. Run it and keep the output. A bug you can't reproduce is a finding too: record what you tried and what you saw.
3. For a review finding, the reproduction is the proof: the input, the command and the wrong output. A finding you can't reproduce is reported as unproven, not as fact.

## 3. Try the fix

1. Follow `implement` / `fix-bug`: find the root cause, make the smallest change that makes the test pass, and keep the test.
2. Run the project's full check suite in the worktree. A fix that breaks something else isn't a fix.
3. Two real attempts at most. If the problem still isn't solved, stop and hand off with what you learned.

## 4. Bring it back, or hand off

- **Fixed and verified**: commit in the worktree on its own branch, following the project's commit rules, and say how to bring it in: a PR from that branch, or a cherry-pick onto the working branch. Ask before pushing, merging or opening a PR if the project's rules require it.
- **Needs a person** (a product decision, a credential, a device you don't have, or the fix needs a judgement call): hand off with the `handoff` shape and include:
  - the worktree path and branch;
  - the reproduction: the failing test or the steps, and its output;
  - what you tried and the result of each attempt;
  - your recommended fix, and what's still unknown.

## 5. Clean up

- Stop anything you started in the worktree (dev servers, containers, emulators).
- If the result is merged or no longer needed: `git worktree remove <path>` and delete the throwaway branch (`git branch -D wt/<topic>`). Claude Code removes an agent's worktree by itself when the agent changed nothing.
- If a person needs to inspect it, keep it and list it under "Still running" in the handoff, with the command to remove it.

## Rules

- One writer per worktree. Never edit the main checkout from a worktree session, and never edit another agent's worktree.
- Worktrees share one `.git`: don't run commands that rewrite shared refs (`reset --hard` on a shared branch, `gc --prune`, force pushes to a branch someone else uses, `rebase --update-refs`, `git stash` that another session could pop) while others work. Rebasing and force-pushing your own task branch with `sync-branch` is fine.
- Reviewers stay read-only in the main checkout. In their own disposable worktree they may add a failing test to prove a finding; the test goes into the handoff, not into the reviewed branch.
