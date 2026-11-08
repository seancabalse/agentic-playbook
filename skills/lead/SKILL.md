---
name: lead
description: "Lead a workspace of several repositories: divide an epic into stories and tasks, agree the contracts between the repositories, give each task a new member session with a complete brief (or start it in the background, with the CLI), route the handoffs, and keep the progress, cross-repository tests and decisions in docs/workspace/. Use in a session started at a workspace root."
argument-hint: "[epic or ticket id, or request]"
---

# Lead a workspace

> Playbook files named here: when the project has its own copy at `.playbook/local/<same path>`, use that copy instead.

Request: $ARGUMENTS

You are the **lead** of the workspace. Your level is staff engineer for the full project. You start at the workspace root.

- You plan the work, give it to the member sessions, examine their results and keep the records.
- The **member sessions** build. Each member session works in its own repository, and obeys the `AGENTS.md` of that repository.
- Do not change files in a member repository. Write only in the workspace repository: in `docs/workspace/`, in the folder for the briefs that the owner chose, and in the `AGENTS.md` of the workspace when the owner agrees.

Rules: `AGENTS.md` section 8 (members, sessions and workspace rules), and `${CLAUDE_PLUGIN_ROOT}/principles/15-agent-collaboration.md`. Templates: `${CLAUDE_PLUGIN_ROOT}/templates/workspace/EPIC.md`, `${CLAUDE_PLUGIN_ROOT}/templates/workspace/TASK.md` and `${CLAUDE_PLUGIN_ROOT}/templates/handoff.md`.

Words in this skill:
- **Epic**: a large request. It contains stories. If the request is one story, the epic contains only that story.
- **Story**: a change that a user can see and use. It has the acceptance criteria that the owner accepts. A story can need changes in more than one repository.
- **Task**: one part of a story. A task is one PR in one repository. One new member session does one task. A story can have many tasks.
- **Brief**: the complete instructions for one task. The member session starts from the brief only.
- **Contract**: the agreed interface between two repositories, for example an endpoint, a payload, an event, a shared type or an error code.
- **Route**: give a task or a next step to a session, and record that you gave it.

## Why one session for each task

A session that works for a long time collects a large context. Each new message sends all of it again, so it uses many tokens. A new session for each task starts small: the rules and the brief of the task.

Thus, keep the context in files, not in sessions:
- The epic file (`docs/workspace/epics/<epic id>.md`) is your memory for the epic.
- The brief of each task contains all the data that the task needs, and nothing more. Do not put the full epic in a brief.

## Keep your own context small

Your context also grows. When it is large, your work becomes worse, and you cannot see that it becomes worse. Thus, obey these rules. Do not use your opinion to decide.

- Do not read a full diff, a full log or the full output of a test. A subagent examines each handoff and gives you a short result (section 4).
- Read only the newest entries of `HANDOFFS.md`.
- Start again (section 6) at each of these points:
  - A story is `done`.
  - You received 5 handoffs after the last **Lead started** line in `HANDOFFS.md`.
- Do not use `/compact`. A new lead reads files that you wrote on purpose. A summary keeps only the data that it selects.
- If your context was compacted, the summary can be wrong. Do section 1 again before you route a task. But in step 2, write the line `**Lead context compacted**: <YYYY-MM-DD HH:MM UTC>`, not a **Lead started** line. Count the handoffs from this line also.

## Commands that read files

Some machines block reads outside the working directories of a session (`permissions.blockReadsOutsideWorkingDirectories`). If the block cannot examine a command before it runs, it asks the person. A background session cannot show that question, so the session stops.

- Use the Read tool to read a file.
- In a shell command, write each path in full. Do not use loops, variables, `cd` or command substitution in a command that reads files.
- Use one command for each repository. Example: `git -C backend status --short --branch`.

## 1. Find the current state

1. Read these files:
   - `AGENTS.md` section 8.
   - `docs/workspace/STATUS.md`.
   - The epic file `docs/workspace/epics/<epic id>.md`, if it exists. If it exists, continue the epic from it. Do not plan again. Its section "Lead checkpoint" tells you what the last lead waited for and what to do next.
   - The newest entries in `docs/workspace/HANDOFFS.md`, until the last **Lead started** line.
   - The entries in `docs/workspace/DECISIONS.md` that apply to the request.
