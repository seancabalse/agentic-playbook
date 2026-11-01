---
name: docs-upkeep
description: "Update AGENTS.md, the decision log, the architecture doc and the runbook after a change. Use at the end of each task."
---

# Docs upkeep

> Playbook files named here: when the project has its own copy at `.playbook/local/<same path>`, use that copy instead.

Look at the diff and the conversation, then update each doc that's affected. Skip a doc only when nothing in it changed.

| If the change… | Update |
| -- | -- |
| Adds or changes a rule someone must follow when coding (a convention, a helper to use, a "never do X") | **`AGENTS.md`**: one bullet in the right section, with the code path. Keep it operational, with no history. |
| Involved a decision (product from the owner, technical, process, an accepted risk) | **Decision Log**: a row at the top of the right section: date, **bold summary**, why, source. Name the owner for product decisions. |
| Adds or changes a table, column, flow, job, function or integration | **Architecture & Data Model**: the schema line, a flow diagram (text), "built" with ticket and PR |
| Hit a trap (a tool behaved surprisingly, a command needed a flag, something cost over 10 minutes) | **Developer Runbook**: a "Traps already hit" row (trap → fix with commands), or a new how-to section |
| Changes setup, env vars or commands | **README** and the runbook's local loop |
| Is a hard-to-reverse choice | **ADR** via `write-adr` |
| Completes or advances a ticket | **Ticket**: status, PR link, and a comment with what was done, the verification, and anything not verified |

## How

- **Where the docs live and how to edit them safely** is in `AGENTS.md` → "Tracker": Linear documents, Confluence pages, `docs/` in the repo, Notion, …. Follow its editing notes, such as anchors without ticket ids in Linear, or the page version number in Confluence. Patch small sections instead of rewriting whole documents.
- **Repo docs** change in the same commit as the code.
- **Plain language**, concrete names, links to code paths, tickets and PRs. One home per fact: link, don't copy.

Report which docs you updated and which you checked and left unchanged.

Rules: `${CLAUDE_PLUGIN_ROOT}/principles/12-documentation-knowledge.md`.
