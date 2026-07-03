#!/usr/bin/env bash
# Vendor KaTeX locally for client-side math rendering — no runtime CDN.
#
# Posts with `data.math: true` load KaTeX (see _layouts/blog-post.liquid), which
# renders `$…$` / `$$…$$` in the browser. To keep the site's no-CDN policy
# (slices 06/07), the KaTeX CSS, JS, auto-render extension, and fonts are
# vendored under assets/katex/ and committed, so CI/deploy just serve them.
#
# We vendor woff2 fonts ONLY: KaTeX's @font-face lists woff2 first, and every
# modern browser supports it, so no woff/ttf request is ever made — matching the
# site's woff2-only font convention (assets/fonts/). katex.min.css references
# fonts/ relatively, so the fonts/ subdir placement below resolves as-is.
#
# Idempotent: re-run to refresh or bump KATEX_VER. Needs network + curl + tar.
#
# Usage:   ./scripts/fetch-katex.sh
# Env:     KATEX_VER=0.17.0

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

KATEX_VER="${KATEX_VER:-0.17.0}"
DIR="assets/katex"
TARBALL_URL="https://registry.npmjs.org/katex/-/katex-${KATEX_VER}.tgz"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "  → KaTeX ${KATEX_VER}"
curl -sSfL --retry 3 --max-time 120 -o "$tmp/katex.tgz" "$TARBALL_URL"
tar xzf "$tmp/katex.tgz" -C "$tmp"   # extracts to $tmp/package/

src="$tmp/package/dist"
rm -rf "$DIR"
mkdir -p "$DIR/fonts"

cp "$src/katex.min.css"                "$DIR/katex.min.css"
cp "$src/katex.min.js"                 "$DIR/katex.min.js"
cp "$src/contrib/auto-render.min.js"   "$DIR/auto-render.min.js"
cp "$src"/fonts/*.woff2                "$DIR/fonts/"

# Record the vendored version alongside the assets.
printf 'KaTeX %s — vendored by scripts/fetch-katex.sh (woff2 only)\n' "$KATEX_VER" > "$DIR/VERSION"

echo "     $DIR/{katex.min.css,katex.min.js,auto-render.min.js}"
echo "     $(ls -1 "$DIR/fonts" | wc -l | tr -d ' ') woff2 fonts in $DIR/fonts/"
echo
echo "Done. KaTeX ${KATEX_VER} vendored in $DIR/"
