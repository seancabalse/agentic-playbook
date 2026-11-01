# Branch: `mobile`

This branch is `main` plus the rules, skills and starter files for **iOS and Android apps built with Expo and React Native**. Everything on `main` still applies; this branch only adds to it.

## What it adds

- **Stack**: `stacks/expo-react-native.md` (versioned Expo docs, `npx expo install`, generated native folders, EAS builds, Reanimated, text scaling, device testing).
- **Starter file**: `templates/testing/maestro-screenshots.yaml`, a Maestro flow that captures PR screenshots on an emulator or simulator.
- **A "Mobile (iOS and Android)" section** at the end of:
  - principles `04` (targets, fixed art, layout checks), `05` (system font sizes, TalkBack and VoiceOver, Hermes `Intl`), `06` (keystore, app lock, permissions, push payloads), `08` (emulator and simulator drivers), `10` (native vs over-the-air, store releases) and `11` (mobile budgets, on-device profiling);
  - skills `capture-screenshots`, `verify-feature`, `a11y-audit`, `design-review`, `release-readiness` and `vet-dependency` (native modules).
- **Stack inference** in `bootstrap-project`: an Expo `app.json` suggests `expo-react-native`.

## Stacks (`--stack`)

`expo-react-native`, plus everything on `main`: `react-web`, `node-service`, `nx-monorepo`.

## Prerequisites

- Node.js LTS (the Expo CLI runs through `npx`).
- **Xcode** with an iOS simulator (macOS only).
- **Android Studio** with an emulator and the platform tools (`adb`).
- **Maestro** for repeatable flows and screenshots.
- An Expo account for EAS Build and EAS Update.

## Use it

```bash
git clone --branch mobile https://github.com/seancabalse/agentic-playbook ~/code/agentic-playbook-mobile
~/code/agentic-playbook-mobile/scripts/playbook.sh project ~/code/app --stack expo-react-native --tracker linear
```

To use it as a Claude Code plugin from the project's copy: `/plugin marketplace add ./.playbook`, then `/plugin install playbook@agentic-playbook`.

**Screenshots for a PR**: say "capture screenshots for ACME-42: settings default, error, and at the largest text". `capture-screenshots` drives `adb` or `simctl`, or runs the Maestro flow:

```bash
maestro test .playbook/templates/testing/maestro-screenshots.yaml -e APP_ID=com.acme.app -e TICKET=ACME-42
```

Claude looks at every image. A black one usually means a secure window (a biometric prompt) or a locked device. `/ship-pr` then publishes them with `templates/testing/push-screenshots.sh`.

## Staying in sync with `main`

Shared changes land on `main` first. Bring them in with:

```bash
git checkout mobile
git merge main
```

This branch only adds files and appends sections at the end of shared files, so merges are usually clean. If `main` also changed the end of a file, keep both: `main`'s text first, then the "Mobile (iOS and Android)" section.
