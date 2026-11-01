# Data and migrations

The database outlives every client version. Treat its schema as a public API.

## Changing the schema

1. **Only through migrations** (the database tool's migrations, Prisma, Drizzle, Flyway, Liquibase), applied from scratch locally to prove they work. Never by hand in a dashboard or SQL editor.
2. **Never edit a migration that has reached the default branch.** Add a new one.
3. **Hosted environments change only through the pipeline**: dev on merge, prod as a deliberate manual run. Never from a laptop.
4. **Regenerate types after every migration** and commit them; CI fails if they're stale.
5. **Old clients keep working.** Additive changes first (new nullable column, new table); remove things only after no shipped client uses them. Old clients live on: open browser tabs, installed apps and API consumers keep calling the old shape.

## Every new table, in the same PR

6. A tenant id and a foreign key to the tenant.
7. Access policies (deny by default), grants per role, and column grants where only some columns are writable.
8. Database tests covering can and can't for each role (`08-testing-qa.md`).
9. A decision about live updates (realtime, change feeds): published or not. If published, only the columns clients may see, with a test that checks it.
10. Soft delete (`deleted_at`) if people can remove rows, plus the purge job's coverage.
11. Indexes for the queries the app actually runs, especially on tenant id and foreign keys.

## Integrity in the database

12. **Constraints over code**: `not null`, `check` (sizes, enums, "both or neither"), unique indexes (one active subscription per account), foreign keys with deliberate `on delete`.
13. **Triggers for invariants that span rows or roles**: "only the author deletes", "tags belong to the same tenant", "server stamps who approved it".
14. **Functions for anything that must be atomic or must hide data**: create-and-join, read-and-record, export-without-recording.
15. **Size caps on JSON and text** so one client can't store megabytes in a row.
16. **Client ids are UUIDs made on the client**, so writes are idempotent (`02-architecture.md` rule 7).

## Data lifecycle

17. **Soft delete, then purge** after a documented window, with files purged after their rows (`02-architecture.md` rule 15).
18. **Account deletion keeps shared content**: author ids become null and the UI shows "a former member" (or similar), unless policy says otherwise.
19. **Export is available to the people the data belongs to** and leaves the data unchanged (no "read" markers set).
20. **Back up and test a restore** before production, and note the retention and backup policy in the runbook.

## Supabase

- **Pin the CLI** (`npx -y supabase@<x.y.z> …`) locally and in CI.
- **Migrations**: `supabase migration new <name>` (it reads SQL from stdin, so redirect `< /dev/null` when scripting), then `supabase migration up` locally. `supabase db reset` rebuilds from scratch to prove the full history applies.
- **Hosted projects change only through the deploy workflow** (dev on merge, prod by manual run), never with `supabase db push` from a laptop or the dashboard SQL editor.
- **Every content table**: RLS on, policies through one `security definer` membership function (for example `private.is_member(tenant_id)`) that pins `search_path`, grants per role, and column grants where only some columns are writable.
- **Types**: `supabase gen types typescript --local` after each migration, committed; CI fails if they're stale.
- **Realtime**: the publication lists its tables in a migration, with a column list for any table that has a secret column.
- **Purge**: `pg_cron` runs the soft-delete purge and then the storage orphan sweep.
