# Git Guardrails for Claude Code

This guide enables safety hooks that prevent Claude from executing destructive git operations. The setup intercepts dangerous commands like `git push`, `git reset --hard`, `git clean`, `git branch -D`, and `git checkout .` before execution.

## Installation Process

**Scope Selection**: First, determine whether to install guardrails for the current project only (`.claude/settings.json`) or globally across all projects (`~/.claude/settings.json`).

**Hook Placement**: Copy the blocking script from `scripts/block-dangerous-git.sh` to either `.claude/hooks/block-dangerous-git.sh` (project-level) or `~/.claude/hooks/block-dangerous-git.sh` (global), then make it executable.

**Configuration**: Add a PreToolUse hook entry to your settings file that targets the Bash tool and references the script location using the appropriate path variable.

**Customization**: After installation, you can modify which git commands are blocked by editing the script directly.

**Testing**: Verify functionality by piping a sample git command through the script — it should return exit code 2 with a blocking message.

The hook prevents Claude from accessing these operations while remaining transparent about why commands cannot execute.
