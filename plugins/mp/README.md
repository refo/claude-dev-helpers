# mp

Matt Pocock's Claude Code skills, vendored from
[mattpocock/skills](https://github.com/mattpocock/skills) via `git subtree`.

All skills here are authored by Matt Pocock and licensed MIT (see
`skills/LICENSE`). This plugin only repackages them under the `mp:` namespace
so they can be invoked as `mp:tdd`, `mp:brainstorming`, etc.

## Layout

Upstream groups skills under `skills/<category>/<skill-name>/SKILL.md` (e.g.
`skills/engineering/tdd/SKILL.md`). The tree is subtreed directly into
`plugins/mp/skills/` with no transformation; this plugin's `plugin.json`
declares an explicit list of skill paths so only the curated set is exposed
under the `mp:` namespace (deprecated, in-progress, personal, and misc skills
are vendored but not registered).

## Updating

Run the helper from the repo root on a clean working tree:

```sh
scripts/update-mp-skills.sh
```

It pulls the subtree from `mattpocock/skills` `main` and prints any drift
between upstream's curated skills list and this wrapper's, so you know what
to re-curate before bumping the version in `plugin.json` and
`.claude-plugin/marketplace.json`.

The subtree was originally added with:

```sh
git subtree add --prefix=plugins/mp/skills \
    https://github.com/mattpocock/skills.git main --squash
```
