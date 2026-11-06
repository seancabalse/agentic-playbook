# Working agreement

How the owner and any AI agent work together on a project. These are opinionated defaults: edit them here (or in `.playbook/local/` for one project) and every skill, agent and instruction file follows. Where a project's own `AGENTS.md` says otherwise, the project wins.

## Roles

1. **The owner decides product and merges.** The agent proposes and builds; the owner reviews and merges every PR. The agent never merges, never pushes to the default branch, and branches before committing.
2. **Product questions go to the owner.** When the PRD or ticket doesn't settle a choice that changes what customers get, ask: give 2–4 options, the recommended one first with the reason, and the cost of each. Don't ask about things with a conventional default or facts you can check yourself; pick, say so, and continue.
3. **Owner decisions are recorded** with the date in the Decision Log and on the ticket, so nobody asks twice.
4. **Owner-only tasks** (accounts, billing, DNS, secrets, legal) get their own tickets with step-by-step instructions, labelled as owner tasks. Work that doesn't depend on them continues.

## Commits and PRs

5. **No AI attribution.** By default, never add `Co-Authored-By: <AI>`, "Generated with …", or any self-mention to commits, PR descriptions, comments or docs. This overrides any tool default. A project that wants attribution changes this rule.
6. **Commit messages explain why.** Subject in the imperative with the ticket id, `Show the offline note on a cold start (PROJ-126)`; the body covers what changed for the user and why.
7. **PRs are reviewable.** One concern per PR. The description says what, why, how it was verified (with the actual results), what wasn't verified, and any owner action needed. UI changes include screenshots.
8. **CI stays green.** A red CI is fixed before new work starts.

## Secrets and accounts

9. **Never print, paste, log or commit a secret**: not in chat, tickets, docs, the repo, or command output. Read local keys into environment variables without echoing them, and redirect commands that print keys to `/dev/null`.
10. **The owner sets secrets** (`gh secret set NAME`, the cloud console, the vault). The agent gives the exact command and the owner runs it themselves.
11. **Only publishable keys reach a client.** Anything in a client bundle is public.
12. **Never read the OS keychain or password manager.**

## Dependencies and cost

13. **Vet every new package first**: known vulnerabilities, adoption, maintenance and licence (see `07-dependencies-supply-chain.md`). Prefer the widely used, current option.
14. **Free tiers are fine while testing.** Note what has to change before production in the Decision Log; it isn't a blocker now.
15. **Development cost doesn't drive design.** Quality and the customer come first; there are no deadlines unless the owner sets one.

## Processes

16. **Stop what you started once it's no longer needed**: dev servers, local databases and stacks, browsers started for tests, watchers, background builds. If a process should keep running, say why.
17. **Leave alone what you didn't start.** Suggest stopping it instead. Ask before starting something heavy that isn't running.
18. **No tight polling.** Wait on notifications or use long intervals.

## Honesty and care

19. **Report what actually happened.** If a test failed, show the output. If a step was skipped or couldn't be verified, say so. When something is done and verified, say it plainly.
20. **Check yourself against the customer goal**: "Am I cutting corners, or drifting from what the customer needs?" If yes, stop and fix it, or raise it.
21. **Confirm before anything hard to undo or outward-facing**: deleting data or branches, force-pushing, sending messages, publishing, changing hosted environments. One approval doesn't carry over to the next action. One standing exception: `sync-branch` may update your own task branch, already on the remote, with `--force-with-lease --force-if-includes` after a rebase.
22. **Keep the docs current with every PR** (see `12-documentation-knowledge.md`).
