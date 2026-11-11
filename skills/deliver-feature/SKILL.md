---
name: deliver-feature
description: "Deliver a ticket from start to end with the agents: brief, plan, build, verification, reviews, fixes and docs. It stops before shipping. Run only when the user asks."
argument-hint: "[ticket id]"
disable-model-invocation: true
---

# Deliver a feature with handoffs

> Playbook files named here: when the project has its own copy at `.playbook/local/<same path>`, use that copy instead.

Ticket: $ARGUMENTS

You are the **orchestrator**, the tech lead. You plan, delegate, review and verify. The **product-engineer** agent writes the code, one writer at a time; you only write small changes yourself. Every agent returns a handoff (`${CLAUDE_PLUGIN_ROOT}/templates/handoff.md`), and you check its key claims before acting on it. Rules: `${CLAUDE_PLUGIN_ROOT}/principles/15-agent-collaboration.md`.

## 1. Plan (gate: owner)

If the request isn't clear enough to plan (goal, users, scope or acceptance criteria missing), delegate to the **product-owner** agent first. Ask the owner its blocking questions, run it again with the answers, and repeat until it returns a brief ready to agree; the owner agrees it, and you post it on the ticket. Then follow `start-task`. Post the plan and assumptions on the ticket. If there are product questions, **ask and stop** until the owner answers. Move the ticket to the tracker's in-progress status.

## 2. Design (only for structural work: new tables, flows, vendors, sync)

Delegate to the **architect** agent with the ticket, the plan and the relevant code paths. If its handoff says an ADR is needed, write it (`write-adr`), then **ask the owner to accept it and stop** until they do.

## 3. Build

Delegate to the **product-engineer** agent. Give it:
- the ticket and acceptance criteria;
- the owner's decisions;
- the plan with its checks;
- the architect's design, if there was one;
- the files and area it may change.

It follows `implement` (preloaded) and works in **its own worktree** (`isolation: worktree`), on a branch from your feature branch. Its handoff names the worktree path and branch.

- **If it returns blocked** with a product question, ask the owner, then send the answer back (continue the same agent if your tool allows, or start a new run with its handoff).
- **When it returns done**:
  - Read the **whole diff** yourself, in its worktree (`git -C <path> diff <feature-branch>...HEAD`).
  - Run the full check suite yourself, in the worktree. Its "passed" is a claim, not proof.
  - Check the diff against the plan and the scope.
  - Then bring it into the feature branch (merge or cherry-pick its commits) and remove the worktree. Don't push until the owner ships.
- **For a change of a few lines**, build it yourself following `implement`, rather than delegating.
- **Independent slices** (no shared files) may go to separate product-engineer runs, each in its own worktree. Otherwise run them one after another.

## 4. Verify

Delegate to the **qa-verifier** agent with:
- the acceptance criteria;
- which states and settings matter;
- the screenshot matrix (`capture-screenshots`);
- the runbook's launch steps.

Read its handoff, and re-check one key claim yourself (for example, open one screenshot).

## 5. Review, in parallel, read-only

Start these together, each with the diff (`git diff <base>...HEAD`), the ticket and the qa handoff:
- **code-reviewer**: always.
- **security-auditor**: when auth, data access, files, payments or personal data changed.
- **design-reviewer**: when UI changed; pass it the screenshot paths.

## 6. Fix (at most 2 loops)

Decide each finding first (principle 13, "Fix now, or ask the owner"): ask the owner about the ones that would widen the scope. Send the other **confirmed** findings (and the plausible ones you've checked) to the **product-engineer**, with the reviewers' scenarios and any failing tests they wrote in their worktrees. It fixes them in a fresh worktree from the feature branch. When it returns, re-read the diff, re-run the full checks, then have **qa-verifier** re-check only what changed. After two loops, stop and report what's left instead of looping.

## 7. Docs

Delegate to the **docs-keeper** agent with the diff, the decisions made and the handoffs. Check its list of updated docs.

## 8. Stop for the owner

Post a summary handoff on the ticket. It covers:
- what was built;
- the evidence: checks, screenshots, the review results;
- what wasn't verified;
- the decisions made;
- what's next.

Make sure nothing is left running. Then tell the owner it's ready, and that `/ship-pr` opens the PR. **Don't commit, push or open the PR yourself** unless the owner says so in this conversation.
