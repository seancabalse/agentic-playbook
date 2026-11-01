# Delivery, CI and release

Small changes, always shippable, deployed by machines.

## Branches and PRs

1. **Short-lived branches from the default branch**, named from the ticket (`<user>/proj-123-short-title`). Stacked branches are fine, but rebase onto the default branch once the base merges.
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

## Mobile (iOS and Android)

- **Native or over the air**: a native change (a new native module, permissions, config plugins, the app icon, an SDK upgrade) needs a new store build. JS-only changes can ship over the air (EAS Update or equivalent). Each PR says which it needs.
- **Over-the-air updates match their runtime version**: an update never reaches a build whose native code it doesn't fit.
- **Builds run in the pipeline** (EAS Build or equivalent) from profiles in the repo, never from a laptop. Signing credentials are owner-held.
- **Store releases** go to internal testing first (TestFlight, the Play Console's internal track), then out as a staged rollout (Google Play's percentage rollout, the App Store's phased release).
- **The release checklist adds**: the store listing and screenshots, review notes with a test account, App Store privacy labels and the Play Store data safety form matching what the app collects, and the minimum OS versions.
- **Old app versions stay installed for months**: the server stays compatible with every version still in use, and a forced-update path exists before you need it.
