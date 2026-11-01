# Dependencies and supply chain

Every package is code you didn't review, running with your permissions.

## Before adding a package

Run the `vet-dependency` skill. It checks:

1. **Need**: can the platform, the standard library or an existing dependency do this in a few lines? If so, don't add it.
2. **Known vulnerabilities**: the ecosystem advisory database (`npm audit`, GitHub Advisories, OSV) for the version you'll install. Is a fixed version available, and does the advisory affect the code path you use?
3. **Adoption and maintenance**: weekly downloads, dependents, last release, open issue and PR response, number of maintainers, and whether it's archived.
4. **Fit**: supports your runtime and framework version (for example the Node LTS or the framework's major), its types, its bundle size, and whether it has native or compiled parts that need a build toolchain.
5. **Licence** compatible with how you ship (MIT, Apache-2.0, BSD and ISC are fine; ask about GPL, AGPL and source-available licences).
6. **Install script and permissions**: does it run post-install scripts or ask for network or file access it shouldn't need?
7. **Release age**: let a brand-new release age about two weeks before adopting it, unless it fixes an advisory that affects you. Many supply-chain attacks are caught and pulled within days. Check that the release came from the usual maintainers and matches a tag.

Prefer the **widely used, current** option over the clever one.

## Installing

8. **Use the ecosystem's version-aware installer** when there is one (`nx add`, `ng add`, or the one the stack file names), so versions match the framework.
9. **Pin exact versions for packages whose data or output you depend on** (time-zone databases, parsers, crypto, codegen). After bumping one, rerun the tests that check it against the system.
10. **Commit the lockfile**, and review its diff in PRs: unexpected new transitive packages are a red flag.

## Living with them

11. **Audit in CI** and look at new advisories each week. Fix by upgrading the direct dependency; never accept an "audit fix" that downgrades your framework (`npm audit fix --force` can propose absurd downgrades).
12. **Advisories you can't fix yet are decisions**: log the package, the advisory, why it doesn't affect you or what blocks the fix, and a review date. Better still, keep them in an allowlist that CI reads, so an expired review date fails the build.
13. **Upgrade on a schedule**: framework SDKs following their upgrade guide, one major at a time, with the full suite and a check in the real app.
14. **Remove dependencies you no longer use** in the same PR that stops using them.

## Python

- **Advisories**: `pip-audit` (or `uv run pip-audit`) against the resolved environment, plus OSV and GitHub Advisories, for the version you'll install.
- **Fit**: `requires-python`, wheels for every target platform (no sdist-only C extensions that need a compiler in production), `py.typed` or stubs, and a pure-Python fallback where one exists.
- **Install with `uv add <pkg>`** (it updates `pyproject.toml` and `uv.lock`), never `pip install` into a system or shared interpreter. Commit `uv.lock`, and review its diff.
- **Pin exactly** (`==`) the packages whose output you depend on, as in rule 9.
- **Audit in CI** with `uv run pip-audit`, and accepted advisories go in the allowlist with a review date (rule 12).
