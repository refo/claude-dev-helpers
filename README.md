# claude-dev-helpers

Personal Claude Code marketplace + plugin: stack-agnostic agentic dev workflow helpers.

## What's in here

This repo is a Claude Code [marketplace](https://docs.claude.com/en/docs/claude-code/plugins) containing one plugin so far:

- **`dev-helpers`** — slash commands for TDD, conventional commits, PRD writing, GitHub issue triage, pre-commit setup, design grilling, plus a `/init-helpers` bootstrapper that writes a per-project `.claude/helpers.json` so each command knows your stack.

## Install (any machine)

```text
/plugin marketplace add https://github.com/refo/claude-dev-helpers
/plugin install dev-helpers@refo
```

That's it. The slash commands are now available in every project on this machine. No per-project file copying.

## Use in a new project

The first time you `cd` into a repo where you want the helpers to be aware of the stack:

```text
/init-helpers
```

It inspects the repo's manifests, lockfiles, linter configs, and CLAUDE.md, then drafts a `.claude/helpers.json` for you to review and commit. Every other command in the plugin (`/commit`, `/tdd`, `/setup-pre-commit`, `/next-issue`, …) reads that file to tailor itself to the project's package manager, test runner, linter, commit conventions, and so on.

Without `helpers.json`, the commands fall back to detecting the stack on the fly — slightly less crisp but they still work.

## Commands shipped by `dev-helpers`

| Command | What it does |
|---|---|
| `/init-helpers` | Detect this repo's stack and draft `.claude/helpers.json`. Run once per project. |
| `/commit` | Stage + commit using conventional-commit format. Reads scope list and secrets blocklist from `helpers.json`. |
| `/tdd` | Red-green-refactor loop with vertical-slice discipline. Uses `commands.test` from `helpers.json`. |
| `/setup-pre-commit` | Install pre-commit hooks appropriate for the detected stack (husky/lefthook/pre-commit/native). |
| `/next-issue` | Pick the next unblocked GitHub issue in the active milestone and start the grill-then-implement flow. |
| `/grill-me` | Interview the user about a plan or design until every branch of the decision tree is resolved. |
| `/prd-to-issues` | Break a PRD into independently-grabbable issues using tracer-bullet vertical slices. |
| `/prd-to-plan` | Turn a PRD into an executable implementation plan. |
| `/write-a-prd` | Interview-driven PRD authoring. |
| `/triage-issue` | Triage and refine an open issue. |
| `/design-an-interface` | Design a public interface with deep-module discipline before writing code. |
| `/ubiquitous-language` | Build/maintain a project glossary of domain terms. |
| `/git-guardrails-claude-code` | Reminders about safe git operations for Claude Code sessions. |

## Hook shipped by `dev-helpers`

- **`block-dangerous-git.sh`** (PreToolUse on `Bash`) — blocks destructive git commands (`push --force`, `reset --hard`, `clean -f`, `branch -D`, `checkout .`, `restore .`) from being executed by the assistant. The user can still run them manually.

## `.claude/helpers.json` schema

See the example inside [`plugins/dev-helpers/commands/init-helpers.md`](plugins/dev-helpers/commands/init-helpers.md). Short version:

```json
{
  "stack": { "language": "...", "packageManager": "...", "runtime": "..." },
  "commands": { "test": "...", "typecheck": "...", "lint": "...", "format": "...", "build": "...", "dev": "..." },
  "doNotRun": ["..."],
  "commit": { "scopes": ["..."], "secretsBlocklist": ["..."], "trailer": "..." },
  "tooling": { "linter": "...", "preCommitFramework": "...", "testRunner": "...", "testFilePattern": "..." },
  "issueTracker": { "type": "github", "milestoneNamingConvention": null }
}
```

## Per-repo overrides

If a single project needs a bespoke version of a command, drop a file at `<repo>/.claude/commands/<name>.md` and it will shadow the plugin's copy.

## Layout

```
claude-dev-helpers/
├── README.md
├── .claude-plugin/
│   └── marketplace.json        ← marketplace manifest
└── plugins/
    └── dev-helpers/
        ├── .claude-plugin/
        │   └── plugin.json     ← plugin manifest
        ├── README.md
        ├── commands/           ← 13 slash commands
        └── hooks/
            ├── hooks.json
            └── block-dangerous-git.sh
```
