#!/usr/bin/env bash
# Install the engineering playbook. This folder is the shareable template: a project gets a copy of it
# as .playbook/ (committed, and itself a Claude Code plugin), an AGENTS.md built from .playbook/AGENTS.md
# plus the chosen stacks and tracker, and each tool's files. In those tool files and AGENTS.md,
# ${CLAUDE_PLUGIN_ROOT} becomes the path where the playbook ends up.
#
#   playbook.sh project <dir> [--stack a,b] [--tracker linear|jira|github] [--tools plugin|claude,agents,cursor,copilot] [--force]
#   playbook.sh user [--force]           skills + agents for every project (~/.claude)
#   playbook.sh prompts [<out>]          plain prompts for any chat assistant (default: dist/prompts)
#   playbook.sh list                     stacks, trackers, starter files, skills and agents
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FORCE=0
# The plugin's path variable, as it's written in the sources ([$] keeps sed from reading it as an anchor).
TOKEN='[$]{CLAUDE_PLUGIN_ROOT}'

die() { echo "playbook: $*" >&2; exit 1; }
note() { echo "  $*"; }

# render SRC DST PREFIX [ARGS]: copy with ${CLAUDE_PLUGIN_ROOT} (and optionally $ARGUMENTS) replaced.
render() {
  local src="$1" dst="$2" prefix="$3" args="${4:-}"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ "$FORCE" -ne 1 ]; then note "kept   $dst (exists; --force to replace)"; return; fi
  if [ -n "$args" ]; then
    sed -e "s#$TOKEN#$prefix#g" -e "s#\$ARGUMENTS#$args#g" "$src" > "$dst"
  else
    sed -e "s#$TOKEN#$prefix#g" "$src" > "$dst"
  fi
  note "wrote  $dst"
}

# Body of a markdown file without its leading frontmatter.
body() { awk 'NR==1 && $0=="---" {fm=1; next} fm && $0=="---" {fm=0; next} !fm' "$1"; }
# One frontmatter field (single-line values only).
field() { awk -v k="$2" 'NR==1 && $0=="---" {fm=1; next} fm && $0=="---" {exit} fm && index($0, k": ")==1 {sub(k": ", ""); gsub(/^"|"$/, ""); print; exit}' "$1"; }

