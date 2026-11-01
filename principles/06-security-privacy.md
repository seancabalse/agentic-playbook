# Security and privacy

Assume the client is hostile, the network is public, and every log will be read by someone it shouldn't be. Guidance follows OWASP ASVS, the OWASP Top 10 and the platforms' own rules.

## Secrets

1. **Secrets never leave their vault.** Never print, paste, log or commit them (`00-working-agreement.md` §9–12). `.env` files are gitignored and an `.env.example` lists the names only.
2. **Clients hold only publishable keys.** Anything bundled into an app or web page is public: service keys, signing keys and admin tokens stay server-side.
3. **Least privilege, per environment.** Deploy tokens are scoped to one project and one permission set, with separate credentials for dev and prod. Rotate on any suspicion, and log the rotation (not the value).
4. **Server-to-server calls carry their own key** (generated into the vault by a migration, sent in a header), not a user's session.

## Access control

5. **Deny by default, at the data layer.** Every table, bucket and endpoint starts closed. Access is granted by tenant membership (row-level security or equivalent) and covered by tests that prove both "can" and "can't" (`08-testing-qa.md`).
6. **Column-level secrets need extra care.** If one column must stay hidden (a message body), revoke it from direct selects and expose it through a function that checks access and records the read. Remember that replication and realtime don't respect column privileges: publish an explicit column list.
7. **Who may do what is enforced on the server** (author-only delete, admin-only billing changes): column grants plus triggers or policies, not just hidden buttons.
8. **Rate-limit what can be abused** (sign-in codes, invites, joins, pings) on the server, with a specific error code and a friendly client message.
9. **Validate on the server**: types, sizes (cap JSON and text columns), enums, cross-row invariants (same tenant, no duplicates) in constraints or triggers.

## Sessions and devices

10. **Sign-in that works everywhere.** Prefer one-time codes or platform sign-in to links that depend on deep-link handling.
11. **Offline isn't signed out.** An expired token that couldn't refresh offline keeps the session; only an explicit sign-out or a revoked session signs out.
12. **Sign-out clears the device**: queued writes, caches, push registration and pending invites, in that order, before the session goes.
13. **Data kept on the client is protected.** Session tokens live where scripts can't read them (`HttpOnly` cookies on the web, the OS keychain for installed apps). Private data cached on the client is encrypted, or not cached on shared devices.

## Privacy

14. **Collect the minimum.** Coarse location only, rounded coordinates, no background location, no contacts. Ask for a permission only when the feature needs it, and turn off what you don't use (`Permissions-Policy` on the web).
15. **Strip metadata** (EXIF, GPS) before upload.
16. **Private content never goes to logs, analytics, crash reports or notifications.** A notification says "Ana sent you a message", never the message. Analytics events carry names and counts, not content.
17. **Files are private** (private buckets, short-lived signed URLs). Nothing is public by default.
18. **People can leave.** Account deletion and data export are in the app; retention windows are documented and enforced by jobs.

## Process

19. **Threat-model each feature that touches auth, money, files, sharing or personal data** (`threat-model` skill): assets, actors, entry points, then STRIDE per entry point, then mitigations as tickets.
20. **Security review before merge** for those paths (`security-audit` skill, `security-auditor` agent), plus a full audit before each release.
21. **Dependencies are part of your attack surface** (`07-dependencies-supply-chain.md`).
22. **Publishing is irreversible.** Pasted code, logs or tokens on external services may be cached even if deleted. Treat "send to a third party" as a release.

## Mobile (iOS and Android)

- **Keys and sessions at rest** live in the platform keystore: the Keychain on iOS, the Keystore on Android (for example through `expo-secure-store`). A larger encrypted store keeps only its key there.
- **An optional app lock** (biometrics or the device passcode) hides the app-switcher preview while it's on (iOS: a cover while the app is inactive; Android 13+: `setRecentsScreenshotEnabled(false)`). It must survive the platform rebuilding the activity.
- **Permissions**: use the system photo picker (no storage permission) and coarse location only, and block every permission you don't use in the app config (for example `android.blockedPermissions` in Expo's `app.json`).
- **Push payloads** carry ids and generic wording, never private content: the lock screen is public. APNs keys and FCM credentials are owner-held secrets.
- **Deep links** are an entry point: validate every parameter. Prefer one-time codes to tappable magic links, because many mail apps don't open custom schemes.
