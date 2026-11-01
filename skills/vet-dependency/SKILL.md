---
name: vet-dependency
description: "Vet a package before you add or upgrade it: advisories, release age, adoption, licence and fit. Use for each new dependency."
argument-hint: "[package name(s), and what it's for]"
---

# Vet a dependency

> Playbook files named here: when the project has its own copy at `.playbook/local/<same path>`, use that copy instead.

Package: $ARGUMENTS

Principles: `${CLAUDE_PLUGIN_ROOT}/principles/07-dependencies-supply-chain.md`.

1. **Need**: can the platform, the standard library or an existing dependency do this in a few lines? Say so if yes, and stop.
2. **Candidates**: the package plus one or two alternatives. For each, check from live sources (the registry, the advisory DB, the repo), not memory:
   - Latest version and release date; weekly downloads and dependents; maintainers; open issues and PR response; archived or not.
   - **Advisories** for the version you'd install (GitHub Advisories, OSV, and the ecosystem's audit after a dry install in a scratch dir), and whether they affect the code path you'd use.
   - **Release age**: a version published in the last two weeks waits, unless it fixes an advisory that affects you. Check that it came from the usual maintainer and matches a tag in the repo.
   - **Fit**: the supported framework or runtime versions, types, size, native or compiled parts, and the module format.
   - Licence; post-install scripts; network or file access it shouldn't need.

   | Ecosystem | Look up | Audit | Fit to check |
   | -- | -- | -- | -- |
   | npm | `npm view <pkg> time versions maintainers dist.attestations` | `npm audit`, `npm audit signatures` | Node LTS range (`engines`), React or framework major, TypeScript types, bundle size, native addons (`node-gyp`, prebuilt binaries), ESM/CJS |
   | Other | the registry's page and API | the ecosystem's audit tool, or OSV | the same questions |
3. **Recommend** the widely used, current, clean option, with a one-paragraph why. If none is clean, say what the risk is and ask the owner.
4. **Install the ecosystem's way** (`nx add`, the package manager the lockfile belongs to, or the installer the stack file names). Pin an exact version for packages whose output you depend on.
5. **Check**: the ecosystem's audit (`npm audit`, …) shows no new findings compared with before (say exactly what's pre-existing). The lockfile diff contains no surprising transitive packages.
6. **Record**: the PR "Packages" section (name@version, adoption, advisories, native or compiled parts); a Decision Log entry for anything notable (pinning, an accepted advisory with a revisit trigger, a choice between alternatives).

## Python (PyPI)

Add this row to the table in step 2:

| Ecosystem | Look up | Audit | Fit to check |
| -- | -- | -- | -- |
| PyPI | the PyPI page and JSON (`https://pypi.org/pypi/<pkg>/json`), `uv pip compile` to see the resolved tree | `pip-audit` (or `uv run pip-audit`) | `requires-python`, wheels for every target platform (no sdist-only C extensions), `py.typed` or stubs, a pure-Python fallback |

Install with `uv add <pkg>`, and check with `uv run pip-audit` that there are no new findings.