skills() { for d in "$ROOT"/skills/*/; do basename "$d"; done; }
agents() { for f in "$ROOT"/agents/*.md; do basename "$f" .md; done; }

copy_library() { # copy_library DEST PREFIX: principles, stacks, trackers, and templates with every subfolder
  local dest="$1" prefix="$2" f
  for f in "$ROOT"/principles/*.md "$ROOT"/stacks/*.md "$ROOT"/trackers/*.md; do
    [ -f "$f" ] || continue
    render "$f" "$dest/$(basename "$(dirname "$f")")/$(basename "$f")" "$prefix"
  done
  while IFS= read -r f; do
    render "$ROOT/templates/$f" "$dest/templates/$f" "$prefix"
  done < <(cd "$ROOT/templates" && find . -type f ! -name '.*' | sed 's#^\./##' | sort)
  find "$dest/templates" -type f -name '*.sh' -exec chmod +x {} +
}

# The shared rules: AGENTS.md up to "This project" (sections 1–7).
core_rules() { awk '/^## 8\. This project/ {exit} {print}' "$ROOT/AGENTS.md"; }

# copy_template DEST: the whole playbook, as it is (it stays a plugin), without generated files or the
# source project's own overrides.
copy_template() {
  local dest="$1"
  if [ "$(cd "$ROOT" && pwd)" = "$dest" ]; then note "kept   $dest (this is the template itself)"; return; fi
  if [ -e "$dest" ] && [ "$FORCE" -ne 1 ]; then note "kept   $dest (exists; --force to update, local/ is never touched)"; return; fi
  mkdir -p "$dest"
  rsync -a --exclude dist/ --exclude local/ --exclude .git/ --exclude .DS_Store "$ROOT"/ "$dest"/
  note "wrote  $dest (the playbook; project changes go in $dest/local/)"
}

agents_md() { # agents_md PREFIX STACKS TRACKER: the AGENTS.md content
  local prefix="$1" stacks="$2" tracker="$3" s
  sed -e "s#$TOKEN#$prefix#g" "$ROOT/AGENTS.md"
  for s in $(echo "$stacks" | tr ',' ' '); do
    [ -f "$ROOT/stacks/$s.md" ] || die "unknown stack '$s' (see: playbook.sh list)"
    sed -e "s#$TOKEN#$prefix#g" "$ROOT/stacks/$s.md"
  done
  if [ -n "$tracker" ]; then
    [ -f "$ROOT/trackers/$tracker.md" ] || die "unknown tracker '$tracker' (see: playbook.sh list)"
    sed -e "s#$TOKEN#$prefix#g" "$ROOT/trackers/$tracker.md"
  fi
}

install_project() {
  local dir="" stacks="" tracker="" tools="plugin,agents,cursor,copilot" s a f out
  while [ $# -gt 0 ]; do
    case "$1" in
      --stack) stacks="$2"; shift 2 ;;
      --tracker) tracker="$2"; shift 2 ;;
      --tools) tools="$2"; shift 2 ;;
      --force) FORCE=1; shift ;;
      *) [ -z "$dir" ] || die "unexpected argument '$1'"; dir="$1"; shift ;;
    esac
  done
  [ -n "$dir" ] && [ -d "$dir" ] || die "usage: playbook.sh project <existing dir> [--stack a,b] [--tools …]"
  dir="$(cd "$dir" && pwd)"
  # Check names before writing anything, so a typo leaves the project untouched.
  for s in $(echo "$stacks" | tr ',' ' '); do [ -f "$ROOT/stacks/$s.md" ] || die "unknown stack '$s' (see: playbook.sh list)"; done
  [ -z "$tracker" ] || [ -f "$ROOT/trackers/$tracker.md" ] || die "unknown tracker '$tracker' (see: playbook.sh list)"
  # Claude Code gets the skills and agents one way only: the plugin, or copies in .claude/. Both would list every skill twice.
  case ",$tools," in *,plugin,*) case ",$tools," in *,claude,*) die "--tools: choose plugin or claude, not both (both would load every skill twice)" ;; esac ;; esac
  echo "Installing the playbook into $dir"

  # The template itself, committed with the project. Paths in the generated files are relative to the
  # repo root, where agents run.
  copy_template "$dir/.playbook"

  case ",$tools," in *,agents,*)
    out="$dir/AGENTS.md"
    if [ -e "$out" ] && [ "$FORCE" -ne 1 ]; then out="$dir/AGENTS.playbook.md"; note "AGENTS.md exists: merge AGENTS.playbook.md into it (project rules win)"; fi
    agents_md ".playbook" "$stacks" "$tracker" > "$out"; note "wrote  $out"
    if [ ! -e "$dir/CLAUDE.md" ]; then cp "$ROOT/templates/CLAUDE.md" "$dir/CLAUDE.md"; note "wrote  $dir/CLAUDE.md"
    elif ! grep -q '@AGENTS.md' "$dir/CLAUDE.md"; then note "CLAUDE.md exists without @AGENTS.md: add that line"; fi
  ;; esac

  case ",$tools," in *,plugin,*)
    # The project's own .playbook/ is the plugin: one source, no copies in .claude/ to drift or load twice.
    f="$dir/.claude/settings.json"
    if [ -e "$f" ]; then
      note "kept   $f (exists): merge in the settings from .playbook/templates/claude-settings.json, with the source"
      note "       { \"source\": \"directory\", \"path\": \"./.playbook\" }"
    else
      mkdir -p "$(dirname "$f")"
      cat > "$f" <<'JSON'
{
  "extraKnownMarketplaces": {
    "agentic-playbook": { "source": { "source": "directory", "path": "./.playbook" } }
  },
  "enabledPlugins": { "playbook@agentic-playbook": true },
  "worktree": { "baseRef": "head" }
}
JSON
      note "wrote  $f (the playbook plugin from ./.playbook)"
    fi
    for s in $(skills); do
      [ -e "$dir/.claude/skills/$s" ] && note "WARNING $dir/.claude/skills/$s duplicates the plugin's skill: remove it"
    done
  ;; esac

  case ",$tools," in *,claude,*)
    for s in $(skills); do render "$ROOT/skills/$s/SKILL.md" "$dir/.claude/skills/$s/SKILL.md" ".playbook"; done
    for a in $(agents); do render "$ROOT/agents/$a.md" "$dir/.claude/agents/$a.md" ".playbook"; done
    grep -qs 'playbook@agentic-playbook' "$dir/.claude/settings.json" && note "WARNING .claude/settings.json also enables the playbook plugin: disable one of the two"
  ;; esac

  case ",$tools," in *,cursor,*)
    # Cursor reads AGENTS.md itself; each skill becomes an agent-requested rule.
    for s in $(skills); do
      f="$dir/.cursor/rules/$s.mdc"
      if [ -e "$f" ] && [ "$FORCE" -ne 1 ]; then note "kept   $f (exists)"; continue; fi
      mkdir -p "$(dirname "$f")"
      { printf -- '---\ndescription: %s\nalwaysApply: false\n---\n' "$(field "$ROOT/skills/$s/SKILL.md" description)"
        body "$ROOT/skills/$s/SKILL.md" | sed -e "s#$TOKEN#.playbook#g" -e 's#\$ARGUMENTS#the task the user gave#g'
      } > "$f"; note "wrote  $f"
    done
  ;; esac

  case ",$tools," in *,copilot,*)
    f="$dir/.github/copilot-instructions.md"
    if [ -e "$f" ] && [ "$FORCE" -ne 1 ]; then note "kept   $f (exists): make sure it points to AGENTS.md"
    else
      mkdir -p "$(dirname "$f")"
      { echo "Follow AGENTS.md at the repository root: the project's rules plus the playbook core below."; echo
        core_rules | sed -e "s#$TOKEN#.playbook#g"; } > "$f"; note "wrote  $f"
    fi
    for s in $(skills); do
      f="$dir/.github/prompts/$s.prompt.md"
      if [ -e "$f" ] && [ "$FORCE" -ne 1 ]; then note "kept   $f (exists)"; continue; fi
      mkdir -p "$(dirname "$f")"
      { printf -- '---\ndescription: %s\n---\n' "$(field "$ROOT/skills/$s/SKILL.md" description)"
        body "$ROOT/skills/$s/SKILL.md" | sed -e "s#$TOKEN#.playbook#g" -e 's#\$ARGUMENTS#${input:task}#g'
      } > "$f"; note "wrote  $f"
    done
  ;; esac

  cat <<EOF

Next:
  0. With the plugin (default): each person runs, once per machine, from the repo root:
       claude plugin marketplace add ./.playbook
     then starts a new Claude Code session (skills are /playbook:<name>).
  1. Fill "## 8. This project" in AGENTS.md (or run /playbook:bootstrap-project in Claude Code).$( [ -z "$tracker" ] && printf '\n     No --tracker given: add a "## Tracker" section (copy one from .playbook/trackers/).' )
  2. Add screenshots/, test-results/ and .claude/worktrees/ to .gitignore. Agents work in git worktrees: make sure
     .claude/settings.json has "worktree": { "baseRef": "head" } (the plugin route writes it), and copy
     .playbook/templates/worktreeinclude to .worktreeinclude (the gitignored files a worktree needs, e.g. .env).
  3. Commit .playbook/ with the project. Change a default in .playbook/local/<same path>; edits to the
     rest of .playbook/ are lost when it's updated with --force (local/ is never touched).
  4. Commit the tool files you want to share (.claude/, .cursor/, .github/).
EOF
}

install_user() {
  [ "${1:-}" = "--force" ] && FORCE=1
  local home="$HOME/.claude" s a
  echo "Installing skills and agents for every project into $home"
  copy_library "$home/playbook" "$home/playbook"
  for s in $(skills); do render "$ROOT/skills/$s/SKILL.md" "$home/skills/$s/SKILL.md" "$home/playbook"; done
  for a in $(agents); do render "$ROOT/agents/$a.md" "$home/agents/$a.md" "$home/playbook"; done
  cat <<EOF

Personal skills override a project's skills of the same name; project agents override personal ones.
To apply the working agreement everywhere, add this line to $home/CLAUDE.md:
  @$home/playbook/principles/00-working-agreement.md
EOF
}

build_prompts() {
  local out="${1:-$ROOT/dist/prompts}" s a f
  FORCE=1
  echo "Building plain prompts into $out"
  mkdir -p "$out/agents"
  for s in $(skills); do
    f="$out/$s.md"
    { echo "<!-- Paste into any AI assistant. Attach AGENTS.md and the playbook files it names, and replace [your task]. -->"
      body "$ROOT/skills/$s/SKILL.md" | sed -e "s#$TOKEN#playbook#g" -e 's#\$ARGUMENTS#[your task]#g'
    } > "$f"
  done
  for a in $(agents); do
    f="$out/agents/$a.md"
    { echo "<!-- A role prompt: paste as the system or first message, then give the task. -->"
      body "$ROOT/agents/$a.md" | sed -e "s#$TOKEN#playbook#g"
    } > "$f"
  done
  echo "  done: $(skills | wc -l | tr -d ' ') skill prompts, $(agents | wc -l | tr -d ' ') role prompts"
}

list() {
  local d
  echo "Stacks:";  for f in "$ROOT"/stacks/*.md; do [ -f "$f" ] && echo "  $(basename "$f" .md)"; done
  echo "Trackers:"; for f in "$ROOT"/trackers/*.md; do [ -f "$f" ] && echo "  $(basename "$f" .md)"; done
  echo "Starter files (templates/):"; for d in "$ROOT"/templates/*/; do [ -d "$d" ] && echo "  $(basename "$d")/: $(cd "$d" && ls | paste -sd ' ' -)"; done
  echo "Skills:";  for s in $(skills); do echo "  $s"; done
  echo "Agents:";  for a in $(agents); do echo "  $a"; done
}

cmd="${1:-}"; [ $# -gt 0 ] && shift
case "$cmd" in
  project) install_project "$@" ;;
  user) install_user "$@" ;;
  prompts) build_prompts "$@" ;;
  list) list ;;
  *) sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
esac
