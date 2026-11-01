---
name: log-decision
description: "Record a decision or an accepted risk in the decision log. Use when the owner or the team makes a decision."
argument-hint: "[the decision]"
---

# Log a decision

> Playbook files named here: when the project has its own copy at `.playbook/local/<same path>`, use that copy instead.

Decision: $ARGUMENTS

1. **Classify it**:
   - **Product**: what customers get; the owner decided.
   - **Technical**: how it's built.
   - **Process**: how we work.
   - **Accepted risk**: a known issue we're living with.
   - Hard to reverse? Use `write-adr` instead and log a pointer.
2. **Write the row** at the **top** of the right section (`${CLAUDE_PLUGIN_ROOT}/templates/decision-log.md` shape):
   - Date (absolute, YYYY-MM-DD).
   - **Bold one-line summary**, then any detail. For product decisions, add "Owner decision".
   - **Why**: the constraint or evidence, not "preferred".
   - **Source**: the ticket, PR or question.
   - Accepted risks also get **revisit when**.
3. **If it reverses an earlier decision**, mark the old row *Superseded (YYYY-MM-DD)* with a pointer to the new one. Never delete it.
4. **If it implies a rule**, add one bullet to `AGENTS.md` in the right section.
5. **If it changes a ticket's scope**, update the ticket description and say so in a comment.

Edit the Decision Log where `AGENTS.md` → "Tracker" says it lives (a tracker document, a Confluence page, or `docs/decisions.md`), following that section's editing notes. Insert right after the section's table header row.
