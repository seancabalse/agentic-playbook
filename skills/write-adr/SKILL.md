---
name: write-adr
description: "Write an architecture decision record for a choice that is hard to reverse. Use when you choose a stack, a vendor, a data model or a protocol."
argument-hint: "[the decision to make]"
---

# Write an ADR

> Playbook files named here: when the project has its own copy at `.playbook/local/<same path>`, use that copy instead.

Decision: $ARGUMENTS

1. **Check it needs an ADR** (`${CLAUDE_PLUGIN_ROOT}/principles/03-adrs-and-decisions.md`). If it's easy to reverse, log it in the Decision Log instead (`log-decision`).
2. **Read what exists**: `docs/adr/` (the next number, related ADRs, ones this supersedes), the Decision Log, and the PRD requirements involved.
3. **Gather the forces**: requirements with ids, constraints (platform, budget and free tiers, team, compliance), and what's already decided.
4. **Find at least two real options.** For each, check the current docs and versions (not memory): maturity, adoption, licence, cost, lock-in, and fit with the stack. If the answer depends on numbers you don't have (performance, memory, cost), propose a **time-boxed spike** with what it will measure, and stop there.
5. **Ask the owner** when the choice is a product or business trade-off: present the options with your recommendation first. Technical choices with a clear winner: recommend, and let the owner confirm in review.
6. **Write `docs/adr/NNNN-kebab-title.md`** from `${CLAUDE_PLUGIN_ROOT}/templates/adr.md`. Status is Proposed until the owner accepts it; then Accepted with the date and who decided.
7. **Follow through**:
   - Add a row to the Decision Log pointing to the ADR.
   - Add the rules it implies to `AGENTS.md`.
   - File tickets for the "now we must" consequences.
   - When superseding, mark the old ADR *Superseded by NNNN* without changing its body.