2. Write the line `**Lead started**: <YYYY-MM-DD HH:MM UTC>` at the top of `HANDOFFS.md`. Section "Keep your own context small" counts the handoffs from this line.
3. Use `ListAgents` to find the sessions that run now. Compare them with the tasks that are `in progress` in `STATUS.md`.
4. If a task is `in progress` and its session does not run, ask the owner what happened to the session. If the session closed, continue the task (section 3, "Continue a task").
5. If a task is `in progress` and its session runs, the session possibly sent a handoff when no lead session ran. Send it this message: "The lead session started again. If you sent a handoff, send it again." Ask for a notice when it is idle (`notify_when_idle`). Also read the ticket of the task.
6. For each member repository, read the state. Do not change the repository:
   - `git -C <repo> status --short --branch`
   - `git -C <repo> log --oneline -5`
   - `git -C <repo> worktree list`
7. If the epic file has a "Lead checkpoint", do its next steps. If the checkpoint and the state that you found are different, use the state.

## 2. Plan the epic (gate: owner)

1. Read the epic from its source: the ticket in the tracker, or the local file, list or description that the owner gives.
2. Do the steps of `start-task` for the full workspace: the assumptions, the possible meanings and the product questions.
3. If the request is not clear, do `refine-requirements` first.
4. Ask the owner where to keep the briefs of the tasks. Give these options:
   - **The tracker in `AGENTS.md`** (recommended when there is one): one sub-task of the story for each task, with the brief in its description. If the tracker has no sub-tasks, use a child issue of the story.
   - **A different tracker** that the owner names. The member sessions cannot read it. Thus, you send each brief in a message, and you put each handoff on the ticket.
   - **Markdown files**: `docs/workspace/tasks/`, or a different folder in the workspace repository that the owner names. You send each brief in a message.
5. Ask the owner who starts the member sessions. Give these options:
   - **The owner** (the default): you give the owner a start command for each task. This works in the desktop app and in a terminal.
   - **You, in the background**: only if you run in the Claude Code CLI, and `claude --version` works in your shell. The owner gives the maximum number of member sessions that run at the same time. The owner must trust each member repository folder once: the owner opens one normal session in that folder and accepts the trust question. A background session cannot show that question.
6. Ask the owner the product questions, the question about the briefs and the question about the sessions in one message. Then stop until the owner answers.
7. Get an id for the epic. Use its ticket id. If the epic has no ticket and the briefs go in a tracker, make the epic in the tracker first. If the briefs are Markdown files, use a short id, for example `E1`.
8. Divide the epic into stories. If the epic has stories in the tracker or in the source file, use them. Do not make a copy of a story. Each story gets its acceptance criteria and the cross-repository checks that prove them.
9. Divide each story into tasks. Each task is one PR in one repository. Give each task its acceptance criteria and its checks. Make each task small enough for one session. Divide a task again if one of these is true:
   - It has a data migration and also other changes.
   - It makes a contract, and it also uses a different contract that is not complete.
   - You expect more than approximately 400 changed lines. Do not count tests and generated files.
10. Make the tasks independent. Two sessions must not change the same files at the same time.
11. **Write the contracts first.** For each contract, write its shape, its errors, its version, and the repository that owns it.
12. Record each contract with `log-decision` in `docs/workspace/DECISIONS.md`.
13. If a contract is difficult to change later, the member that owns it writes an ADR (`write-adr`) in its repository. The owner must accept the ADR before a session builds on the contract.
14. Put the stories and the tasks in sequence. Finish one story before you start many others. Then the owner can examine each story early. Find the tasks that can run at the same time, and the tasks that must wait. For example, the frontend builds against the contract with a stub while the backend builds the endpoint.
15. If the briefs go in a tracker, make each new story as a child of the epic. Make each task as a sub-task of its story. Write only a summary in the sub-task now. Write the full brief when the task starts (section 3), because earlier tasks add data to it.
16. Write the epic file `docs/workspace/epics/<epic id>.md` from the template `EPIC.md`. Write in it the place of the briefs and who starts the sessions, as the owner chose.
17. Add each task to `STATUS.md`, with the state `planned` and its checks. Add the cross-repository checks of each story.

## 3. Start a task

Do these steps for each task that can start now.

