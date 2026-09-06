#!/usr/bin/env bash
# Legacy branch deploy for billo.systems.
#
# Writes the build output into ./site/, which is a git worktree
# attached to the orphan `site` branch. GitHub Pages serves from
# that branch only when Pages is configured for legacy branch publishing.
# The current production path is `.github/workflows/deploy.yml`.
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

# Build the Pagefind search index into site/pagefind/ (reads ./pagefind.yml).
# Stock tool, no custom CLI: the `pagefind` binary on PATH. Safe here because
# this is a one-shot build (unlike `cobalt serve`, which would wipe
# site/pagefind/ on each incremental rebuild — see scripts/preview.sh).
echo "→ Indexing search (Pagefind)..."
if ! command -v pagefind >/dev/null 2>&1; then
  echo "error: pagefind not found on PATH — run ./scripts/install-pagefind.sh" >&2
  echo "       (or see https://pagefind.app/docs/installation/)." >&2
  exit 1
fi
pagefind --site site

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
