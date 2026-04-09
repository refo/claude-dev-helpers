---
name: commit
description: Create a git commit with conventional commit message format
argument-hint: [message | --amend]
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git commit:*), Read
---

# Commit

## Context

- Branch: !`git branch --show-current`
- Status: !`git status`
- Staged and unstaged diff: !`git diff HEAD`
- Recent commits (for style reference): !`git log --oneline -10`
- Project helpers config (if present): !`cat .claude/helpers.json 2>/dev/null || echo "no helpers.json — fall back to inferring scope from changed paths and use a generic secrets blocklist"`

## Arguments

User provided: $ARGUMENTS

## Instructions

Create a single git commit for the changes shown above.

### Commit message format

Use Conventional Commits: `type(scope): description`

Types: feat, fix, refactor, chore, docs, style, test, perf, ci, build

**Scope selection:**
- If `helpers.json` defines `commit.scopes`, pick the most appropriate one from that list based on the changed paths.
- Otherwise, infer a short scope from the dominant changed area (e.g. directory name, package name, top-level module).
- If changes span multiple scopes, omit the scope or use the dominant one.

Rules:
- Subject line under 72 characters, lowercase, no period.
- Use imperative mood ("add feature" not "added feature").
- Add a blank line + body only when the "why" isn't obvious from the subject.
- Match the style of recent commits shown above.
- If `helpers.json` defines `commit.trailer`, append it after a blank line. Otherwise, append `Co-Authored-By: Claude <noreply@anthropic.com>`.

### Argument handling

- No arguments: auto-generate message from diff.
- `--amend`: amend the previous commit instead of creating a new one.
- Any other text: use it as the commit subject line (still add trailer).

### Staging

- If there are unstaged changes and nothing is staged: stage all modified/new files with `git add -A`.
- If some files are already staged: commit only the staged files (do not add unstaged changes).
- **Never stage files matching the project's secrets blocklist.** Read `commit.secretsBlocklist` from `helpers.json` if present. If not present, use this default: `.env*`, `.env.*`, `credentials*`, `secrets*`, `*.key`, `*.pem`, `*.p12`, `*.pfx`, `id_rsa*`, `*.sqlite`, `*.sqlite3`, `*.db`.

### Execution

Stage (if needed) and commit in a single response. Use HEREDOC for the commit message. Do not output any text besides the tool calls.