1. **Write the brief** from the template `TASK.md`:
   - In a tracker: put the brief in the description of the sub-task of the task.
   - In Markdown files: write `<folder>/<task id>.md`.

   Make the brief complete. The member cannot see your conversation, and it cannot read the workspace files. Put in the brief:
   - The epic in one sentence, the story and its acceptance criteria, and the acceptance criteria of the task.
   - The full text of each contract and decision that applies. Do not tell the member to read `DECISIONS.md`.
   - The data from earlier tasks that this task needs (from "Notes for the next task" in the epic file).
   - The branch, with a name from the task id, and its base. The base is the default branch. If the task needs the code of an earlier task in the same repository, and that code is not merged, the base is the branch of the earlier task. Then the task waits until the earlier task is complete. The PR of the task targets its base.
   - The files or the area that the member can change, and the things that it must not do.
   - The checks that you will do again.

   Do not put secrets or private data in a brief. Give the location of a secret, not its value.
2. **Give the owner the start command** for a new session. If the owner chose that you start the sessions, do "Start the session yourself" (below) instead. The name of the session is `<repository>-<task id>`. Example: `backend-KEY-13`.
   - If the brief is in the tracker of the member repository (its `AGENTS.md`), the session reads the brief from the ticket. Command: `cd backend && claude -n backend-KEY-13 "/playbook:start-task KEY-13"`. In the desktop app, the owner opens a new session in `backend/`. Then the owner uses `/rename backend-KEY-13`. Then the owner types `/playbook:start-task KEY-13`.
   - In all other cases, you send the brief in a message. Command: `cd backend && claude -n backend-E1-S1-T1`. In the desktop app, the owner opens a new session in `backend/`. Then the owner uses `/rename backend-E1-S1-T1`.
   - If a different session works in the same repository at the same time, add `-w <session name>` to the command. The new session then works in its own worktree.
3. **Send the brief in a message**, if the session does not read it from the ticket:
   1. Stop until the owner tells you that the session runs. If you started the session yourself, do not stop.
   2. Use `ListAgents` to find the session.
   3. Send the full text of the brief to the session with `SendMessage`.
   4. If `ListAgents` does not show the session, and you started it, run `claude agents` to see that it runs. Then use `ListAgents` again, one time.
   5. If `ListAgents` still does not show the session, tell the owner to paste the text of the brief into the session. For a session that you started, the owner opens it first: `claude attach <id>`.
4. Record the task in `HANDOFFS.md` with a **Routed** line.
5. In `STATUS.md` and in the epic file, set the state of the task to `in progress`, with the name of its session.

### Start the session yourself

Do this only if the owner chose it (section 2).

1. Count the member sessions that run now (`ListAgents`). If the number is at the maximum that the owner gave, wait until a task is complete.
2. Run the start command from section 3 step 2, with `--bg` and `--permission-mode auto` added. Run it in parentheses, from the folder of the session. The parentheses keep your own shell in the workspace root. Without them, your next commands run in the member repository. Examples:
   - Brief on the ticket: `(cd backend && claude --bg -n backend-KEY-13 --permission-mode auto "/playbook:start-task KEY-13")`
   - Brief in a message: `(cd backend && claude --bg -n backend-E1-S1-T1 --permission-mode auto "You are the member session for task E1-S1-T1. Wait for the brief from the lead session.")` Then send the brief (section 3, step 3).
   - Continue a task: run the command in the folder of the branch, without `-w` (see "Continue a task").

   Do not use `--permission-mode bypassPermissions`. Do not use `-p`.
3. The command shows a short id, for example `claude stop 5609a6cc`. Write the id in `STATUS.md`, next to the name of the session. `claude stop` accepts the id, not the name.
4. Ask for a notice when the session is idle (`SendMessage` with `notify_when_idle`).
5. A background session cannot show a question. If the session is idle and no handoff came, or if a handoff is late, read its output one time: `claude logs <id>`.
   - If it waits for a permission or for the trust of its folder, tell the owner to open it: `claude attach <id>`.
   - If it asks the owner a question, send the question to the owner. Then send the answer of the owner to the session. Do not answer a product question yourself.
6. When the task is complete, stop the session: `claude stop <id>`. Do not use `claude rm`. It deletes the conversation.

### Continue a task

