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

## Mobile (iOS and Android)

Verification runs on an Android emulator and an iOS simulator (or real devices), as well as in tests.

| Platform | Drive it | Screenshot | Repeatable flows | Watch out for |
| -- | -- | -- | -- | -- |
| **Android emulator** | `adb`: `am start -a android.intent.action.VIEW -d <deep link>`, `input tap/text/keyevent`, `uiautomator dump` to find elements | `adb exec-out screencap -p > file.png` | Maestro (`maestro test flow.yaml`, `takeScreenshot`; `templates/testing/maestro-screenshots.yaml`) | Settings: `settings put system font_scale 2.0`, `wm density`, animation scales; reset them after. A PIN-locked emulator boots locked. Secure windows (biometric prompts) capture as black. `adb reverse` for local ports. |
| **iOS simulator** | `xcrun simctl openurl booted <url>`, Maestro for taps, or the desktop app's iOS simulator tool | `xcrun simctl io booted screenshot file.png` | Maestro (same flow file) | `simctl ui booted content_size accessibility-extra-extra-extra-large` and `appearance dark`; reset to `large` and `light`. A simulator build needs a simulator build profile. |

- **Run it on both platforms** when the change touches platform behaviour (permissions, notifications, files, keyboard, lifecycle). Say which one you didn't run.
- **Mobile unhappy paths**: airplane mode, the app killed from the switcher mid-write or mid-upload, background and foreground, and a settings change that rebuilds the view (font scale, display size).
- **"Offline" on an emulator**: turning the network off may not cut a local backend reached through `adb reverse`. Pause the backend as well.
- **Real devices** for what emulators and simulators can't show: performance, push delivery, biometrics, the camera.
- **Clean up**: stop emulators, simulators and Metro; reset font scale, density, animations and appearance.
## Supabase

- **Database rules** are pgTAP tests in `supabase/tests/`, run with `supabase test db` (pinned CLI). Every table has can and can't tests for each role, through RLS.
- **Integration tests** run against `supabase start` (Postgres, Auth, Storage, Realtime and Edge Functions locally) with real users that the admin client creates. Read the local service key with `supabase status -o env`, never echoed. Local email lands in Mailpit, where tests read sign-in codes.
- **Realtime**: a test checks that every table a channel subscribes to is in the publication, and that secret columns aren't published.
- **CI** starts only what the tests need (`supabase start -x studio,imgproxy`, for example), and runs `supabase test db` and the integration tests on every PR that touches data.

## Tests for a change

This section is for the verification of a change: the `qa-verifier` agent, the `verify-feature` skill, and the examination of a handoff by the lead. Rule 12 is for the author before a PR.

15. **Run the tests that the change can affect. Do not run all the tests.** First, do an impact assessment:
    1. Find the changed files: `git diff --name-only <base>...HEAD`, and `git status --short` for the files that are not committed.
    2. For each changed file, find the code that uses it. Find the files that import it, then the files that import those files. Continue until you find the tests and the entry points (a route, a screen, a handler, a job). A test runner can do this for you. Examples: `vitest related --run <files>`, `jest --findRelatedTests <files>`, `nx affected -t test`. Read the docs for the installed version. If the runner cannot do it, search for the imports (`grep -rln "<module name>"`).
    3. A shared file can affect many features. Examples: a utility, a type, a hook, a component of the kit, a schema, a query, a client, a style token. Test each feature that uses the shared file, not only the feature of the task.
    4. Some changes can affect all the code. For these changes, run all the tests: dependencies or the lockfile; the configuration of the build, the lint, the types or the tests; environment variables; global setup (providers, the app shell, the router, middleware, the database client); generated code. For a migration or an access policy, run all the database tests.
    5. If you cannot find all the users of a file (for example dynamic imports, or routes in strings), make the scope larger. Run all the tests of the package or the module.
16. **Run the typecheck and the lint for the full project** when they are fast (approximately 1 minute or less). They find the users of a change that the import search did not find.
17. **Write the impact assessment in your report**: the changed files, the features that they affect, the tests that you ran, and the tests that you did not run, with the reason.
18. **CI runs all the tests.** The impact assessment makes the local checks fast. It does not replace CI.
