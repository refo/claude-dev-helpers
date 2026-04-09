---
name: setup-pre-commit
description: Set up pre-commit hooks appropriate for this project's stack (lint + format + typecheck + tests). Use when user wants to add pre-commit hooks or commit-time quality checks.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Setup Pre-Commit

## Context

- Project helpers config (if present): !`cat .claude/helpers.json 2>/dev/null || echo "no helpers.json — detect stack from project files"`
- Lockfiles and manifests: !`ls -1 package.json bun.lock bun.lockb pnpm-lock.yaml yarn.lock package-lock.json pyproject.toml uv.lock poetry.lock requirements.txt go.mod Cargo.toml Gemfile mix.exs composer.json 2>/dev/null || true`
- Existing config files: !`ls -1 biome.json .eslintrc* .prettierrc* ruff.toml .pre-commit-config.yaml lefthook.yml lefthook.yaml .husky 2>/dev/null || true`

## Goal

Install a pre-commit hook that runs (in this order):

1. **Format + lint** on staged files
2. **Typecheck** (if the language has one)
3. **Tests** (fast subset if possible, otherwise full suite)

The goal is to **catch bad commits before they happen**, without slowing down `git commit` so much that the user starts using `--no-verify`.

## Process

### 1. Detect the stack and pick the right tools

Read `helpers.json` first. If present, use the values from `tooling.preCommitFramework`, `tooling.linter`, `commands.test`, `commands.typecheck`, `commands.lint`, `commands.format`. Skip detection.

Otherwise, detect from the project files shown in Context above and pick the conventional stack:

| Detected | Pre-commit framework | Linter / Formatter | Typecheck | Test |
|---|---|---|---|---|
| `bun.lock(b)` | husky | biome | `tsc --noEmit` (via `bun run typecheck`) | `bun test` |
| `pnpm-lock.yaml` | husky + lint-staged | biome or eslint+prettier | `tsc --noEmit` | `pnpm test` |
| `yarn.lock` / `package-lock.json` | husky + lint-staged | eslint + prettier (or biome) | `tsc --noEmit` | `npm test` / `yarn test` |
| `pyproject.toml` + `uv.lock` | `pre-commit` framework | ruff (lint + format) | mypy or pyright (if configured) | `pytest` |
| `pyproject.toml` + `poetry.lock` | `pre-commit` framework | ruff or black + flake8 | mypy or pyright | `pytest` |
| `go.mod` | lefthook (or native git hooks) | `gofmt`, `go vet`, `golangci-lint` | `go build ./...` | `go test ./...` |
| `Cargo.toml` | lefthook (or native git hooks) | `cargo fmt`, `cargo clippy` | `cargo check` | `cargo test` |
| `Gemfile` | overcommit or `pre-commit` | rubocop | (none — Ruby) | `bundle exec rspec` |
| `mix.exs` | native git hooks | `mix format`, `credo` | `mix dialyzer` (if installed) | `mix test` |

If the stack doesn't match any of the above, **ask the user** what tooling they want before proceeding. Don't guess.

### 2. Confirm with the user

Before installing anything, show the user:

- The stack you detected (or read from `helpers.json`)
- The pre-commit framework you propose
- The exact list of checks the hook will run
- Any new dev dependencies you'd need to install

Wait for confirmation. The user may want to skip tests, swap a linter, or change the framework.

### 3. Install

Install the pre-commit framework using the project's package manager:

- **husky** (JS/TS): `<pm> add -d husky`, then `<pm>x husky init`
- **lefthook**: install via the appropriate package manager (`brew`, `npm`, `cargo`, etc.) or as a project dev dep
- **pre-commit framework** (Python): `uv add --dev pre-commit` or `pip install pre-commit` → `pre-commit install`
- **native git hooks**: write directly to `.git/hooks/pre-commit` and `chmod +x`

Then create the hook script (or config file) with the checks decided in step 2.

### 4. Verify

- Confirm the hook file exists and is executable.
- Run each check command manually once to make sure they pass on the current tree before the next commit.
- Make a trivial test commit to verify the hook fires (or use the framework's dry-run mode if available).

### 5. Commit the setup

Stage only the new pre-commit config files, the manifest changes (e.g. `package.json`, `pyproject.toml`), and any newly generated config (`biome.json`, `.pre-commit-config.yaml`, `lefthook.yml`, etc.).

Use the `commit` skill to write a conventional commit message — typically `chore: add pre-commit hooks`.

## Guardrails

- **Don't install Prettier alongside Biome**, or ESLint alongside Biome. Pick one.
- **Don't make the hook so slow that the user disables it.** If tests are slow, run only the tests touching changed files in the hook and the full suite in CI.
- **Don't bypass existing config.** If `biome.json` / `ruff.toml` / `lefthook.yml` already exists, read it first and respect the project's choices.
- **Don't run the hook with `--no-verify`** to test it. Make a real test commit.
