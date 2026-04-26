# mp

Matt Pocock's Claude Code skills, vendored from
[mattpocock/skills](https://github.com/mattpocock/skills) via `git subtree`.

All skills here are authored by Matt Pocock and licensed MIT (see
`skills/LICENSE`). This plugin only repackages them under the `mp:` namespace
so they can be invoked as `mp:tdd`, `mp:brainstorming`, etc.

## Layout

Upstream stores each skill as `<skill-name>/SKILL.md` at the repo root, which
matches Claude Code's expected `skills/<name>/SKILL.md` shape — so the upstream
tree is subtreed directly into `plugins/mp/skills/` with no transformation.

## Updating

The subtree was added with:

```sh
git subtree add --prefix=plugins/mp/skills \
    https://github.com/mattpocock/skills.git main --squash
```

Pull future upstream changes with the symmetric command:

```sh
git subtree pull --prefix=plugins/mp/skills \
    https://github.com/mattpocock/skills.git main --squash
```

Run from the repo root on a clean working tree.
