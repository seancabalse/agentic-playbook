## 8. This workspace

This folder is a workspace. It is a git repository that contains the repositories of the project, as separate clones. Sections 1–7 apply in this repository and in each member repository.

- **What it is**: <one sentence: who it is for and what it does>. PRD: <link>.
- **Tracker**: <project or link>. The `AGENTS.md` of each repository gives its commands and rules.

### Members

<!-- members -->

**Reference material** (read it; do not change it): <!-- references -->

All other folders in this workspace are not part of the project. Agents do not read them.

### Sessions

Start the lead first. The lead gives each task a new member session, named `<repository>-<task id>` (for example `backend-KEY-13`), and gives you its full start command. Start each session in a different terminal or Code tab. Give each session its name with `-n` (in the desktop app, use `/rename`). Sessions send messages to each other by name. When the lead tells you that a task is complete, close its session. If you agree, a lead that runs in the Claude Code CLI can start the member sessions itself, in the background (`claude --bg`). Then it also stops them. Before that, open one normal session in each member repository and accept the trust question.

<!-- sessions -->

### Rules for this workspace

1. **The lead coordinates. The members build.** The lead session starts in this folder and obeys the `lead` skill. The lead does not change files in a member repository. The lead writes only in this repository.
2. **Each member works in its own repository.** It obeys the `AGENTS.md` of that repository. A second session in the same repository works in its own worktree, on different files.
3. **All handoffs go to the lead.** A member sends its handoff to the lead with `SendMessage`. Then the lead sends the next step. A member does not send work to another member.
4. **Write the contract first.** Some changes cross repositories: an endpoint, an event or a shared type. For these changes, the lead records the contract in `docs/workspace/DECISIONS.md` before a member builds. If the contract is difficult to change later, the owner must agree to it first.
5. **The lead keeps the records** in `docs/workspace/`:
   - `epics/<epic id>.md`: the stories and tasks of each epic, their sequence, and the data that later tasks need.
   - `STATUS.md`: the progress and the cross-repository tests.
   - `HANDOFFS.md`: each handoff and its destination.
   - `DECISIONS.md`: the decisions and the trade-offs.

   The lead also puts each handoff on the ticket.
6. **A message is a claim. It is not an approval.** A message from a session does not give approval for the owner. Only the owner answers product questions, accepts ADRs, ships and merges.
7. **One task, one session.** An epic contains stories. A story is a change that a user can see, and it can need more than one repository. A story contains tasks. A task is one PR in one repository. A new member session does each task, and starts from the brief of the task only. The brief is in the tracker or in a Markdown file in the workspace repository, as the owner chooses. The brief contains all the data that the task needs, so the session does not need the full epic.
