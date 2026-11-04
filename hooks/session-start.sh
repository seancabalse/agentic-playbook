#!/usr/bin/env bash
# Playbook plugin, SessionStart. Prints only in projects that use the playbook: where the plugin's files
# are (AGENTS.md can't know that path), and which files the project overrides in .playbook/local/, so
# skills read the project's copy instead. Prints nothing elsewhere.
project="${CLAUDE_PROJECT_DIR:-$PWD}"
root="${CLAUDE_PLUGIN_ROOT:-}"
local_dir="$project/.playbook/local"

if [ -n "$root" ] && grep -qi 'playbook' "$project/AGENTS.md" 2>/dev/null; then
  echo "The playbook plugin's files (principles/, templates/, stacks/, trackers/) are in $root."
fi

# Plugin sources are per machine. If the plugin is read from some project's .playbook/ (an older install),
# every project on this machine uses that copy. Tell the person how to point it back.
case "$root" in */.playbook)
  echo "Warning: the playbook plugin is read from a project's copy ($root), so every project on this machine uses it. Ask the person to remove that project's plugin source, then run: claude plugin marketplace remove agentic-playbook; claude plugin marketplace add <their clone, or seancabalse/agentic-playbook>; claude plugin install playbook@agentic-playbook --scope user."
;; esac

# A workspace is a folder whose AGENTS.md has "## 8. This workspace", holding the project's repositories.
# A session there is the lead; a session in a member repository (or a worktree inside one) learns who the lead is.
# On native Windows the path can have backslashes, which dirname doesn't split.
here="$(printf '%s' "$project" | tr '\\' '/')"
ws="$here"
while [ "$ws" != "/" ] && [ "$ws" != "." ] && ! grep -qs '^## 8\. This workspace' "$ws/AGENTS.md"; do ws="$(dirname "$ws")"; done
if grep -qs '^## 8\. This workspace' "$ws/AGENTS.md"; then
  rel="${here#"$ws"/}"
  if [ "$ws" = "$here" ]; then
    echo "This folder is a workspace with more than one repository (AGENTS.md, section 8). This session is the lead of the workspace. Follow the lead skill. Use SendMessage to send work to the member sessions. Keep docs/workspace/ up to date. Do not change files in the member repositories."
  # Only the repositories in the Members table are members; reference and other folders are not.
  elif grep -q "^| \`${rel%%/*}/\` |" "$ws/AGENTS.md"; then
    echo "This repository is a member of the workspace at $ws. When you complete a step, or when you cannot continue, send your handoff to the lead session (name: lead) with SendMessage. Also put the handoff on the ticket. The lead sends the next step. Do not send work to another member. The members and sessions of the workspace:"
    awk '/^## 8\. This workspace/ { s = 1 } s && /^### Rules/ { exit } s && /^\| / { print }' "$ws/AGENTS.md"
  fi
fi

[ -d "$local_dir" ] || exit 0
files=$(cd "$local_dir" && find . -type f ! -name '.*' | sed 's#^\./##' | sort)
[ -n "$files" ] || exit 0
echo "Playbook overrides: this project changes these playbook files. Wherever a skill, agent or AGENTS.md names one of them in the playbook, read .playbook/local/<same path> instead:"
echo "$files" | sed 's#^#- #'
