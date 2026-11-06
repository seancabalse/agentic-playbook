#!/usr/bin/env bash
# Install the engineering playbook. Claude Code reads it from the plugin, installed once per machine; a
# project gets an AGENTS.md built from the playbook's AGENTS.md plus the chosen stacks and tracker, and
# each tool's files. Cursor, Copilot and copied skills (--tools claude) read files in the repo, so they
# also get a copy as .playbook/; then ${CLAUDE_PLUGIN_ROOT} becomes .playbook in the files written.
#
#   playbook.sh project <dir> [--stack a,b] [--tracker linear|jira|github] [--tools plugin|claude,agents,cursor,copilot] [--force]
#   playbook.sh workspace [<dir>] [--force]  a workspace of several repositories: asks which folders belong to it
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

# copy_template DEST: the playbook's files, without generated files, the source project's own overrides,
# or the plugin manifest. The copy is never a plugin source: plugin sources are per machine, so a
# project's copy would replace the machine-wide install for every project.
copy_template() {
  local dest="$1"
  if [ "$(cd "$ROOT" && pwd)" = "$dest" ]; then note "kept   $dest (this is the template itself)"; return; fi
  if [ -e "$dest" ] && [ "$FORCE" -ne 1 ]; then note "kept   $dest (exists; --force to update, local/ is never touched)"; return; fi
  mkdir -p "$dest"
  rsync -a --exclude dist/ --exclude local/ --exclude .git --exclude .claude-plugin/ --exclude .DS_Store "$ROOT"/ "$dest"/
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
  local dir="" stacks="" tracker="" tools="plugin,agents" prefix='${CLAUDE_PLUGIN_ROOT}' s a f out
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

  # Cursor, Copilot and copied skills read the playbook from the repo, so they need a copy, committed with
  # the project (paths relative to the repo root, where agents run). The plugin needs none: without a copy,
  # AGENTS.md keeps ${CLAUDE_PLUGIN_ROOT}, and the plugin's session hook prints where that is.
  case ",$tools," in *,claude,*|*,cursor,*|*,copilot,*) copy_template "$dir/.playbook"; prefix=".playbook" ;; esac

  case ",$tools," in *,agents,*)
    out="$dir/AGENTS.md"
    if [ -e "$out" ] && [ "$FORCE" -ne 1 ]; then out="$dir/AGENTS.playbook.md"; note "AGENTS.md exists: merge AGENTS.playbook.md into it (project rules win)"; fi
    agents_md "$prefix" "$stacks" "$tracker" > "$out"; note "wrote  $out"
    if [ ! -e "$dir/CLAUDE.md" ]; then cp "$ROOT/templates/CLAUDE.md" "$dir/CLAUDE.md"; note "wrote  $dir/CLAUDE.md"
    elif ! grep -q '@AGENTS.md' "$dir/CLAUDE.md"; then note "CLAUDE.md exists without @AGENTS.md: add that line"; fi
  ;; esac

  case ",$tools," in *,plugin,*)
    # Claude Code loads the playbook from the plugin installed on each machine. The project only says
    # where agent worktrees start. It never registers a copy as a plugin source (see copy_template).
    f="$dir/.claude/settings.json"
    if [ -e "$f" ]; then
      grep -q '"baseRef"' "$f" || note "kept   $f (exists): add \"worktree\": { \"baseRef\": \"head\" }"
      grep -q '\./\.playbook' "$f" && note "WARNING $f registers ./.playbook as a plugin source: remove it and its enabledPlugins entry (it replaces the machine-wide install for every project)"
    else
      mkdir -p "$(dirname "$f")"
      printf '{\n  "worktree": { "baseRef": "head" }\n}\n' > "$f"
      note "wrote  $f (agent worktrees start from the current branch)"
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

  # The workspace setup prints its own next steps for all its repositories.
  [ "${PLAYBOOK_NO_NEXT:-0}" = 1 ] && return
  cat <<EOF

Next:
  0. Claude Code: each person installs the plugin once per machine (README, "Choosing how to install"),
     then starts a new session. Skills are /playbook:<name>.
  1. Fill "## 8. This project" in AGENTS.md (or run /playbook:bootstrap-project in Claude Code).$( [ -z "$tracker" ] && printf '\n     No --tracker given: add a "## Tracker" section (copy one from trackers/ in the playbook).' )
  2. Add screenshots/, test-results/ and .claude/worktrees/ to .gitignore. Agents work in git worktrees: make sure
     .claude/settings.json has "worktree": { "baseRef": "head" } (the plugin route writes it), and copy the
     playbook's templates/worktreeinclude to .worktreeinclude (the gitignored files a worktree needs, e.g. .env).
  3. Change a playbook default for this project in .playbook/local/<same path>, and commit it.$( [ "$prefix" = ".playbook" ] && printf '\n     Commit .playbook/ too. Edits outside local/ are lost when it is updated with --force.' )
  4. Commit the tool files you want to share (.claude/, .cursor/, .github/).
