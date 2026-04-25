#!/usr/bin/env bash
# Deploy billo.systems to GitHub Pages.
#
# Writes the build output into ./site/, which is a git worktree
# attached to the orphan `site` branch. GitHub Pages serves from
# that branch.
#
# Usage:
#   ./scripts/deploy.sh
#
# Assumes:
#   - cobalt-bin installed (cargo install cobalt-bin)
#   - The site worktree exists (see scripts/setup-site-worktree.sh)
#   - You're happy with the current state of the source branch

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

# Clear worktree content (preserves .git linkage file).
echo "→ Clearing site/ (keeping .git linkage)..."
find site -mindepth 1 -maxdepth 1 -not -name '.git' -exec rm -rf {} +

echo "→ Building with Cobalt..."
cobalt build

# Commit + push from within the worktree.
cd site
echo "→ Staging deploy..."
git add -A

if git diff --cached --quiet; then
  echo "→ No changes to deploy. Done."
  exit 0
fi

SRC_HASH=$(git -C .. rev-parse --short HEAD)
SRC_MSG=$(git -C .. log -1 --pretty=%s)
git commit -m "deploy: ${SRC_HASH} — ${SRC_MSG}"
git push origin site
echo "→ Deployed ${SRC_HASH}."
