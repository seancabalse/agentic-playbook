---
name: sync-branch
description: "Bring your task branch up to date with the team branch (main or dev): fetch, predict the conflicts, rebase, resolve the clear conflicts or stop, run the checks and update the pushed branch with --force-with-lease. Use at the start of a task, before each push, before a handoff, and when the playbook says that the branch is behind."
argument-hint: "[team branch, if not configured]"
---

# Sync the branch with the team branch

> Playbook files named here: when the project has its own copy at `.playbook/local/<same path>`, use that copy instead.

Team branch: $ARGUMENTS

The team branch is the branch that the team keeps up to date, for example `main` or `dev`. Other people push to it many times each day. If your branch stays old, the conflicts become larger. Thus, rebase your branch often, while the conflicts are small.

Rules:
- Rebase only your own task branch. Do not rebase the team branch. Do not rebase a branch that another person or session works on. Do not use `--update-refs`: it can move the branch of an earlier task.
- Do not push to the team branch.
- Push a rebased branch only with `--force-with-lease --force-if-includes`. Never use `--force` alone. The owner agreed to this force push for your own task branch only (working agreement, rule 21).
- Sync only at a clean point: all your changes are committed and the checks pass. Do not use `--autostash` or `git stash`: all the worktrees of a clone share one stash, so another session can take your changes.
- Do not discard work. Before you rebase, write down the commit of your branch, so that you can go back to it.

## 1. Find the base

1. Find the team branch:
   - Read it from the git configuration: `git config playbook.integrationBranch`.
   - If it is empty, use the branch in the request (`$ARGUMENTS`). If the request does not give one, use the default branch of the remote: `git symbolic-ref --short refs/remotes/origin/HEAD`. If that fails, use `main` or `master`, the one that is on the remote.
   - If you did not get the branch from the configuration, ask the owner one time: "The team branch is `<name>`. Is this correct?" Then save it: `git config playbook.integrationBranch <name>`. All the worktrees of this clone use this value. The playbook hook also uses it.
2. Find the base of your branch. Usually it is the team branch. If your brief or ticket says that your branch starts from the branch of an earlier task that is not merged, the base is that branch. Save it, so that the playbook hook compares with it: `git config branch.<your branch>.playbookBase <earlier branch>`.
3. If the base is the branch of an earlier task, and that task is now merged into the team branch, go to section 7.

## 2. Find the state

1. Get the new commits: `git fetch origin <team branch>`.
2. Find the state of your branch:
   - The branch: `git branch --show-current`. If it is the team branch, go to section 6.
   - The new commits: `git rev-list --count HEAD..<base>`. Use `origin/<team branch>` as `<base>` when the base is the team branch. If the number is 0, your branch is up to date. Stop.
   - Your changes that are not committed: `git status --short`.
   - Whether the branch is on the remote: `git ls-remote --exit-code --heads origin <your branch>`. Exit code 0 means that it is on the remote. Write down the result. You use it in section 5.
3. Predict the conflicts. This command does not change your files: `git merge-tree --write-tree --name-only --no-messages HEAD <base>`.
   - Exit code 0: no conflicts.
   - Exit code 1: the lines after the first line are the files with conflicts.
   - A different exit code: the prediction failed (for example, git is older than 2.38). Continue without a prediction.

## 3. Prepare

1. If you have changes that are not committed, continue your step until the checks pass, and commit. Then sync. If a conflict is predicted, do not change the files with the conflict before you sync.
2. Write down the commit of your branch: `git rev-parse HEAD`. You go back to it if the rebase fails.
3. Turn on the memory of conflict resolutions one time for each clone: `git config rerere.enabled true`. Then git repeats a resolution when the same conflict occurs again in a later rebase.

## 4. Rebase

1. Rebase:
   - The base is the team branch: `git rebase origin/<team branch>`.
   - The base is the branch of an earlier task: `git rebase --fork-point <earlier branch>`. The earlier task can rebase its branch too. Then your branch contains old copies of its commits. `--fork-point` replays only your own commits. If git cannot find the fork point, do the steps of section 7 step 1 to find the old end of the earlier task, and use `git rebase --onto <earlier branch> <old end>`.
2. If the rebase completes without conflicts, go to section 5.
3. If a conflict occurs, examine each file with a conflict:
   - Read your change and the change from the team. Find the commits from the team that changed the file: `git log --oneline HEAD..<base> -- <file>`. Read their messages.
   - If git says "Resolved '<file>' using previous resolution", git used a resolution from an earlier rebase. The file has no conflict markers. Read it and compare it with the two changes, as for a new conflict. If the resolution is wrong, run `git rerere forget <file>`, and resolve the conflict again.
   - **Resolve the conflict** only if all of these are true:
     - You understand the change from the team, and its purpose.
     - The resolution keeps the purpose of both changes.
     - The file is in the scope of your task.
   - To resolve: edit the file, remove the conflict markers, `git add <file>`, then `git rebase --continue`. Do not take one side of a full file (`--ours` or `--theirs`) without reading both sides.
   - **Stop** if a resolution needs a decision about the change of another person, or if the file is not in the scope of your task:
     1. `git rebase --abort`. Your branch is then as it was before.
     2. Report to the owner (in a workspace, to the lead): the files, the team commits (id, author and message), the two changes, and your recommendation. Then wait.

## 5. Check and push

1. Run the full check suite from `AGENTS.md` ("Before calling a task done"): lint, typecheck and tests. A rebase without conflicts can still break the code, because the team changed code that your change uses.
2. If a check fails because of a team change, fix it in a new commit. If the fix is not in the scope of your task, report it as in section 4 step 3.
3. If the checks fail and you cannot fix them, go back to the commit that you wrote down: `git reset --keep <commit>`. Then report. If a resolution was wrong, tell the next sync to check it: git can use it again (section 4 step 3).
4. Push only if the branch was on the remote before the sync (section 2). Then the remote branch (and its PR) stays the same as your branch: `git push --force-with-lease --force-if-includes origin <your branch>`. If git refuses, another person pushed to your branch. Do not push again. Report it.
   - Do not push a new branch here. `handoff` and `ship-pr` push a new branch when the owner says so.
5. Report in one line: "Rebased `<branch>` onto `<base>` at `<commit>`: `<n>` new commits, conflicts `<none / resolved in <files>>`, checks `<result>`, pushed `<yes/no>`." In a workspace, put this line in your next handoff.

## 6. The team branch in a checkout

If your checkout is on the team branch, do not rebase it, and do not commit on it.

- If `git status --short` shows no changes, update it: `git pull --ff-only`.
- If it shows changes, tell the owner. The owner decides.

## 7. The earlier task is merged

Your branch contains the commits of the earlier task. The team branch contains them as different commits (for example, after a squash merge). A normal rebase then gives conflicts in files of the earlier task. Do this instead:

1. Find the old end of the earlier task in your branch: `git merge-base --fork-point <earlier branch> HEAD`. If the output is empty (for example, the local branch of the earlier task does not exist), ask the owner or the lead for the last commit of the earlier task in your branch. Do not guess.
2. Do sections 2 to 5 with the team branch as the base. In section 4, rebase only your own commits: `git rebase --onto origin/<team branch> <old end of the earlier task>`.
3. Remove the saved base: `git config --unset branch.<your branch>.playbookBase`.

## When to sync

- At the start of a task, after you make or continue its branch.
- When the playbook says that your branch is behind its base, or that a rebase will conflict. Sync at the next point where your checks pass. If a conflict is predicted, go to that point first, and do not change the files with the conflict before you sync.
- Before each push, before a handoff and before a PR (`ship-pr`).
