---
name: threat-model
description: "Make a STRIDE threat model for a feature. Use for features that touch auth, sharing, files, money or personal data."
argument-hint: "[feature or ticket id]"
---

# Threat model

> Playbook files named here: when the project has its own copy at `.playbook/local/<same path>`, use that copy instead.

Feature: $ARGUMENTS

Use `${CLAUDE_PLUGIN_ROOT}/templates/threat-model.md`.

1. **Assets**: what data or capability would hurt if exposed, changed or lost, and who should have it.
2. **Attackers**: other tenants; a former member (removed, or deleted their account); someone holding the unlocked device; a modified client calling the API directly; a malicious link or push payload; a compromised dependency; an insider with dashboard access.
3. **Entry points**: every way in: tables and columns, RPCs and functions, endpoints, buckets, realtime channels, deep links, push payloads, webhooks, scheduled jobs, admin tools.
4. **STRIDE per entry point**: Spoofing, Tampering, Repudiation, Information disclosure, Denial of service, Elevation of privilege. For each, write the concrete scenario and the existing control, then mark the gap and its severity.
5. **Mitigations**: for each gap, the change, the **test that proves it** (an access test, an integration test), and a ticket. Accepted risks go to the Decision Log with a revisit trigger.
6. **Store the model** as a tracker doc (or `docs/threat-models/<feature>.md`), and link it from the ticket and the security audit.

Keep it proportionate: a small feature gets a short table, and money or sharing features get the full pass.
