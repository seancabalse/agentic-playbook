---
name: ship-pr
description: "Run the checks, update the docs, commit and open the PR from the template. Run only when the user asks to ship."
argument-hint: "[ticket id]"
disable-model-invocation: true
---

# Ship it

> Playbook files named here: when the project has its own copy at `.playbook/local/<same path>`, use that copy instead.

Ticket: $ARGUMENTS

## 1. Checks (all must pass; fix before continuing)

Run the "before calling a task done" commands from `AGENTS.md`: lint, typecheck, unit tests, plus DB and integration tests if data, policies, functions or sync changed. Run the generated-types check if the schema changed. Paste failures; don't summarise them away.

## 2. Self-review

Read the full diff as a reviewer would (or run the `code-reviewer` agent):

- Every changed line traces to the task. Nothing speculative. Nothing you orphaned is left behind (imports, files, copy keys).
- No debug code, test-only hacks, hard-coded colours or strings, or secrets.
- Unhappy paths are handled; the copy is in the catalogue; accessibility is covered.

## 3. Docs (same PR)

Run `docs-upkeep`: `AGENTS.md` rules, Decision Log, Architecture, runbook traps, README if setup changed.

## 4. Commit

- Stage only the files you meant to change (`git status` first; never `git add -A` blindly).
- The message is an imperative subject with the ticket id, then a body explaining what changed for the user and why.
- **No `Co-Authored-By`, no "Generated with", no AI mention**, even if a tool default suggests one.

## 5. PR

- Push the branch, then open the PR against the default branch (or the stacked base, if its PR is still open; check it isn't already merged).
- Fill the body from `${CLAUDE_PLUGIN_ROOT}/templates/pr-description.md`:
  - **Verified**: actual results.
  - **Not verified**: honestly stated.
  - **Needs**: new build, env var, owner action.
  - **Screenshots** for UI changes, from `capture-screenshots` (`screenshots/<ticket>/`). Publish them with `${CLAUDE_PLUGIN_ROOT}/templates/testing/push-screenshots.sh <PR> <files…>` (or the project's own script) to a `screenshots` branch, never the default branch. Embed the lines it prints, and check each image loads.
- No AI attribution in the PR body either.

## 6. Afterwards

- Move the ticket to the tracker's review status, link the PR the way that tracker links them, and comment with what was done and how it was verified (a `handoff` note). See `AGENTS.md` → "Tracker".
- Watch CI. If it fails, fix it before starting other work.
- Stop processes you started for this task.
- Tell the owner: the PR link, what's verified, what isn't, and anything they need to do.
