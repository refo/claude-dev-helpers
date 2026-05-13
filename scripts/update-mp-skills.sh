#!/usr/bin/env bash
# Update the vendored mattpocock/skills subtree and report drift between
# upstream's curated skills list and our wrapper's.
#
# Usage: scripts/update-mp-skills.sh
# Run from the repo root on a clean working tree. Pulls main from upstream
# via `git subtree`, then prints the diff between upstream's plugin.json
# skills list and ours so you know what to curate / bump.

set -euo pipefail

UPSTREAM="https://github.com/mattpocock/skills.git"
PREFIX="plugins/mp/skills"
WRAPPER_MANIFEST="plugins/mp/.claude-plugin/plugin.json"
MARKETPLACE="./.claude-plugin/marketplace.json"

if [[ ! -d .git ]]; then
  echo "error: run from the repo root" >&2
  exit 1
fi

if ! git diff-index --quiet HEAD --; then
  echo "error: working tree must be clean" >&2
  exit 1
fi

echo "==> pulling subtree from $UPSTREAM main"
git subtree pull --prefix="$PREFIX" "$UPSTREAM" main --squash

UPSTREAM_MANIFEST="$PREFIX/.claude-plugin/plugin.json"
if [[ ! -f "$UPSTREAM_MANIFEST" ]]; then
  echo "warning: upstream ships no .claude-plugin/plugin.json; nothing to diff"
  exit 0
fi

echo
echo "==> upstream skills (relative to $PREFIX):"
upstream_list=$(jq -r '.skills[]' "$UPSTREAM_MANIFEST" | sed 's|^\./||' | sort)
echo "$upstream_list" | sed 's/^/  /'

echo
echo "==> our wrapper skills (relative to $PREFIX, ./skills/ prefix stripped):"
wrapper_list=$(jq -r '.skills[]' "$WRAPPER_MANIFEST" | sed 's|^\./skills/||' | sort)
echo "$wrapper_list" | sed 's/^/  /'

echo
echo "==> drift (lines starting with '<' = only upstream, '>' = only wrapper):"
diff <(echo "$upstream_list") <(echo "$wrapper_list") || true

cat <<EOF

Next steps if the lists differ:
  1. Edit $WRAPPER_MANIFEST to mirror upstream's curated list
     (prepend "./skills/" to each path).
  2. Bump "version" in $WRAPPER_MANIFEST and $MARKETPLACE.
  3. Commit with a message naming the new/renamed/removed skills.
EOF