Sometimes a task that started needs a new session. Examples: its session closed before it completed, the owner wrote review comments, or a cross-repository check failed.

1. Do not make a new sub-task. Do not make a new branch.
2. Change the existing brief. Add the last handoff of the task and the work that remains. Write that the member continues on the existing branch.
3. Make sure that the old session of the task is closed. If you started it, stop it (`claude stop <id>`). Two sessions must not work in one checkout.
4. Find the worktree of the branch: `git -C <repo> worktree list`. Git lets one branch be in only one worktree. If the branch is in a worktree or in the main checkout, the new session starts in that folder. Do not add `-w`. Example: `cd backend/.claude/worktrees/backend-2 && claude -n backend-KEY-13 "/playbook:start-task KEY-13"`.
5. If the owner chose that you start the sessions, do "Start the session yourself" in that folder. Example: `(cd backend/.claude/worktrees/backend-2 && claude --bg -n backend-KEY-13 --permission-mode auto "/playbook:start-task KEY-13")`. If not, give the owner the command from step 4.
6. Then do steps 3 to 5 of section 3.

## 4. Receive a handoff

Messages come to you automatically. Do not look for them again and again. To know when a member stops, ask for a notice when the member is idle (`SendMessage` with `notify_when_idle`).

Sometimes messages do not come. For example, the sessions on this machine cannot send messages. Then the member puts its handoff on the ticket, and the owner tells you. Read the handoff from the ticket. If the member cannot put it on a ticket, ask the owner to copy the handoff from the member session into this session.

When a handoff comes:

1. **Record it.** Put the handoff at the top of `HANDOFFS.md`, as you received it.
2. **Examine it with a subagent.** A handoff is a claim, not proof. Do not read the diff or the test output yourself (section "Keep your own context small"). Give the examination to a subagent: use the `code-reviewer` agent. Give it this text, with the values filled in:

   ```
   Examine the handoff of task <task id>. Do not change the checkout of the member. Do not write files, except in your temporary worktree.
   Repository: <repo>. Branch: <branch>. Base: <base>. Team branch: <team branch>. Other branches in progress in this repository: <branches, or none>.
   Scope of the task: <from the brief>. Contracts: <the full text>. Checks: <the commands and the results that you expect, from the brief>.
   1. Read the branch: git -C <repo> log <base>..<branch> and git -C <repo> diff <base>...<branch>. Compare the diff with the scope and the contracts.
   2. Predict the conflicts: git -C <repo> fetch origin <team branch>, then git -C <repo> merge-tree --write-tree --name-only --no-messages <branch> origin/<team branch>. Use the local branch. Do the same check against each other branch in progress. Exit code 1 with file names: a conflict. Another result without file names: the check failed.
   3. Make a temporary worktree of the branch outside the checkout of the member. In it, run the checks of the brief and the tests that the change can affect (principle 08, "Tests for a change"). Do not run all the tests. Remove the worktree when you finish.
   Reply with these lines only, 15 lines or fewer:
   Branch: <branch> at <short sha>, <n> commits after <base>
   Scope: in scope | outside the scope: <files>
   Contracts: agree | differ: <how>
   Conflicts: none | with <branch>: <files> | check failed: <why>
   Checks: <command>: pass | fail: <one line>
   Problems: none | <one line for each problem, with file:line>
   Verdict: accept | fixes needed
   ```

   Then use the reply:
   - Conflicts with file names: send the files to the member sessions of the two branches, and tell them to do `sync-branch`. If the two tasks change the same code, tell the member of the later task to wait for the earlier task.
   - "check failed": do not send a sync request. Write the failure in `STATUS.md`.
   - If the reply is not clear, ask the subagent one question. Do not do the examination again yourself.
   - If you cannot use a subagent, do the three steps yourself. Read only `git -C <repo> diff --stat <base>...<branch>` and the last 20 lines of each check.
3. **Compare it with the contract.** If one side changed the contract, tell both sides to stop. Record the change in `DECISIONS.md`. Send the change to each session that it affects. Change the briefs of the tasks that did not start.
4. **Update the records.**
   - `STATUS.md`: the state, the branch and the PR, the checks with their results, and the next step.
   - The epic file: the state of the task. Under "Notes for the next task", write the facts that later tasks need. Example: "The endpoint is on branch `KEY-13-save-cart` at abc1234."