EOF
}

# ask VAR QUESTION DEFAULT: read one answer from stdin (so answers can be piped in); Enter keeps the default.
ask() {
  local reply=""
  printf '%s [%s]: ' "$2" "$3" >&2
  IFS= read -r reply || true
  printf -v "$1" '%s' "${reply:-$3}"
}
is_yes() { case "$1" in [Yy]*) return 0 ;; *) return 1 ;; esac; }

guess_role() {
  case "$(echo "$1" | tr 'A-Z' 'a-z')" in
    *front*|*web*|*client*|*ui|fe|fe-*|*-fe) echo frontend ;;
    *back*|*api*|*server*|*service*|be|be-*|*-be) echo backend ;;
    *) echo other ;;
  esac
}

# The stacks a repository's manifests suggest, limited to the stacks this branch has ("none" if no match).
infer_stacks() {
  local d="$1" found="" s out=""
  if [ -f "$d/nx.json" ]; then found="$found nx-monorepo"; fi
  if [ -f "$d/package.json" ]; then
    if grep -qE '"(react-dom|next|@remix-run/react|react-router)"' "$d/package.json"; then found="$found react-web"; fi
    if grep -qE '"(express|fastify|@nestjs/core|hono)"' "$d/package.json"; then found="$found node-service"; fi
  fi
  for s in $found; do if [ -f "$ROOT/stacks/$s.md" ]; then out="$out,$s"; fi; done
  out="${out#,}"; echo "${out:-none}"
}

