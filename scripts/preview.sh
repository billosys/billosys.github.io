#!/usr/bin/env bash
# Local preview of billo.systems WITH working search.
#
# Why not `cobalt serve`?  Cobalt's dev server rebuilds the site into a fresh
# directory on every change and wipes it clean each time — which clobbers the
# `site/pagefind/` index that Pagefind writes as a separate post-build step.
# Under `cobalt serve` the search box loads but returns nothing. (Learned the
# hard way on the LFE blog, whose custom CLI worked around the same conflict.)
#
# Instead we do a one-shot pipeline with stock tools only (no custom binary):
#   cobalt build  →  pagefind --site site --serve
# `pagefind --serve` builds the index AND statically serves site/ (default
# http://localhost:1414), so the whole blog + search work together.
#
# It does not watch for changes — re-run this script after editing sources.
#
# Usage:  ./scripts/preview.sh
# Assumes: cobalt and the pagefind binary on PATH.

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

if ! command -v pagefind >/dev/null 2>&1; then
  echo "error: pagefind not found on PATH — run ./scripts/install-pagefind.sh" >&2
  echo "       (or see https://pagefind.app/docs/installation/)." >&2
  exit 1
fi

echo "→ Building with Cobalt..."
cobalt build

echo "→ Indexing + serving (Pagefind)…  Ctrl-C to stop."
pagefind --site site --serve
