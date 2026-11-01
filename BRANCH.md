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

## Use it

```bash
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

## Staying in sync with `main`

Shared changes land on `main` first. Bring them in with:

```bash
git checkout python
git merge main
```

This branch only adds files and appends sections at the end of shared files, so merges are usually clean. If `main` also changed the end of a file, keep both: `main`'s text first, then the "Python" section.
