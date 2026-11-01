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
# Branch: `python`

This branch is `main` plus the rules, skills and starter files for **Python services: plain Python, FastAPI and Django**. Everything on `main` still applies; this branch only adds to it.

## What it adds

- **Stacks**:
  - `stacks/python.md`: uv, ruff, strict mypy, pytest, typed boundaries, aware datetimes, async, logging, data access and security rules.
  - `stacks/python-fastapi.md`: layers, pydantic models, auth dependencies, async drivers, errors, operability and tests.
  - `stacks/python-django.md`: settings, apps and layers, migrations, tenancy, DRF, security, jobs and tests.
- **Starter file**: `templates/python/pyproject.toml` (uv, hatchling, ruff with security rules, strict mypy, strict pytest, coverage).
- **A "Python" section** at the end of principle `07` (pip-audit, wheels, `uv add`, `uv.lock`) and of the `vet-dependency` skill (the PyPI checks).
- **Stack inference** in `bootstrap-project`: `pyproject.toml` or `requirements*.txt` suggests `python`, plus FastAPI or Django from the dependencies.

## Stacks (`--stack`)

`python`, `python-fastapi`, `python-django`, plus everything on `main`: `react-web`, `node-service`, `nx-monorepo`. Use `python` with one framework stack, for example `--stack python,python-fastapi`.

## Prerequisites

- **uv** (it installs and pins the Python version too).
- Docker, for integration tests against a real database (Testcontainers or Docker Compose).
# Branch: `supabase`

This branch is `main` plus the rules for a **Supabase (Postgres) backend**: migrations, row-level security, pgTAP tests, Realtime, Storage, Edge Functions and scheduled jobs. Everything on `main` still applies; this branch only adds to it.

## What it adds

- **Stack**: `stacks/supabase-postgres.md` (pinned CLI, migrations, generated types, RLS and grants, secret columns, Realtime, the client, error codes, Auth, Storage, Edge Functions, jobs, integration tests).
- **A "Supabase" section** at the end of:
  - principle `08` (pgTAP with `supabase test db`, integration tests against `supabase start`, Realtime publication tests);
  - principle `09` (migration commands, deploy by workflow only, RLS through one membership function, types, purge jobs);
  - the `bootstrap-project` skill (stack inference, plus the CI and deploy-workflow setup).

## Stacks (`--stack`)

`supabase-postgres`, plus everything on `main`: `react-web`, `node-service`, `nx-monorepo`. It is a backend stack, so pair it with a client stack, for example `--stack react-web,supabase-postgres`.

## Prerequisites

- The **Supabase CLI**, run through `npx -y supabase@<x.y.z>` with a pinned version.
- **Docker**, for the local stack (`supabase start`).
- Node.js LTS.

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
git clone --branch python https://github.com/seancabalse/agentic-playbook ~/code/agentic-playbook-python
uv init --package api && cd api
cp ~/code/agentic-playbook-python/templates/python/pyproject.toml .   # then rename the package
~/code/agentic-playbook-python/scripts/playbook.sh project . --stack python,python-fastapi --tracker github
```

Then, in Claude Code:

```
/playbook:bootstrap-project python,python-fastapi
```

`AGENTS.md` gets the Python and FastAPI rules. The commands it verifies are `uv run ruff check .`, `uv run ruff format --check .`, `uv run mypy`, `uv run pytest` and `uv run pip-audit`. `vet-dependency` checks PyPI packages: advisories through `pip-audit`, wheels for your platforms, `py.typed`, and release age.

To change a default for one project, for example: `/playbook:customize stacks/python.md we use pyright, not mypy`.
git clone --branch supabase https://github.com/seancabalse/agentic-playbook ~/code/agentic-playbook-supabase
~/code/agentic-playbook-supabase/scripts/playbook.sh project ~/code/app --stack react-web,supabase-postgres --tracker linear
```

Then run `/playbook:bootstrap-project react-web,supabase-postgres` in Claude Code. It adds `supabase test db` and the integration tests to the project's check list, and plans the deploy workflow (dev on merge, prod by manual run) with the secrets the owner sets.

## Staying in sync with `main`

Shared changes land on `main` first. Bring them in with:

```bash
git checkout mobile
git merge main
```

This branch only adds files and appends sections at the end of shared files, so merges are usually clean. If `main` also changed the end of a file, keep both: `main`'s text first, then the "Mobile (iOS and Android)" section.
git checkout python
git merge main
```

This branch only adds files and appends sections at the end of shared files, so merges are usually clean. If `main` also changed the end of a file, keep both: `main`'s text first, then the "Python" section.
git checkout supabase
git merge main
```

This branch only adds files and appends sections at the end of shared files, so merges are usually clean. If `main` also changed the end of a file, keep both: `main`'s text first, then the "Supabase" section.