# A workspace: this folder is a coordination repository (the lead session runs here) that holds the
# project's repositories as separate clones. Asks which folders belong to the project, then writes the
# workspace's AGENTS.md, CLAUDE.md, records and .gitignore, and sets up member repositories without an AGENTS.md.
install_workspace() {
  local ws="" a d name role s stacks tracker f line
  local members="" sessions="" refs="" ignores="" setup=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --force) FORCE=1; shift ;;
      *) [ -z "$ws" ] || die "unexpected argument '$1'"; ws="$1"; shift ;;
    esac
  done
  ws="${ws:-.}"
  [ -d "$ws" ] || die "usage: playbook.sh workspace [<existing dir>] [--force]"
  ws="$(cd "$ws" && pwd)"
  echo "Setting up a workspace in $ws. Press Enter to keep the answer in [brackets]."

  ask a "Is $ws the workspace (main) repository, where the lead session runs? (y/n)" y
  is_yes "$a" || die "stopped: run it in the workspace folder, or pass its path"
  if [ ! -e "$ws/.git" ]; then
    ask a "It isn't a git repository yet. Run git init? (y/n)" y
    if is_yes "$a"; then git -C "$ws" init -q; note "wrote  $ws/.git (git init)"; fi
  fi
  ask tracker "Tracker (linear, jira, github or none)?" none
  if [ "$tracker" = none ]; then tracker=""; fi
  [ -z "$tracker" ] || [ -f "$ROOT/trackers/$tracker.md" ] || die "unknown tracker '$tracker' (see: playbook.sh list)"

  sessions="| \`lead\` | this folder | \`claude -n lead\` |"
  for d in "$ws"/*/; do
    [ -d "$d" ] || continue
    name="$(basename "$d")"
    # The workspace's own records.
    if [ "$name" = docs ] && [ -d "$d/workspace" ]; then continue; fi
    if [ -e "$d/.git" ]; then
      ask a "Is $name/ (a git repository) part of the project? (y/n)" y
      is_yes "$a" || continue
      ask role "  Its role (frontend, backend or other)?" "$(guess_role "$name")"
      ask stacks "  Its stacks, comma-separated (see: playbook.sh list)?" "$(infer_stacks "$d")"
      if [ "$stacks" = none ]; then stacks=""; fi
      for s in $(echo "$stacks" | tr ',' ' '); do [ -f "$ROOT/stacks/$s.md" ] || die "unknown stack '$s' (see: playbook.sh list)"; done

      # One new session for each task; the lead gives the full command, with the task id.
      sessions="$sessions"$'\n'"| \`$name-<task id>\` | \`$name/\` | \`cd $name && claude -n $name-<task id>\` |"
      members="$members"$'\n'"| \`$name/\` | $role | ${stacks:-none} |"
      ignores="$ignores/$name/"$'\n'

      if [ -e "$d/AGENTS.md" ]; then
        note "kept   $name/AGENTS.md (exists; run /playbook:bootstrap-project there if section 8 isn't filled in)"
      else
        ask a "  $name/ has no AGENTS.md. Set it up with the playbook now? (y/n)" y
        if is_yes "$a"; then setup="$setup$name|$stacks"$'\n'; fi
      fi
    else
      case "$(echo "$name" | tr 'A-Z' 'a-z')" in ref|refs|reference*|spec*|design*) a=y ;; *) a=n ;; esac
      ask a "Is $name/ reference material that agents read but never change? (y/n)" "$a"
      if is_yes "$a"; then refs="$refs, \`$name/\`"; fi
    fi
  done
  [ -n "$members" ] || die "no repositories chosen: a workspace needs at least one member repository"
  refs="${refs#, }"

  # AGENTS.md: the playbook's sections 1–7 unchanged, the workspace's section 8, then the tracker section.
  f="$ws/AGENTS.md"
  if [ -e "$f" ] && [ "$FORCE" -ne 1 ]; then f="$ws/AGENTS.playbook.md"; note "AGENTS.md exists: merge AGENTS.playbook.md into it (the workspace's rules win)"; fi
  { core_rules
    M="| Repository | Role | Stacks |"$'\n'"| -- | -- | -- |$members" \
    S="| Session | Where | Start it with |"$'\n'"| -- | -- | -- |"$'\n'"$sessions" \
    R="${refs:-none}" awk '
      $0 == "<!-- members -->" { print ENVIRON["M"]; next }
      $0 == "<!-- sessions -->" { print ENVIRON["S"]; next }
      # Not sub(): a folder name can hold "&", which sub() reads as the matched text.
      (i = index($0, "<!-- references -->")) { $0 = substr($0, 1, i - 1) ENVIRON["R"] substr($0, i + length("<!-- references -->")) }
      { print }' "$ROOT/templates/workspace/AGENTS.md"
    if [ -n "$tracker" ]; then echo; cat "$ROOT/trackers/$tracker.md"; fi
  } > "$f"
  note "wrote  $f"
  if [ ! -e "$ws/CLAUDE.md" ]; then cp "$ROOT/templates/CLAUDE.md" "$ws/CLAUDE.md"; note "wrote  $ws/CLAUDE.md"
  elif ! grep -q '@AGENTS.md' "$ws/CLAUDE.md"; then note "CLAUDE.md exists without @AGENTS.md: add that line"; fi
  f="$ws/.claude/settings.json"
  if [ ! -e "$f" ]; then
    mkdir -p "$ws/.claude"; printf '{\n  "worktree": { "baseRef": "head" }\n}\n' > "$f"
    note "wrote  $f (agent worktrees start from the current branch)"
  fi

  # The lead's records. Never replaced, even with --force: they hold the workspace's history.
  mkdir -p "$ws/docs/workspace"
  for f in STATUS.md HANDOFFS.md DECISIONS.md; do
    if [ -e "$ws/docs/workspace/$f" ]; then note "kept   $ws/docs/workspace/$f"; continue; fi
    if [ "$f" = DECISIONS.md ]; then cp "$ROOT/templates/decision-log.md" "$ws/docs/workspace/$f"
    else cp "$ROOT/templates/workspace/$f" "$ws/docs/workspace/$f"; fi
    note "wrote  $ws/docs/workspace/$f"
  done

  # Member repositories keep their own history, so the workspace repository ignores them. Without a final
  # newline, the first added entry would join the file's last line, and neither would be ignored.
  if [ -s "$ws/.gitignore" ] && [ -n "$(tail -c 1 "$ws/.gitignore")" ]; then echo >> "$ws/.gitignore"; fi
  printf '%s\n' "$ignores" ".claude/worktrees/" | while IFS= read -r line; do
    [ -n "$line" ] || continue
    grep -qxF "$line" "$ws/.gitignore" 2>/dev/null && continue
    echo "$line" >> "$ws/.gitignore"; note "added  $line to $ws/.gitignore"
  done

  printf '%s' "$setup" | while IFS='|' read -r name stacks; do
    [ -n "$name" ] || continue
    echo
    if [ -n "$tracker" ]; then PLAYBOOK_NO_NEXT=1 install_project "$ws/$name" --stack "$stacks" --tracker "$tracker"
    else PLAYBOOK_NO_NEXT=1 install_project "$ws/$name" --stack "$stacks"; fi
  done

  cat <<EOF

Next:
  0. Claude Code: each person installs the plugin once per machine (README, "Choosing how to install").
     The lead skill and the session-start message that tells each session its role come from the plugin.
  1. Fill in "## 8. This workspace" in AGENTS.md: what it is, the PRD and the tracker project.
  2. In each member repository, run /playbook:bootstrap-project. It fills in that repository's section 8, adds
     .claude/worktrees/ to its .gitignore and sets up .worktreeinclude, which a second session's worktree needs.
  3. Start the lead (claude -n lead) and give it an epic: /playbook:lead <epic or ticket>. It divides the epic
     into tasks and gives you the command for a new session for each task. Run all sessions on the same
     side (all native, or all inside WSL): sessions can't message across.
  4. Close each task's session when the lead tells you. The lead keeps docs/workspace/ current.
  5. Commit AGENTS.md, CLAUDE.md, .gitignore, .claude/settings.json and docs/workspace/ on a branch.
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
  workspace) install_workspace "$@" ;;
  user) install_user "$@" ;;
  prompts) build_prompts "$@" ;;
  list) list ;;
  *) sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
esac
