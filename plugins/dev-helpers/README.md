# dev-helpers

Stack-agnostic agentic dev workflow helpers for Claude Code.

See the [top-level README](../../README.md) for installation and usage. This file is what shows up when someone browses the plugin source directly.

## Design

The plugin ships **generic** slash commands. Per-project knobs live in `<repo>/.claude/helpers.json`, written by the `/init-helpers` command. Commands read from that file at runtime so the same plugin code works across every stack the assistant can recognize.

If `helpers.json` is missing, commands fall back to inferring values from the repo's manifests/lockfiles. They still work — they're just slightly less crisp.

## Why a plugin instead of copying files

- One `git push` to update; one `/plugin update` to receive updates on any machine.
- Per-repo overrides still work: `<repo>/.claude/commands/<name>.md` shadows the plugin copy.
- Adds zero files to the consumer repo (other than the optional `helpers.json`).

## Adding a new command

1. Drop `<name>.md` into `commands/`. Use frontmatter (`name`, `description`, optionally `argument-hint`, `allowed-tools`).
2. If the command needs project-specific values, read them from `.claude/helpers.json` via a context line: `!`cat .claude/helpers.json 2>/dev/null || echo "(no helpers.json)"``.
3. If you add a new field to `helpers.json`, update the schema example in `commands/init-helpers.md` so `/init-helpers` writes it for new projects.
4. Bump the version in `.claude-plugin/plugin.json` and the marketplace entry.
