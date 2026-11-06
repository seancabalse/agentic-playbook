#!/usr/bin/env bash
# Playbook plugin: tells a session when its branch falls behind the team branch (main or dev), and which
# files a rebase onto it would conflict in, so the agent syncs before conflicts grow. It never changes the
# branch; the sync-branch skill does that.
#   SessionStart: one line whenever the branch is behind.
#   PreToolUse on `git commit` / `git push`: only when a conflict is predicted, or the branch is far behind.
# Compared with: the branch's own base (`git config branch.<name>.playbookBase`, for a branch stacked on an
# unmerged task), else the team branch (`git config playbook.integrationBranch`), else origin/HEAD, main or master.
input="$(cat)"
field() { printf '%s' "$input" | sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -1; }
event="$(field hook_event_name)"
# SessionStart adds plain stdout to the context; PreToolUse needs additionalContext, which never blocks.
say() {
  if [ "$event" = PreToolUse ]; then
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"%s"}}\n' \
      "$(printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')"
  else
    echo "$1"
  fi
}

if [ "$event" = PreToolUse ]; then
  # A `git … commit` or `git … push` in the command (also `git -C "a b" push`, and `git push` at its end or before
  # `;`). A false match only costs a check: this hook never blocks.
  cmd="$(printf '%s' "$input" | sed -nE 's/.*"command"[[:space:]]*:[[:space:]]*"((\\.|[^"\\])*)".*/\1/p' | head -1)"
  printf '%s' "$cmd" | grep -qE '(^|[^[:alnum:]_./-]|\\[nt])git[[:space:]]([^;&|]*[[:space:]])?(commit|push)([^[:alnum:]_-]|$)' || exit 0
fi

# Native Windows: JSON-escaped backslashes (C:\\Users) become forward slashes, which git accepts.
cwd="$(field cwd | sed -e 's/\\\\/\//g' -e 's/\\/\//g')"; cwd="${cwd:-${CLAUDE_PROJECT_DIR:-$PWD}}"
root="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)" || exit 0
grep -qi 'playbook' "$root/AGENTS.md" 2>/dev/null || exit 0
branch="$(git -C "$root" symbolic-ref --quiet --short HEAD)" || exit 0
team="$(git -C "$root" config playbook.integrationBranch)"
[ -n "$team" ] || team="$(git -C "$root" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)"
team="${team#origin/}"
if [ -z "$team" ]; then
  for b in main master; do git -C "$root" rev-parse --verify --quiet "origin/$b" >/dev/null && { team="$b"; break; }; done
fi
[ -n "$team" ] && [ "$branch" != "$team" ] || exit 0

# Fetch at most every 2 minutes, in the background, and wait at most 5 s: never wait for a password, a
# credential window or a dead connection (git has no HTTP connect timeout). A slow fetch finishes on its own
# and the next check uses it; this one compares with the last fetch. The explicit refspec also works in
# single-branch clones.
gitdir="$(git -C "$root" rev-parse --absolute-git-dir)"
if [ -z "$(find "$gitdir/FETCH_HEAD" -mmin -2 2>/dev/null)" ]; then
  ssh_cmd="${GIT_SSH_COMMAND:-$(git -C "$root" config core.sshCommand || echo ssh)}"
  GIT_TERMINAL_PROMPT=0 GCM_INTERACTIVE=never GIT_HTTP_LOW_SPEED_LIMIT=1000 GIT_HTTP_LOW_SPEED_TIME=5 \
  GIT_SSH_COMMAND="$ssh_cmd -o BatchMode=yes -o ConnectTimeout=5" \
    git -C "$root" fetch --quiet origin "+refs/heads/$team:refs/remotes/origin/$team" </dev/null >/dev/null 2>&1 &
  pid=$!; i=0
  while kill -0 "$pid" 2>/dev/null && [ "$i" -lt 10 ]; do sleep 0.5; i=$((i + 1)); done
fi
git -C "$root" rev-parse --verify --quiet "origin/$team" >/dev/null || exit 0
up="origin/$team"

# A branch stacked on another task's unmerged branch is compared with that branch (local: worktrees share
# refs). When the merge of that branch into the team branch changes nothing, it is merged (also squashed).
base="$(git -C "$root" config "branch.$branch.playbookBase")"
if [ -n "$base" ] && git -C "$root" rev-parse --verify --quiet "$base" >/dev/null; then
  merged="$(git -C "$root" merge-tree --write-tree "$up" "$base" 2>/dev/null | head -1)"
  if [ "$merged" = "$(git -C "$root" rev-parse "$up^{tree}")" ]; then
    say "Playbook: the base of branch $branch ($base) is merged into $up. Run the sync-branch skill (section 7) to move your commits onto $up."
    exit 0
  fi
  up="$base"
fi
behind="$(git -C "$root" rev-list --count "HEAD..$up")"
[ "$behind" -gt 0 ] || exit 0
if [ "$behind" -eq 1 ]; then n="1 commit"; else n="$behind commits"; fi

# A merge of the committed work with the team branch, in memory: exit 1 lists the conflicting files.
files="$(git -C "$root" merge-tree --write-tree --name-only --no-messages HEAD "$up" 2>/dev/null)"
rc=$?
if [ "$rc" -gt 1 ]; then
  # Old git (merge-tree --write-tree needs 2.38), unrelated or shallow history.
  [ "$event" = SessionStart ] || exit 0
  msg="Playbook: branch $branch is $n behind $up. The playbook could not predict conflicts here (git merge-tree exit $rc; it needs git 2.38 or later and the full history). Run the sync-branch skill before you start."
elif [ "$rc" -eq 1 ]; then
  files="$(printf '%s\n' "$files" | sed 1d | sort -u | paste -sd ',' - | sed 's/,/, /g')"
  msg="Playbook: branch $branch is $n behind $up, and a rebase onto it would conflict in: $files. Run the sync-branch skill now, before you continue."
elif [ "$event" = SessionStart ]; then
  msg="Playbook: branch $branch is $n behind $up (no conflict predicted). Run the sync-branch skill before you start, so that you build on the current code."
elif [ "$behind" -ge 50 ]; then
  msg="Playbook: branch $branch is $n behind $up (no conflict predicted). Run the sync-branch skill at your next clean point."
else
  exit 0
fi

say "$msg"
