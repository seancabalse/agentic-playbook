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

[ -d "$local_dir" ] || exit 0
files=$(cd "$local_dir" && find . -type f ! -name '.*' | sed 's#^\./##' | sort)
[ -n "$files" ] || exit 0
echo "Playbook overrides: this project changes these playbook files. Wherever a skill, agent or AGENTS.md names one of them in the playbook, read .playbook/local/<same path> instead:"
echo "$files" | sed 's#^#- #'
