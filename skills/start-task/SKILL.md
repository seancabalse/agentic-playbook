---
name: start-task
description: "Start a task: read the context, state the assumptions, ask product questions and write a plan with a check for each step. Use at the start of each task."
argument-hint: "[ticket id or short description]"
---

# Start a task

> Playbook files named here: when the project has its own copy at `.playbook/local/<same path>`, use that copy instead.

Task: $ARGUMENTS

## 1. Gather context (read before deciding anything)

1. **The ticket**, from the project's tracker (Linear, Jira, GitHub Issues, …), using the access and conventions in `AGENTS.md` → "Tracker": description, acceptance criteria, comments, linked tickets, and the requirement ids it serves. If there's no ticket, restate the request as acceptance criteria.
2. **The rules**: `AGENTS.md` (already loaded) and the sections relevant to this area. Read the Decision Log entries and ADRs that touch it, and the runbook traps for the tools you'll use.
3. **The code** that will change, and its tests. Find the existing pattern for this kind of change and follow it.
4. **Current docs for any API you'll use**, for the installed version (`${CLAUDE_PLUGIN_ROOT}/principles/01-engineering.md` §6). Don't rely on memory for fast-moving frameworks.

## 2. Think before coding

- List your **assumptions** explicitly.
- If the request has **several readings**, list them.
- If there's a **simpler approach** than the ticket implies, say so.
- If the request is **vague, large or new** (no clear goal, users, scope or acceptance criteria), run `refine-requirements` first, or delegate to the `product-owner` agent and relay its questions. Then continue from its agreed brief.
- Identify **product decisions** the PRD or ticket doesn't settle. Ask them now, in one batch: 2–4 options each, the recommended one first with its reason and trade-offs in customer terms. Don't ask about conventional defaults or facts you can check; choose those and say so.
- Check for **owner-only steps** (accounts, secrets, DNS). If one blocks the task, say what it is and plan the work around it.

## 3. Plan

Write a short plan where each step has a check:

```
1. <step> → verify: <test / command / observation>
2. …
N. Verify in the real app → verify: <acceptance criteria walked, screenshots>
```

Include data (migration, policies, tests, generated types), UI states (loading, error, offline, empty), copy in the catalogue, accessibility at the largest text size, docs to update, and whether a new build or deploy step is needed.

## 4. Start

- Move the ticket to the tracker's in-progress status (the mapping is in `AGENTS.md` → "Tracker"), and create a branch named from the ticket off the up-to-date default branch.
- Then build it with `implement` (or delegate to the `product-engineer` agent), smallest verifiable step first. When a step's check fails, fix it before moving on.

Rules: `${CLAUDE_PLUGIN_ROOT}/principles/00-working-agreement.md`, `01-engineering.md`, `14-product-and-planning.md`.
