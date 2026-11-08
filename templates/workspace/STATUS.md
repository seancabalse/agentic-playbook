# Workspace status

The lead keeps this file. Update it when a handoff comes, when you start a task, and when a state changes. One row for each task. The stories and tasks of each epic, and their sequence, are in `epics/`. Each row shows the current state. The history is in `HANDOFFS.md`.

## Work

| Story | Task (ticket) | Repository | Session | State | Branch / PR | Checks (command → result) | Next |
| -- | -- | -- | -- | -- | -- | -- | -- |
| <KEY-11> | <KEY-13 short title> | <backend/> | <backend-KEY-13 (id 5609a6cc if the lead started it), or "closed"> | planned · in progress · in review · blocked (<why>) · done | <branch> / <PR link> | <`npm test` → 42 passed> | <who does what> |

## Cross-repository tests

These checks use more than one repository. Examples: contract tests, end-to-end journeys, and the frontend against a local backend.

| Story | Check (command or scenario) | Repositories | Last run (UTC) | Result |
| -- | -- | -- | -- | -- |

## Open decisions

The questions that only the owner can answer. A decision is closed only when the owner answers. Then the lead records it in `DECISIONS.md`.

| Id | Question | Options (recommended first) | Asked (UTC) | Answer, by whom, when |
| -- | -- | -- | -- | -- |
| <Q1> | <Accept the stack ADR of backend/?> | <accept · change> | <YYYY-MM-DD HH:MM> | <open, or: "accept", owner, YYYY-MM-DD HH:MM> |
