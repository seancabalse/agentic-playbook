---
name: security-audit
description: "Audit a change or the project for security and privacy, and prove each finding. Use for auth, data, file and payment changes, and before a release."
argument-hint: "[PR, feature, or 'project']"
---

# Security audit

> Playbook files named here: when the project has its own copy at `.playbook/local/<same path>`, use that copy instead.

Scope: $ARGUMENTS

Principles: `${CLAUDE_PLUGIN_ROOT}/principles/06-security-privacy.md`. Report shape: `${CLAUDE_PLUGIN_ROOT}/templates/audit-report.md`. For a new feature with no threat model yet, run `threat-model` first.

## Check

1. **Secrets**: none in the code, history, logs, fixtures or client bundles (grep for key patterns, `.env` committed by mistake, service keys in client config); only publishable keys client-side; CI secrets scoped.
2. **Access control**: every table, view, function, bucket and endpoint is deny by default. Policies check tenant membership. `security definer` functions check the caller and pin `search_path`. Column secrets are revoked and exposed only through checked functions. Realtime publications use column lists. "Who may do what" (author-only delete) is enforced on the server. There are tests for can **and** can't.
3. **Input**: server-side validation of types, sizes and enums; capped JSON and text; parameterised queries; no injection paths in raw SQL, shell or HTML; uploads checked for type and size.
4. **Auth and sessions**: codes or platform sign-in; rate limits on sign-in, invite and join; offline isn't treated as signed out; sign-out clears queued writes, caches and push tokens; tokens are stored where scripts can't read them (`HttpOnly` cookies, or secure storage); deep links validate their parameters.
5. **Privacy**: no content in logs, analytics, crash reports or notification text; metadata stripped from uploads; coarse location only; unused permissions blocked; export and deletion work; retention jobs run.
6. **Files**: private buckets, per-tenant prefixes, signed URLs with short expiry, no overwrites, orphans swept.
7. **Abuse**: rate limits with codes; quotas; idempotency, so replays don't duplicate; webhook signatures verified.
8. **Dependencies and config**: advisories in the lockfile; security headers (web); debug flags off in release; cleartext traffic off; CORS allow-list.

## Method

- Read the diff or the code paths; grep for risky patterns (`select *` on secret tables, `security definer`, `dangerouslySetInnerHTML`, `eval`, string-built SQL, `console.log(` near user data).
- Prove findings: write a failing access test or show the exact request. If you can't prove it, mark it **plausible** with the reasoning.
- Never print a secret you find. Report its location and tell the owner to rotate it.

## Output

Findings ranked Critical / High / Medium / Low, each with the exploit scenario (who, what request, what they get), evidence (file:line, test), and the fix. Add a "Checked and fine" section. Offer to file tickets; for project audits, write the dated audit doc.
