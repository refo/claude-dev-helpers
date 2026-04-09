---
name: init-helpers
description: Detect this project's stack and write a draft .claude/helpers.json so the rest of the dev-helpers plugin commands know how to behave. Run once per repo after installing the plugin.
allowed-tools: Read, Write, Glob, Grep, Bash(ls:*), Bash(git:*), Bash(cat:*), Bash(test:*), Bash(mkdir:*)
---

# Init Helpers

## Context

- Existing helpers config: !`cat .claude/helpers.json 2>/dev/null || echo "(none — this is a fresh project)"`
- Working directory: !`pwd`
- Top-level files: !`ls -1`
- Git remote (if any): !`git remote get-url origin 2>/dev/null || echo "(no git remote)"`
- Top of CLAUDE.md (if any): !`head -40 CLAUDE.md 2>/dev/null || echo "(no CLAUDE.md)"`

## Purpose

This command bootstraps `<repo>/.claude/helpers.json` — the per-project config file that the rest of the `dev-helpers` plugin commands (`commit`, `next-issue`, `tdd`, `setup-pre-commit`, etc.) read to tailor their behavior to *this specific project*.

You only need to run it **once per repo**, after installing the `dev-helpers` plugin. Re-run it if the project's stack changes (e.g. switched package manager, added a new linter, moved issue trackers).

## What you (the assistant) must do

### 1. Bail out gracefully if helpers.json already exists

If `.claude/helpers.json` is already present in the project (see Context above):

- Show the user the current contents.
- Ask: "A helpers.json already exists. Do you want to (a) leave it alone, (b) review and update fields, or (c) regenerate from scratch?"
- Wait for their answer. Do NOT overwrite without explicit confirmation.

### 2. Detect the stack from project files

You have full access to the working directory. Inspect it thoroughly:

- **Manifests and lockfiles** to identify language + package manager:
  `package.json`, `bun.lock`, `bun.lockb`, `pnpm-lock.yaml`, `yarn.lock`, `package-lock.json`, `pyproject.toml`, `uv.lock`, `poetry.lock`, `requirements.txt`, `Pipfile`, `go.mod`, `Cargo.toml`, `Gemfile`, `mix.exs`, `composer.json`, `pubspec.yaml`, `build.gradle*`, `pom.xml`, `*.csproj`, `*.fsproj`, `*.sln`, `flake.nix`, `Justfile`, `Makefile`.
- **Linter / formatter configs**:
  `biome.json`, `.eslintrc*`, `.prettierrc*`, `ruff.toml`, `.rubocop.yml`, `rustfmt.toml`, `clippy.toml`, `.editorconfig`.
- **Test configs**: `vitest.config.*`, `jest.config.*`, `playwright.config.*`, `pytest.ini`, `tox.ini`, presence of `*.test.ts`, `test_*.py`, `*_test.go`, `spec/` directory, etc.
- **Pre-commit / git-hook configs**: `.husky/`, `.pre-commit-config.yaml`, `lefthook.yml`/`.yaml`, `.git/hooks/pre-commit`.
- **Issue tracker hints**: git remote host (GitHub / GitLab / Bitbucket), `.github/` directory, references in `CLAUDE.md`.
- **CLAUDE.md** for any project-specific rules already documented (commit scope conventions, "don't run X" rules, naming conventions).
- **`package.json` `scripts` section** (or equivalent) for `test`, `typecheck`, `lint`, `format`, `dev`, `build` script names.

You don't need to run any commands beyond reading files. Use `Read`, `Glob`, and `Grep`. Reach for `WebSearch` only if you encounter an exotic stack you genuinely don't recognize from training.

### 3. Draft a helpers.json

Build a draft using the schema below. Fill in every field you can reasonably infer. For fields you can't infer, leave them as `null` or omit them — do not fabricate values.