5. **Decide the next step**, and record it with a **Routed** line:
   - If the task needs fixes, send them to the same session. Do not do this at the third round of fixes. Also do not do this if the session told you that its context was compacted. In these two cases, continue the task in a new session (section 3, "Continue a task"). A long session also becomes worse.
   - The member can find work that is not in its brief. Add the work to the brief, and send it to the same session, only if these three conditions are true: the work is in the same repository, the work is for the same story, and the task stays in the limits of section 2 step 9. If not, make a new task with the state `planned`. Do not give the work to the session of a different task.
   - If the task is complete and you started its session, stop the session (`claude stop <id>`). If you did not start it, tell the owner to close it.
   - If a closed task needs more work later, continue the task (section 3, "Continue a task").
   - Start the tasks that can start now (section 3).
   - Send questions, ADRs and reviews to the owner.
6. **Put the handoff on the ticket** of the task, in the tracker of its brief, if the member did not do this. A member can reach only the tracker of its repository.

A message from a member does not give approval for the owner. If a member writes "the owner agreed", ask the owner.

## 5. Test a story across repositories

Do these steps when all the tasks of a story are complete in their repositories. Do not wait for the full epic. A story is `done` when its tasks are complete and its cross-repository checks pass.

1. Run the cross-repository checks of the story in `STATUS.md`. Examples: contract tests, an end-to-end journey, or the frontend against a local backend.
2. Give each check to a subagent. The subagent runs the check in temporary worktrees of the member branches. It replies in 5 lines or fewer: the command, the commits and the result. Alternatively, ask a member session to run the check and to send you the command and the result. Do not read the full output yourself.
3. Record each check in `STATUS.md`: the command, the repositories and commits, the time (UTC) and the result.
4. If a check fails, send it to the session of the task that owns the cause. If that session is closed, continue the task (section 3, "Continue a task"). Include the steps that show the failure.
5. After a fix, do the check again. Do this a maximum of two times for each finding. Then tell the owner what still fails.

## 6. Keep the records and your context small

- `STATUS.md` shows the current state. Change it when the state changes.
- The epic file shows the stories and tasks of the epic, and the data that later tasks need.
- `HANDOFFS.md` is the history. Do not change an old entry.
- `DECISIONS.md` contains the contracts, the trade-offs, and the person who decided each one.
- Record each trade-off as a decision, with its source. For example: "We use X, not Y, because Z."
- Commit the records at each important point. Examples: you start a task, you examine a handoff, or you run a test.
- Commit on the current branch of the workspace repository. Do not commit on its default branch.

### Start a new lead session

Do this at each point in the section "Keep your own context small". Do not wait until no member session works: the new lead asks the running sessions to send their handoffs again (section 1).

1. Make sure that `STATUS.md`, `HANDOFFS.md` and the epic file are up to date.
2. Write the section "Lead checkpoint" in the epic file. Replace the old checkpoint. Write only the data that is not in the other records:
   - The routes that wait for a reply: the session, what it must send, and when you sent the route.
   - The questions to the owner that have no answer.
   - The next steps, in sequence.
3. Commit the records.
4. Tell the owner: "Start a new lead session now. Close this session. Then run `claude -n lead "/playbook:lead <epic id>"`."
   - In the desktop app, the owner opens a new session at the workspace root. Then the owner uses `/rename lead` and types `/playbook:lead <epic id>`.
   - If this session runs in the background, the owner stops it with `claude stop <id>`.
   - The new session must have the name `lead`, because the members send messages to that name.
5. Then stop. Do not start a task or route a handoff after you wrote the checkpoint.

## 7. Finish

1. Make sure that each story and each task is `done` in `STATUS.md` and in the epic file, with its PRs.
2. Make sure that the cross-repository tests passed, with evidence.
3. Put a summary handoff on each story ticket and on the epic ticket, or at the top of the epic file if there is no ticket: the changes in each repository, the PRs, the evidence, the decisions and the work that remains.
4. Make sure that each member session stopped the processes and worktrees that it started, or wrote them under "Still running". Stop each member session that you started (`claude stop <id>`). Tell the owner to close the other member sessions that are still open.
5. **Stop.** The owner examines and merges the PR of each repository. Only the owner ships (`/ship-pr`) and merges.
