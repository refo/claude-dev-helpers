#!/bin/bash
# Blocks destructive git operations from being executed by Claude Code.
# Registered as a PreToolUse hook for the Bash tool in .claude/settings.local.json.
# Exit code 2 = block the tool call and show the message to Claude.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('command',''))" 2>/dev/null || echo "")

DANGEROUS_PATTERNS=(
  "git push"
  "push --force"
  "push -f"
  "git reset --hard"
  "git clean -f"
  "git clean -fd"
  "git branch -D"
  "git checkout \."
  "git restore \."
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$pattern"; then
    echo "BLOCKED: '$COMMAND' matches dangerous pattern '$pattern'. The user has prevented you from running this. Ask the user to run it manually if truly needed." >&2
    exit 2
  fi
done

exit 0