```jsonc
{
  "$schema": "https://raw.githubusercontent.com/refo/claude-dev-helpers/main/schemas/helpers.schema.json",
  "stack": {
    "language": "typescript",          // primary language: typescript, javascript, python, go, rust, ruby, elixir, php, java, csharp, ...
    "packageManager": "bun",           // bun, pnpm, npm, yarn, uv, poetry, pip, cargo, go, bundler, mix, composer, ...
    "runtime": "bun"                   // bun, node, deno, python, go, rust, ruby, beam, jvm, dotnet, ...
  },
  "commands": {
    "test": "bun test",                // command to run the full test suite
    "testWatch": "bun test --watch",   // watch mode
    "typecheck": "bun run typecheck",  // null if the language has no static typecheck
    "lint": "bunx biome check",        // linter
    "format": "bunx biome format --write",
    "build": "bun run build",          // null if not applicable
    "dev": "bun run dev"               // dev/watch server, if any
  },
  "doNotRun": [
    "bun run dev"                      // commands the assistant must NEVER start; usually long-running watchers the user runs themselves
  ],
  "commit": {
    "scopes": ["api", "web", "docs"],  // allowed conventional-commit scopes; null if scopes are free-form
    "secretsBlocklist": [              // file patterns the commit skill must never stage
      ".env*",
      ".env.*",
      "credentials*",
      "secrets*",
      "*.key",
      "*.pem",
      "*.sqlite",
      "*.sqlite3",
      "*.db"
    ],
    "trailer": "Co-Authored-By: Claude <noreply@anthropic.com>"
  },
  "tooling": {
    "linter": "biome",                 // biome, eslint, prettier, ruff, rubocop, gofmt, rustfmt, ...
    "preCommitFramework": "husky",     // husky, lefthook, pre-commit, native, none
    "testRunner": "bun-test",          // bun-test, vitest, jest, pytest, go-test, cargo-test, ...
    "testFilePattern": "*.test.ts"     // glob pattern for test files in this project
  },
  "issueTracker": {
    "type": "github",                  // github, gitlab, linear, jira, none
    "milestoneNamingConvention": null  // free-form string the user uses for milestone names, e.g. "M1", "v0.2", "Sprint 14"
  }
}
```

### 4. Show the draft to the user and ask for confirmation

Render the draft in a code block. Then explicitly call out:

- Anything you **inferred with low confidence** (e.g. "I'm guessing the linter is biome because `biome.json` exists, but I see `.eslintrc.json` too — which one is active?").
- Anything you **left as `null`** (e.g. "I left `commit.scopes` as null because I couldn't tell what scopes you use — what should they be?").
- Anything that **looked unusual** in the project that the user should sanity-check.

Ask: "Does this look right? Should I write it as-is, or do you want to change anything first?"

### 5. Write the file

Once the user confirms (or asks for edits and you've applied them):

- Make sure `.claude/` exists (`mkdir -p .claude`).
- Write the final JSON to `.claude/helpers.json`.
- Use real JSON, not JSONC — strip the `//` comments from the example above before writing.

### 6. Suggest follow-ups

After writing, suggest:

- Add `.claude/helpers.json` to git (`git add .claude/helpers.json`) so the whole team picks up the same config.
- If the project uses any of the commands that read this file (`commit`, `next-issue`, `tdd`, `setup-pre-commit`), mention which ones will now have project-tailored behavior.
- If `helpers.json` says `tooling.preCommitFramework` is set but no pre-commit is actually installed yet, suggest running `/setup-pre-commit`.

## Guardrails

- **Never overwrite an existing `helpers.json` without explicit user confirmation.**
- **Never fabricate fields you can't infer.** `null` is a valid answer.
- **Never run shell commands beyond reading files** (`ls`, `cat`, `git remote get-url`). This is a detection command, not an installer.
- **Don't assume English-language conventions for everything** — if the project's CLAUDE.md or commit history is in another language, mirror that in your suggestions.
