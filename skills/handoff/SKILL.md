---
name: handoff
description: "Write a handoff when work goes to another agent, session or person, or continue from a handoff. Use at the end of a session or a task."
argument-hint: "[write | resume] [ticket id]"
---

# Handoff

> Playbook files named here: when the project has its own copy at `.playbook/local/<same path>`, use that copy instead.

Request: $ARGUMENTS

Rules: `${CLAUDE_PLUGIN_ROOT}/principles/15-agent-collaboration.md`. Shape: `${CLAUDE_PLUGIN_ROOT}/templates/handoff.md`.

## write

1. **Gather the facts**, not memories:
   - `git status` and `git log` for the branch and commits; push if the owner wants the next session to start from it. Run `sync-branch` before you push, so the next session starts from current code.
   - The commands you ran and their results; screenshot paths; data checks.
   - Open findings with their scenarios.
   - Decisions made and who made them; questions still open for the owner.
   - Processes still running (dev server, browser, local stack, listeners).
2. **Fill the template completely.**
   - **Next** names exactly who does what, with the inputs they need.
   - **Don't** lists the traps, such as a migration already applied or a setting changed.
   - Mark anything unverified as such.
3. **Deliver it**:
   - **To a subagent's caller**: as your final message.
   - **To a later session, another tool or a person**: as a comment on the ticket (via the tracker in `AGENTS.md` → Tracker), and in the PR description if a PR is open.
   - **In a workspace member** (the session-start message tells you): send the handoff to the lead with `SendMessage`. Also put it on the ticket, if the task has one in the tracker of this repository. Do not send it to another member. The lead sends the next step.
4. **Stop the processes you started**, unless the handoff names them under "Still running" with an owner.
5. **Before handing a bug or a review finding to a person** (human in the loop), try it first in a worktree (`reproduce-in-worktree`): the handoff carries the reproduction, what you tried, the result, the worktree path and branch, and your recommendation. Hand off without trying only when trying needs something you don't have, and say what.

## resume

1. **Read** the latest handoff on the ticket, plus the PR, the branch (`git log`, `git diff <base>...`) and `AGENTS.md`.
2. **Re-verify** before building on it: re-run the key check behind each "done" (one test command, one screenshot, one query). If something doesn't hold, say so and fix the plan.
3. **Check "Don't" and "Still running"** first: stop or reuse those processes deliberately.
4. **Continue the "Next" step.** Ask the owner any open questions before work that depends on them.
5. When you stop, write a new handoff. Never edit the old one: the history matters.
