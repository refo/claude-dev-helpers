# claude-dev-helpers

Personal Claude Code [marketplace](https://docs.claude.com/en/docs/claude-code/plugins) bundling a few plugins I use across projects.

## Plugins

| Plugin | What it is |
|---|---|
| [`dev-helpers`](plugins/dev-helpers/) | Stack-agnostic slash commands for TDD, conventional commits, PRD writing, GitHub issue triage, pre-commit setup, design grilling, plus an `/init-helpers` bootstrapper that writes a per-project `.claude/helpers.json`. Includes a `block-dangerous-git.sh` PreToolUse hook. |
| [`mp`](plugins/mp/) | [Matt Pocock's skills](https://github.com/mattpocock/skills), vendored verbatim via `git subtree` and exposed under the `mp:` namespace (`mp:tdd`, `mp:grill-me`, …). |

## Install

Add the marketplace once per machine, then install whichever plugins you want:

```text
/plugin marketplace add https://github.com/refo/claude-dev-helpers
/plugin install dev-helpers@refo
/plugin install mp@refo
```

## Adding another plugin to this repo

1. Scaffold under `plugins/<name>/`:
   - `.claude-plugin/plugin.json` — `name`, `version`, `description`, and pointers to `commands`, `skills`, or `hooks` directories as needed.
   - Plus whatever the plugin ships (e.g. `commands/`, `skills/<skill>/SKILL.md`, `hooks/`).
2. Register it by appending an entry to `.claude-plugin/marketplace.json`:
   ```json
   {
     "name": "<name>",
     "source": "./plugins/<name>",
     "description": "...",
     "version": "0.1.0",
     "category": "...",
     "tags": ["..."]
   }
   ```
3. For plugins vendored from another repo, prefer `git subtree --squash` so updates stay a one-liner. See `plugins/mp/README.md` for the exact `add` / `pull` commands.

## Per-repo overrides

A file at `<repo>/.claude/commands/<name>.md` shadows the plugin's copy of that command for that project.

## Credits

`dev-helpers`' commands started life as skills from [Matt Pocock's `mattpocock/skills`](https://github.com/mattpocock/skills) — adapted and generalized here. The `mp` plugin vendors that repo unchanged. Huge thanks to Matt.

## License

[MIT](LICENSE). `mattpocock/skills` is also MIT — preserve the notices in [`LICENSE`](LICENSE) and `plugins/mp/skills/LICENSE`.
