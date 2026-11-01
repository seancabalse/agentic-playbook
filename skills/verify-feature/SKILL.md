---
name: verify-feature
description: "Verify a feature in the running product against its acceptance criteria and states, with evidence. Use before you call a feature done."
argument-hint: "[ticket id, or 'offline' / 'layout' for the QA scenarios]"
---

# Verify in the real app

> Playbook files named here: when the project has its own copy at `.playbook/local/<same path>`, use that copy instead.

Target: $ARGUMENTS

## Setup

- Start only what's needed (the local backend, the app in a browser, the service). Note each process so you can stop it.
- Use the project's runbook for launch commands and the test accounts (a scripted second user for multi-user flows).
- Pick the driver for the platform (`${CLAUDE_PLUGIN_ROOT}/principles/08-testing-qa.md` → "Drivers"): Playwright or the agent's browser tools for web; `curl` or the test client for an API.

## Walk it

1. **Acceptance criteria**, one by one, as a customer would. Record what you did and what you saw.
2. **States**: loading (throttle or pause the backend), error (stop the API so reads fail), offline (the browser offline plus the backend unreachable), empty (a fresh account).
3. **Unhappy paths**: close the tab or kill the process mid-write or mid-upload, then reopen; a plan limit; permission denied; two users at once; a slow network.
4. **Accessibility**: the largest text size (200% zoom, 320 px reflow), keyboard only, screen reader labels on new controls, reduce motion on. Reset each setting afterwards.
5. **Data**: check the rows, files and jobs the action should create, with direct queries, counts and outcomes.
6. **Lifecycle**: a reload, a second tab, the back button, a session that expires, a deploy while the page is open.

## Scenarios

- **`offline`**: warm the cache, go offline (network off **and** backend unreachable), reload: everything the product promises offline shows from cache. Make one of each write, close the tab, reconnect: each write lands exactly once. Measure the latency to the other user with a realtime listener.
- **`layout`**: 320 px, a tablet, a desktop, 200% zoom, portrait and landscape. Screenshot each key screen.

## Evidence and cleanup

- Capture screenshots with `capture-screenshots` (states × sizes × settings, each one looked at), plus numbers (row counts, latencies).
- Report each criterion as **pass / fail / not verified (why)**. Never round "not verified" up to "pass".
- File tickets for anything found that's outside the task's scope.
- When another agent or session continues from here, write a `handoff` with these results.
- **Stop everything you started** (dev server, browsers, local stack, listeners) and reset changed settings. Leave alone what you didn't start.

## Mobile (iOS and Android)

- **Setup**: the app on an Android emulator or iOS simulator (or a device) against the local backend. Drive it with `adb` or Maestro on Android, and `simctl`, Maestro or the desktop app's simulator tool on iOS (`${CLAUDE_PLUGIN_ROOT}/principles/08-testing-qa.md` → "Mobile").
- **States**: offline is airplane mode **and** the backend unreachable. A local backend can stay reachable through `adb reverse`, so pause it too.
- **Unhappy paths**: kill the app from the switcher mid-write or mid-upload, then relaunch.
- **Accessibility**: Android `font_scale 2.0` and iOS `accessibility-extra-extra-extra-large`; TalkBack and VoiceOver on new controls.
- **Platform lifecycle**: background and foreground, a settings change that rebuilds the view (font scale, display size), a cold start, and a permission denied and then granted in Settings.
- **`offline`**: force-stop and relaunch while offline: everything shows from cache. Make one of each write, kill the app, reconnect: each write lands exactly once.
- **`layout`**: the smallest phone (360 pt wide), a tablet, gesture and 3-button navigation, the largest text on each platform, portrait lock.
- **Clean up**: stop emulators, simulators and Metro, and reset font scale, density, animations and appearance.
