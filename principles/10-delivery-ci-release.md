# Delivery, CI and release

Small changes, always shippable, deployed by machines.

## Branches and PRs

1. **Short-lived branches from the default branch**, named from the ticket (`<user>/proj-123-short-title`). Stacked branches are fine, but rebase onto the default branch once the base merges. On a busy team branch, rebase often (`sync-branch`): at the start of a task, when the playbook hook says the branch is behind or a conflict is coming, and before each push, handoff and PR.
2. **One concern per PR**, with the description from `templates/pr-description.md`. The owner reviews and merges.
3. **Branches auto-delete after merge.** Don't push to a merged branch: open a new one.
4. **Commit messages and PRs follow the working agreement**: the why, the ticket id, and no AI attribution.

## CI

5. **CI runs everything the developer runs**: lint, typecheck, unit, database and integration tests, generated-artefact freshness, dependency audit, and (per stack) a production build. In monorepos it runs on affected projects.
6. **CI uses pinned tool versions** (`npx -y tool@x.y.z`, a toolchain file), because unpinned "latest" breaks without warning.
7. **CI starts only the services the tests need** (for example the local stack without its dashboard).
8. **Secrets in CI are scoped** to the job and environment that needs them.

## Environments and deploys

9. **dev** gets every merge automatically, and **prod** is a deliberate manual run of the same pipeline. Prod may stay "on hold" until launch.
10. **Deploys are workflows**, never laptops: database migrations, functions, infrastructure and app builds.
11. **Configuration per environment** lives in the pipeline (function URLs, keys from the vault), not in code.
12. **Note what each PR needs to release**: a migration, an env var, a config change, a cache purge, a new build.

## Releases

13. **Run the release checklist** (`templates/release-checklist.md`) via the `release-readiness` skill: audits green, migrations applied, privacy notice current, rollback plan.
14. **Version every release** (semver or date plus build number) and write release notes from the merged PRs.
15. **Have a rollback plan per release**: the previous build, a database change that's reversible or forward-fixable, and feature gates to switch things off.
16. **After a release**, watch crash and error rates and the key flows for a day, and log what happened.
