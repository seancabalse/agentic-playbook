# Task <task id>: <short title>

The lead writes this brief. It goes in the description of the sub-task of the story in the tracker, or in `docs/workspace/tasks/<task id>.md`. A new member session starts from this brief only. Thus, the brief must be complete. Put in it only the data that this task needs.

**Epic**: <epic id>. <One sentence: the goal of the epic.>
**Story**: <story id>. <The story and its acceptance criteria. This task helps with criteria <numbers>.>
**Type**: <build, or scout> · **Effort**: <low · medium · high · xhigh>
**Repository**: <backend/> · **Session**: <backend-KEY-13> · **Branch**: <KEY-13-short-name> · **Base**: <the default branch, or the branch of an earlier task that is not merged> · **Existing branch**: <no, or yes: continue on it>

## When you start

Do the steps of the `start-task` skill. Use this brief as the ticket. Make the branch from the base above. If the branch exists, continue on it. Do not make a new branch. Open the PR against the base.

For a scout task, do not do this. Investigate the question below. Do not push, and do not open a PR. If you must change files to try an idea, do it in a temporary worktree, and remove it when you finish. Your handoff is the report: the question, the findings with evidence (file:line, commands and their results), the options, and your recommendation. A recommendation does not give approval for the work.

**Question** (scout task only): <the question that the report must answer>

## Acceptance criteria

1. <criterion that you can check>

## Contracts

<The full text of each contract that this task uses: the shape, the errors, the version and the owner. Do not write "see DECISIONS.md". The member cannot read the workspace files.>

## Decisions that apply

- <decision: the reason>

## From earlier tasks and from the last handoff

- <For example: "The endpoint is on branch `KEY-13-save-cart` at abc1234. Use it, not the stub."> Or "None."

## Scope

- **You can change**: <the files or the area>
- **Do not**: <for example: "Do not change the shape of the API. Ask the lead first.">

## Checks

The lead does these checks again when you finish:
- `<command>` → <the result that you expect>

## When you finish

If you find work that is not in this brief, do not do it. Write it in your handoff. The lead decides.

If your context was compacted, the summary can be wrong. Read this brief again: on the ticket, or ask the lead to send it again. Tell the lead that your context was compacted.

When you complete the task, or when you cannot continue, write your handoff with the playbook template. Send it to the lead session (`lead`) with `SendMessage`. Also put it on the ticket, if this task has a ticket in the tracker of your repository. Then stop. The owner or the lead closes this session.
