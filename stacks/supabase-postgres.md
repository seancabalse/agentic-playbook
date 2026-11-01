
## Stack: Supabase (Postgres)

- **Pin the CLI** (`npx -y supabase@<x.y.z> …`) locally and in CI; unpinned `npx supabase` can fetch a release whose platform binary fails.
- **Schema changes are migrations only**: `supabase migration new <name>` (it reads SQL from stdin, so redirect `< /dev/null` when scripting), then `supabase migration up` locally (keeps data). `db reset` rebuilds from scratch but wipes local data and can drop custom auth templates until a restart. Never edit a migration that has reached the default branch.
- **Hosted projects change only through the deploy workflow** (dev on merge, prod by manual run), never from a laptop or the dashboard SQL editor.
- **Types**: regenerate after each migration (`supabase gen types typescript --local --schema public > src/data/database.types.ts`) and commit; CI fails if stale.
- **Every content table**: `<tenant>_id`, RLS on, policies through a `private.is_member()`-style function, grants per role (column grants where only some columns are writable), and pgTAP tests in `supabase/tests/` for can/can't. Run with `supabase test db`.
- **Secret columns**: revoke `select` on the column and expose it through a `security definer` function that checks membership (and records the read if needed). Realtime ignores column privileges, so publish such tables with a column list and test the publication.
- **Realtime**: a table must be in the publication before a channel subscribes to it, or the whole channel fails. Treat SUBSCRIBED as streaming only with `postgres_changes` options that wait for the server's confirmation; refetch after a rejoin.
- **Client**: one `createClient` module; `db: { retry: false }` when the query library retries; `insert()` ignores conflict options, so use `upsert(…, { onConflict: 'id', ignoreDuplicates: true })` for idempotent creates.
- **Errors**: map by SQLSTATE and custom codes (`PW001`-style for plan limits); classes 22, 23 and 42 are permanent.
- **Auth**: prefer email OTP codes to magic links where deep links are unreliable (mobile apps, some mail clients); custom SMTP and templates must be set on hosted projects; local mail goes to Mailpit. `getSession()` may return null offline for a stored session whose refresh failed; only `SIGNED_OUT` means signed out.
- **Storage**: private buckets, objects at `{tenant}/{id}.ext`, policies per prefix, signed URLs for reads, no overwrites; an orphan sweep removes objects without rows after a grace period.
- **Edge Functions**: `index.ts` is a thin Deno entry; logic is a pure module with injected dependencies, tested with the app's test runner. Each function has `deno.json` and is type-checked in CI. Settings go in `config.toml`; secrets via `supabase secrets set` (owner). The local runtime loads functions only at `supabase start`.
- **Jobs**: `pg_cron` plus `pg_net` calling functions with a key the database generated in Vault, never a user token. Plan scheduled work into a table, then claim it with `for update skip locked`.
- **Integration tests** run against `supabase start` with real users (admin client creates them; local service key read with `supabase status -o env`, never echoed).
