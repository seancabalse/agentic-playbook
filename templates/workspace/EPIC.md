# Epic <epic id>: <short title>

The lead keeps this file at `docs/workspace/epics/<epic id>.md`. It is the memory of the lead for this epic. A new lead session reads it and continues. Write each fact that you need later in this file, not only in the conversation.

**Source**: <the ticket link, or the local file or list that the owner gave>
**Task briefs**: <the tracker, for example "Jira sub-tasks of each story"> or <the folder, for example `docs/workspace/tasks/`>. The owner chose this on <YYYY-MM-DD>.
**Sessions started by**: <the owner> or <the lead, in the background: a maximum of <N> at the same time>

## Goal

<Two or three sentences: who it is for and what it does.>

## Acceptance criteria

1. <criterion that you can check>

## Stories

A story is a change that a user can see. It is `done` when its tasks are complete and its cross-repository checks pass.

| Story | Summary and acceptance criteria | Cross-repository checks | State |
| -- | -- | -- | -- |
| <KEY-11 or E1-S1> | <customers can save a cart: criteria> | <the end-to-end journey> | planned · in progress · done |

## Tasks

A task is one PR in one repository. One new member session does one task. Put the tasks in sequence.

| Task | Story | Repository | Summary | Waits for | Brief | State |
| -- | -- | -- | -- | -- | -- | -- |
| <KEY-13 or E1-S1-T1> | <KEY-11> | <backend/> | <the endpoint POST /carts/{id}/save> | <none, or a task> | <ticket link or file path> | planned · in progress · in review · done |

## Contracts

The full text of each contract is in `docs/workspace/DECISIONS.md`. List them here with the tasks that use them.

- <D-3 `POST /carts/{id}/save`>: owned by <backend/>. Used by <the tasks>.

## Notes for the next task

<The facts that a later task needs from an earlier task. For example: "The endpoint is on branch `KEY-13-save-cart` at abc1234.">
