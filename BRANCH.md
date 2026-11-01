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
git clone --branch supabase https://github.com/seancabalse/agentic-playbook ~/code/agentic-playbook-supabase
~/code/agentic-playbook-supabase/scripts/playbook.sh project ~/code/app --stack react-web,supabase-postgres --tracker linear
```

Then run `/playbook:bootstrap-project react-web,supabase-postgres` in Claude Code. It adds `supabase test db` and the integration tests to the project's check list, and plans the deploy workflow (dev on merge, prod by manual run) with the secrets the owner sets.

## Staying in sync with `main`

Shared changes land on `main` first. Bring them in with:

```bash
git checkout supabase
git merge main
```

This branch only adds files and appends sections at the end of shared files, so merges are usually clean. If `main` also changed the end of a file, keep both: `main`'s text first, then the "Supabase" section.
