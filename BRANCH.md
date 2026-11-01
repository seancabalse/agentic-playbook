# Branch: all

`all` is `main` with every other branch merged in: `mobile`, `python` and `supabase`. Use it for one machine-wide install that serves projects on different stacks. Each addition is in a clearly labelled section ("Mobile (iOS and Android)", "Python", "Supabase"), so a project uses the parts that match its stacks.

## Stacks (`--stack`)

| Stack | From |
| -- | -- |
| `node-service`, `react-web`, `nx-monorepo` | `main` |
| `expo-react-native` | `mobile` |
| `python`, `python-fastapi`, `python-django` | `python` |
| `supabase-postgres` | `supabase` |

## Prerequisites

Those of `main`, plus the tools of the stacks a project uses:
- **Mobile**: Xcode (iOS simulator), Android Studio (emulator, `adb`), Maestro.
- **Python**: `uv`.
- **Supabase**: the Supabase CLI and Docker.

## Install machine-wide

See "Install for every project on this machine" in the README. In short:

```bash
git clone https://github.com/seancabalse/agentic-playbook.git
cd agentic-playbook && git checkout all
claude plugin marketplace add "$PWD"
claude plugin install playbook@agentic-playbook --scope user
```

## Staying in sync

`all` is updated by merging, never edited directly. When two branches add a section to the same file, keep both sections.

```bash
git checkout all
git merge main mobile python supabase
```
