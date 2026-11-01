# Testing and QA

Tests prove the code does what we think. QA proves the product does what the customer needs. Both are part of "done".

## What to test where

| Layer | What | How |
| -- | -- | -- |
| **Pure logic** | Rules, calculations, parsing, formatting, state machines | Unit tests next to the code (`thing.test.ts`), with no network or device. Inject the clock and clients. |
| **Date and time rules** | Anniversaries, countdowns, recurrence, zone conversions | **Property-based** tests across zones, DST changes and leap days |
| **Database rules** | Access policies, triggers, constraints, functions | Database-native tests (pgTAP or equivalent): every table has can/can't tests for each role |
| **Behaviour across services** | Policies seen through the real API, realtime, storage, jobs, functions | Integration tests against a **local stack** (Docker Compose, Testcontainers, or the vendor's local development stack) with real users. Never against live third-party APIs: seed caches or test the pure module. |
| **The product** | The feature as a customer uses it | Run the real app or service and walk the acceptance criteria (`verify-feature` skill) |

## Rules

1. **Tests live next to the code** and use the project's runner (Vitest, Jest, `node:test`).
2. **A bug fix starts with a failing test** that reproduces it, then makes it pass (`fix-bug` skill).
3. **Two copies of a rule get a test that they agree** (the SQL and app versions of the same calculation).
4. **Test the unhappy paths that real users hit**: offline, slow network, server unreachable for reads only, the app killed mid-write or mid-upload, permission denied, plan limit reached, two people editing at once.
5. **Multi-user flows use scripted second users**: a script signs in as the other user (a teammate, the other party), acts through the API, and listens to realtime while the app is driven by hand or by automation.
6. **No flaky waits.** Wait for a condition (a row exists, a subscription is live), not for a fixed number of seconds.
7. **Generated artefacts are checked in CI**: types, schema snapshots, lockfile consistency.

## Verification in the real app

8. **Run it.** Before calling a feature done, use it in a real browser (or call the running service): the happy path, then the states (loading, empty, error, offline), the largest text size, and reduce motion.
9. **Record evidence**: screenshots for UI, command output or row counts for data, and timings for performance. Put them in the PR and on the ticket.
10. **Say what wasn't verified** (a browser, a device or a credential you don't have) and file a ticket when it matters.
11. **Clean up afterwards**: stop dev servers, browsers and local stacks; reset changed settings (zoom, colour scheme, reduced motion, network throttling); remove test-only code.

## Drivers: running the app and capturing evidence

| Platform | Drive it | Screenshot | Repeatable flows | Watch out for |
| -- | -- | -- | -- | -- |
| **Web** | Playwright, or the agent's browser tools (the desktop app's built-in browser, Claude in Chrome, the Playwright MCP server) for exploring | `page.screenshot({ fullPage: true })`; `expect(page).toHaveScreenshot()` for visual regression | Playwright specs (`templates/testing/playwright.config.ts`, `screenshots.spec.ts`), with projects for mobile, desktop and dark | Mock the API per state with `page.route`; wait for visible text, not `networkidle`; reduced motion on; the Playwright version must match its cached browsers (`npx playwright install chromium` once) |
| **API / service** | `curl` or the test client against the local stack | Paste the response (status plus a trimmed body) | Integration tests | Never point at production; read keys from the environment without echoing them |

Other platforms add their drivers in their own section of this file. Screenshots go to `screenshots/<ticket>/<screen>-<state>-<variant>.png` (gitignored), are looked at one by one, and are published by `ship-pr` with `templates/testing/push-screenshots.sh` to a `screenshots` branch. The `capture-screenshots` skill does all of this.

## Quality gates

12. **Before a PR**: lint, typecheck, unit tests, plus database and integration tests when data, policies or functions changed. All green, run locally.
13. **CI repeats them** on a clean machine; a red CI blocks merging.
14. **Before a release**: the `release-readiness` audit, which covers the offline and sync scenario run, the layout QA matrix, accessibility, security and performance on real hardware.

## Supabase

- **Database rules** are pgTAP tests in `supabase/tests/`, run with `supabase test db` (pinned CLI). Every table has can and can't tests for each role, through RLS.
- **Integration tests** run against `supabase start` (Postgres, Auth, Storage, Realtime and Edge Functions locally) with real users that the admin client creates. Read the local service key with `supabase status -o env`, never echoed. Local email lands in Mailpit, where tests read sign-in codes.
- **Realtime**: a test checks that every table a channel subscribes to is in the publication, and that secret columns aren't published.
- **CI** starts only what the tests need (`supabase start -x studio,imgproxy`, for example), and runs `supabase test db` and the integration tests on every PR that touches data.
