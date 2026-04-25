#!/usr/bin/env bash
# One-time setup: create the orphan `site` branch and a worktree
# at ./site/ that points at it. Run this once per clone.
#
# After this succeeds:
#   - `./site/` is checked out to the `site` branch
#   - That branch has a single placeholder commit
#   - GitHub Pages repo setting should be: deploy from `site` branch
#
# Safety: refuses to run with a dirty working tree, because the
# orphan-branch dance below will lose uncommitted work.
#
# Usage:
#   ./scripts/setup-site-worktree.sh

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

# ─────────── Safety: require a clean working tree ───────────
if ! git diff --quiet --ignore-submodules HEAD 2>/dev/null; then
  echo "ERROR: Working tree has uncommitted changes." >&2
  echo "       Commit or stash before running this script — the" >&2
  echo "       orphan-branch dance below will lose uncommitted work." >&2
  exit 1
fi

if [ -n "$(git ls-files --others --exclude-standard)" ]; then
  echo "ERROR: Working tree has untracked files." >&2
  echo "       Commit them first, or add them to .gitignore." >&2
  echo "" >&2
  echo "Untracked:" >&2
  git ls-files --others --exclude-standard | sed 's/^/  /' >&2
  exit 1
fi

if git rev-parse --verify --quiet site > /dev/null; then
  echo "Branch 'site' already exists. Skipping branch creation."
else
  echo "→ Creating orphan 'site' branch..."
  CURRENT_BRANCH=$(git symbolic-ref --short HEAD)

  git checkout --orphan site
  git rm -rf . > /dev/null 2>&1 || true

  cat > README.md <<EOF
# billo.systems — build output

This branch is machine-written. Do not edit by hand.

Source lives on the \`main\` branch. Each deploy rewrites this branch
with the output of \`cobalt build\` from source.

See https://github.com/billosys/billosys.github.io for the source.
EOF

  git add README.md
  git commit -m "Initialize empty site branch for GH Pages deploy"

  git checkout "$CURRENT_BRANCH"
fi

if [ -d site ] && [ -e site/.git ]; then
  echo "Worktree at ./site/ already exists. Skipping."
else
  if [ -d site ]; then
    echo "ERROR: ./site/ exists but is not a worktree. Remove it first." >&2
    exit 1
  fi
  echo "→ Adding worktree at ./site/ attached to branch 'site'..."
  git worktree add site site
fi

echo
echo "Setup complete. Next steps:"
echo "  1. Push: git push -u origin site"
echo "  2. In GitHub repo Settings → Pages, select branch 'site' as the deploy source."
echo "  3. Run ./scripts/fetch-fonts.sh to populate assets/fonts/"
echo "  4. Run cobalt build (or ./scripts/deploy.sh to build + push)."
