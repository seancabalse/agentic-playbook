#!/usr/bin/env bash
# Playbook plugin, PreToolUse on Bash. Blocks two things the working agreement forbids (AGENTS.md section 5):
#   1. AI attribution in commit messages and PR text (git commit, gh pr create/edit).
#   2. Secrets in the changes a `git commit` would record.
# Exit 2 blocks the command and shows the message to Claude. It never prints a secret's value.
# Opt-outs, per project: .playbook/local/allow-ai-attribution (empty file) turns off check 1;
# .playbook/local/secret-scan-allow lists paths (one per line) that check 2 skips.
input="$(cat)"

# `git commit`, also with options before the subcommand (`git -C path commit`, `git -c key=value commit`).
GIT_COMMIT='git([[:space:]]+-[^[:space:]]+([[:space:]]+[^-[:space:]][^[:space:]]*)?)*[[:space:]]+commit([[:space:]]|$)'
is_commit() { printf '%s' "$input" | grep -qE "$GIT_COMMIT"; }
is_commit || printf '%s' "$input" | grep -qE 'gh[[:space:]]+pr[[:space:]]+(create|edit)' || exit 0

# The folder the command runs in (a worktree session has its own).
cwd="$(printf '%s' "$input" | sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"
cwd="${cwd:-${CLAUDE_PROJECT_DIR:-$PWD}}"
root="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || printf '%s' "$cwd")"
local_dir="$root/.playbook/local"

# 1. AI attribution
if [ ! -e "$local_dir/allow-ai-attribution" ] &&
   printf '%s' "$input" | grep -qiE 'co-authored-by:[^"]*(claude|anthropic)|generated with \[?claude|noreply@anthropic\.com'; then
  echo "Blocked by the playbook: commits and PRs in this project carry no AI attribution (AGENTS.md section 5)." >&2
  echo "Remove the Co-Authored-By / \"Generated with\" line and run the command again." >&2
  echo "If the project wants attribution, create .playbook/local/allow-ai-attribution." >&2
  exit 2
fi

# 2. Secrets, only for commits
is_commit || exit 0

allow="$local_dir/secret-scan-allow"
allowed() { [ -f "$allow" ] && grep -qxF "$1" "$allow"; }

diff_args="--cached"
printf '%s' "$input" | grep -qE "commit([[:space:]]+[^[:space:]]+)*[[:space:]]+(-a|--all|-[a-zA-Z]*a[a-zA-Z]*)([[:space:]]|$)" && diff_args="HEAD"

findings=""
# Files that should never be committed.
while IFS= read -r f; do
  [ -n "$f" ] || continue
  allowed "$f" && continue
  case "$f" in
    *.env.example | *.env.sample | *.env.template) ;;
    .env | .env.* | */.env | */.env.* | *.pem | *.p12 | *.pfx | *.key | *id_rsa | *id_ed25519 | *.keystore | *.jks)
      findings="$findings\n- $f: a secrets or key file" ;;
  esac
done < <(git -C "$root" diff $diff_args --name-only --diff-filter=AM 2>/dev/null)

# Added lines that look like credentials. Only the file, line number and kind are reported.
patterns='PRIVATE KEY:-----BEGIN [A-Z ]*PRIVATE KEY-----
AWS access key:AKIA[0-9A-Z]{16}
GitHub token:(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9]{36,}
GitHub token:github_pat_[A-Za-z0-9_]{50,}
Slack token:xox[abprs]-[A-Za-z0-9-]{10,}
Stripe live key:(sk|rk)_live_[A-Za-z0-9]{20,}
Anthropic API key:sk-ant-[A-Za-z0-9_-]{20,}
OpenAI API key:sk-(proj-)?[A-Za-z0-9_-]{32,}
Supabase secret key:sb_secret_[A-Za-z0-9_-]{20,}'
current=""; line=0
while IFS= read -r l; do
  case "$l" in
    "+++ b/"*) current="${l#+++ b/}"; continue ;;
    "@@ "*) line="$(printf '%s' "$l" | sed -n 's/^@@ -[0-9,]* +\([0-9]*\).*/\1/p')"; continue ;;
    "+"*) ;;
    *) continue ;;
  esac
  allowed "$current" && { line=$((line + 1)); continue; }
  while IFS= read -r p; do
    kind="${p%%:*}"; re="${p#*:}"
    if printf '%s' "${l#+}" | grep -qE -- "$re"; then findings="$findings\n- $current:$line: looks like: $kind"; break; fi
  done <<< "$patterns"
  line=$((line + 1))
done < <(git -C "$root" diff $diff_args -U0 --no-color 2>/dev/null)

if [ -n "$findings" ]; then
  echo "Blocked by the playbook: the commit would include what looks like a secret (AGENTS.md section 5)." >&2
  printf '%b\n' "${findings#\\n}" >&2
  echo "Remove it from the commit (keep secrets in the environment or the secret store); the owner rotates any secret that was ever pushed." >&2
  echo "A false positive? Add the path to .playbook/local/secret-scan-allow (one path per line)." >&2
  exit 2
fi
exit 0
