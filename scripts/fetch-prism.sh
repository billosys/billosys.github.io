#!/usr/bin/env bash
# Vendor a curated Prism.js bundle for client-side syntax highlighting — no CDN.
#
# Cobalt's native (syntect) highlighting is disabled (see _cobalt.yml); fenced
# code blocks emit <pre><code class="language-*"> and self-hosted Prism.js
# (loaded by blog-post.liquid) colours them in the browser via the --code-*
# tokens in _sass/_blog-components.scss.
#
# This rebuilds assets/js/prism.js from prismjs@<PRISM_VER> (npm, MIT): Prism
# core + every language the blog uses, in dependency order, then appends the
# hand-written LFE grammar (assets/js/prism-lfe.js) — Prism ships no `lfe`, and
# its `lisp` fallback highlights real LFE poorly. `lykn` is aliased to LFE there.
#
# Idempotent: re-run to refresh or bump PRISM_VER / LANGS. Needs network + npm.
#
# Usage:   ./scripts/fetch-prism.sh
# Env:     PRISM_VER=1.30.0

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

PRISM_VER="${PRISM_VER:-1.30.0}"
OUT="assets/js/prism.js"
LFE_GRAMMAR="assets/js/prism-lfe.js"

# Languages this blog uses (see: grep -rhoE '^```[a-z]+' posts/) plus the
# curated general set from slice 02. Deps (clike, scheme, …) are pulled in
# automatically from components.json. shell is an alias of bash; lfe/lykn come
# from prism-lfe.js.
LANGS="markup css clike javascript c cpp go bash json yaml python rust erlang elixir lisp clojure sql toml docker diff markdown regex racket haskell makefile"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "  → prismjs ${PRISM_VER} (npm)"
( cd "$tmp" && npm install --no-audit --no-fund --silent "prismjs@${PRISM_VER}" >/dev/null )
PRISM="$tmp/node_modules/prismjs"

echo "  → resolving language dependencies + concatenating"
node - "$PRISM" "$LFE_GRAMMAR" "$OUT" <<'NODE' "$LANGS"
const fs = require('fs');
const path = require('path');
const [prismDir, lfeGrammar, out, langStr] = process.argv.slice(2);
const comps = require(path.join(prismDir, 'components.json')).languages;

// Depth-first: emit each language's `require` deps before the language itself.
const order = [], seen = new Set();
const asArr = v => v == null ? [] : Array.isArray(v) ? v : [v];
function visit(id) {
  if (seen.has(id) || id === 'meta' || !comps[id]) return;
  seen.add(id);
  for (const dep of asArr(comps[id].require)) visit(dep);
  order.push(id);
}
for (const l of langStr.trim().split(/\s+/)) visit(l);

const parts = [fs.readFileSync(path.join(prismDir, 'components', 'prism-core.min.js'), 'utf8')];
for (const id of order) {
  const f = path.join(prismDir, 'components', `prism-${id}.min.js`);
  if (fs.existsSync(f)) parts.push(fs.readFileSync(f, 'utf8'));
  else console.error(`  ! no component file for ${id} — skipped`);
}
parts.push(fs.readFileSync(lfeGrammar, 'utf8'));   // hand-written LFE + lykn alias
fs.writeFileSync(out, parts.join('\n'));
console.error(`  → ${order.length} languages + LFE, ${(parts.join('').length/1024|0)}KB → ${out}`);
NODE

cp "$PRISM/LICENSE" assets/js/prism.LICENSE

echo
echo "Done. Prism ${PRISM_VER} bundle → $OUT (+ LFE grammar from $LFE_GRAMMAR)"
