#!/usr/bin/env bash
# PreToolUse hook: general Bash command guard.
# Guards:
#   1. Raw sed/gsed — redirects to safe_sed wrapper
#   2. git commit with heredoc/$(cat <<EOF) — redirects to single-quoted multiline string

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty')
command=$(echo "$input" | jq -r '.tool_input.command // empty')

[[ "$tool_name" != "Bash" ]] && exit 0

# Allow if already using safe_sed
if echo "$command" | grep -q 'safe_sed'; then
    exit 0
fi

# Block raw sed/gsed — redirect to safe_sed (only when sed is the first token)
if echo "$command" | grep -qE '^g?sed[[:space:]]'; then
    printf '{"decision": "block", "reason": "Use ~/.claude/hooks/safe_sed instead of sed for read-only line extraction. Replace `sed -n` with `~/.claude/hooks/safe_sed` — it enforces -n automatically and is pre-approved."}\n'
    exit 0
fi

# Block git commit with heredoc/command-substitution — redirect to single-quoted multiline
# Only when git is the first token (avoids false positives from embedding in string args)
if echo "$command" | grep -qE '^git commit' && echo "$command" | grep -qE '\$\(cat|<<[[:space:]]*'"'"'?EOF'"'"'?'; then
    printf '{"decision": "block", "reason": "Use a single-quoted multi-line string instead of $(cat <<EOF...) for git commit messages. Write literal newlines inside single quotes: git commit -m '"'"'Subject line\\n\\nBody paragraph.\\n\\nCo-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>'"'"'"}\n'
    exit 0
fi

# Block raw git push — redirect to git-push-safe (no explicit remote/branch allowed)
if echo "$command" | grep -qE '^git push'; then
    printf '{"decision": "block", "reason": "Use ~/.claude/hooks/git-push-safe instead of git push directly. Supports all flags (e.g. --force-with-lease) but blocks explicit remote/branch args."}\n'
    exit 0
fi

exit 0
