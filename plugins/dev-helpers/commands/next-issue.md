---
name: next-issue
description: Pick up the next open GitHub issue (or a specific one by number) and start the grill-then-implement flow
argument-hint: [issue-number]
allowed-tools: Bash(gh issue:*), Bash(gh label:*), Bash(gh pr:*), Bash(gh api:*), Bash(git:*), Read, Write, Edit, Glob, Grep
---

# Next Issue

## Context

- Project helpers config (if present): !`cat .claude/helpers.json 2>/dev/null || echo "no helpers.json — proceed with generic defaults; do not run any dev/watch processes unless the user asks"`
- Current active milestone: !`gh api 'repos/{owner}/{repo}/milestones?state=open&sort=due_on&direction=asc' --jq '.[0].title // "no open milestone"'`
- Open issues in current milestone: !`gh api 'repos/{owner}/{repo}/milestones?state=open&sort=due_on&direction=asc' --jq '.[0].title' | xargs -I {} gh issue list --milestone {} --state open --json number,title,labels --jq '.[] | "#\(.number) [\(.labels | map(.name) | join(","))] \(.title)"'`
- Closed issues in current milestone (for dependency tracking): !`gh api 'repos/{owner}/{repo}/milestones?state=open&sort=due_on&direction=asc' --jq '.[0].title' | xargs -I {} gh issue list --milestone {} --state closed --json number --jq '.[] | "#\(.number)"'`
- Current branch: !`git branch --show-current`
- Working tree status: !`git status --short`

## Arguments

User provided: $ARGUMENTS

## Instructions

This is a session-starter skill. Its purpose is to load an issue into context and begin the grill-then-implement flow. **Decisions first, code second.**

### 1. Pick the issue

- **If an issue number was provided as an argument** (e.g. `5`, `#5`, or `3`): use that issue. Run `gh issue view <number>` to load its full body.
- **If no argument was provided**: pick the lowest-numbered open issue in the current milestone whose dependencies are all closed.
  - Look at each candidate issue's "Depends on" section (referenced issue numbers like `#1`, `#4`).
  - If any referenced issue is still open, the candidate is blocked — skip it.
  - Use the first unblocked one.
  - If all open issues are blocked, tell the user which blocker(s) are in the way and stop.

### 2. Announce the pick

Show the user:
- Issue number and title
- Labels (area / module / kind)
- A one-line summary of what this issue is about

### 3. Load the full body and surface design questions

Run `gh issue view <number>` to get the full body. Read the "Design questions to resolve" section. List each open decision explicitly — these are what need the user's input before any code is written.

If the issue has no design questions section, or all its questions can be answered from memory/policy/existing code, say so and proceed to step 5.

### 4. Grill on design questions, one at a time

Follow the same pattern as the `grill-me` skill:

- Ask **one focused question** at a time with context about why it matters.
- Provide a **clear recommendation** based on the helpers config, existing memories, code conventions, and common practice.
- Wait for the user's answer before moving to the next question.
- If the user answers ambiguously or points out something you missed, refine and re-ask.

Do not batch questions. Do not implement anything yet.

### 5. Implement

Once every design question is resolved, implement the issue:

- Follow the dependency order described in the issue body.
- Reuse existing patterns from the codebase (check imports, existing files, conventions).
- Respect project memories and the helpers config.
- **Typecheck before committing** using `commands.typecheck` from `helpers.json` if present (otherwise infer the project's typecheck command from `package.json`/`pyproject.toml`/etc., or skip if the project has no static typecheck).
- **Do not run any command listed in `doNotRun`** in `helpers.json` (typically dev/watch servers the user keeps running themselves).

### 6. Commit

Use the conventional commit format from the `commit` skill, and **include the issue number** so the issue tracker links the commit to the issue:

```
<type>(<scope>): <description> (#<issue-number>)
```

### 7. Offer to close the issue

After committing, offer:
- `gh issue close <number> --comment "Resolved in <commit-sha>"` — close it now
- OR: leave it open for the user to verify manually

Do NOT close automatically. Always confirm.

### 8. Suggest what's next

Show which issue would be unblocked next. Example:
- "Closing #1 unblocks #4, #5, and #10. Run `/next-issue` to continue."

## Guardrails

- **Decisions first, code second.** Never implement before design questions are resolved.
- **Don't pick blocked issues.** Dependency-aware selection matters.
- **Don't close issues without confirmation.** Even if the work is done.
- **Respect `doNotRun`** from `helpers.json` — these are commands the user manages themselves (typically dev servers, watchers).
- **Check memories** before proposing — feedback memories override generic defaults.
- **If the active milestone has no remaining open issues**, tell the user the milestone is complete and suggest planning the next one (don't auto-create).
