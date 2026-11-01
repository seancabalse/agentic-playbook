---
name: refine-requirements
description: "Clarify a vague request with the owner, round by round, and write a requirements brief in ASD-STE100. Use before you plan a new or unclear request."
argument-hint: "[the request, ticket id or idea]"
---

# Refine the requirements

> Playbook files named here: when the project has its own copy at `.playbook/local/<same path>`, use that copy instead.

Request: $ARGUMENTS

You are the product owner, the project owner and the project manager for this request. Write all your text in ASD-STE100: your questions, your summaries and the brief. The rules are in `${CLAUDE_PLUGIN_ROOT}/principles/16-simplified-technical-english.md`.

## 1. Read before you ask

1. Read the request and the ticket, if there is one. Read the comments too.
2. Read the project's `AGENTS.md`, the PRD, the Decision Log and the Architecture doc (see the "Tracker" section for where they are).
3. Read the code and the screens that the request touches. Find what exists now.
4. Do not ask a question that these sources answer. Write the answer down, with the source.

## 2. Bring the domain knowledge

1. Identify the domain of the product and of the request (for example: payments, health, education, logistics, bookings).
2. Write the rules, laws, conventions and normal practice of that domain that apply. Examples: the users' normal expectations, legal requirements for data, normal steps of a business process, and terms the users know.
3. Mark each item as a **fact** (with the source) or an **assumption**. The owner must confirm each assumption.
4. Use the domain knowledge to find what the request does not say. A request for "invoices" includes taxes, numbering, refunds and currencies, even when the request does not say so.

## 3. Find the gaps

Make a list of what you do not know. Use these topics:

| Topic | Questions to answer |
| -- | -- |
| Goal | What problem do the users have? What is the result for them? How will we know that it works? |
| Users | Who uses it? Who else is affected (the other person, an admin, a support person)? What do they know already? |
| Scope | What is in this work? What is not in this work? What is the smallest useful version? |
| Behaviour | What does the user do, step by step? What does the product show at each step? |
| Unhappy paths | What happens when there is no connection, an error, no data, a limit, or a second user who does the same thing? |
| Data | What data does the product keep? Who can see it? For how long? Can the user delete it or export it? |
| Quality | Accessibility, performance, security, privacy, languages, time zones, platforms. |
| Constraints | Accounts, money, laws, dates, other teams, other tickets. |
| Priority | What is most important? What can wait? |

## 4. Ask the owner, round by round

1. Rank the gaps. A **blocking** gap stops the work: the design or the build is different for each answer. A **non-blocking** gap does not stop the work.
2. Ask the blocking questions first. Ask one to four questions in each round. Use the question tool when you have it.
3. For each question, give two to four options. Put the option that you recommend first, and say why. Give the effect of each option on the users, the scope and the risk.
4. Do not ask about a thing that you can decide with a normal default. Decide it, and write it as an assumption in the brief.
5. Write each answer in the brief immediately, with the date.
6. After each round, find the new gaps that the answers make. Then ask the next round.
7. Stop when no blocking question is open. Write the non-blocking questions in "Open questions".
8. Do not invent an answer. If the owner does not know, write the question as open and recommend a way to find the answer (a spike, a test with users, an expert).

## 5. Write the brief

1. Use `${CLAUDE_PLUGIN_ROOT}/templates/requirements-brief.md`.
2. Give each requirement an id (R1, R2…) and each acceptance criterion an id (A1, A2…) that names its requirement.
3. Each acceptance criterion has a check that a person or a test can do.
4. Check the text against the STE rules: sentence length, active voice, no "-ing" forms, one word for one thing.

## 6. Agree and record

1. Show the brief to the owner. Ask: "Is this brief correct and complete?"
2. When the owner agrees, set the status to "Agreed" with the date.
3. Put the brief on the ticket, or in the tracker's document space, as the "Tracker" section says. Link it from the ticket.
4. Record each decision with the `log-decision` skill.
5. Give the next step: `start-task` for the plan, the `architect` agent for structural work, or a split into smaller tickets.

Do not plan the build or write code in this skill.
