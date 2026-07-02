# CC assignment — verify brand-matched syntax highlighting (slice 02)

You are CC on a machine with stock **Cobalt 0.20.2** (the `scripts/deploy.sh`
version). Slice 01 (the blog) is already built and verified. This slice replaces
Cobalt's syntect highlighting (which can't load the bespoke `.tmTheme` on 0.20.2)
with **self-hosted Prism.js**, coloured by the site's `--code-*` design tokens.
CDC authored the changes; you run the build gate. Don't add a CDN, don't patch
Cobalt.

Plan: `docs/design-v2.1.0/02-syntax-highlighting/slice-doc.md`; rows: `ledger.md`.

## What changed (already on disk)

- `_cobalt.yml`: `syntax_highlight.enabled: false`.
- `assets/js/prism.js`: curated self-hosted Prism 1.30.0 (core + markup, css,
  clike, javascript, c, cpp, go, bash, json, yaml, python, rust, erlang, elixir,
  lisp, clojure, sql, toml, docker, diff, regex, markdown). `assets/js/prism.LICENSE`.
- `_layouts/blog-post.liquid`: `<script src="/assets/js/prism.js" defer></script>` (posts only).
- `_sass/_blog-components.scss`: `.token.*` → `--code-*` colour map.

## Steps

1. **Build.** `cobalt build` → exit 0, no warnings (S-05). Confirm no regression
   to slice 01 (articles/archive/tags/feeds still render).
2. **Output shape (S-06, DD-A).** In the built `supervision-trees` post, confirm
   the Erlang block is `<pre><code class="language-erlang">…plain text…</code></pre>`
   — NOT syntect inline-styled `<span style="color:#…">`. If the `language-erlang`
   class is missing, Prism can't hook — report it (we'd add a fence→class fixup).
3. **Palette (S-07).** Open the post in a browser. Confirm Prism highlighted the
   code and the colours are the brand palette: **green code panel**
   (`--code-bg` = green-950), **ochre keywords**, **green strings/functions**,
   muted comments — not Prism's default theme (there is no Prism theme CSS; all
   colour comes from `_blog-components.scss`). Spot-check a couple of token
   colours against the `--code-*` token values.
4. **Self-hosted (S-08).** DevTools Network: `/assets/js/prism.js` loads 200 from
   the site itself; **zero external/CDN requests**. Console: no Prism errors.
5. **Themes (S-09).** Toggle light/dark on the post — code stays legible.
6. **Other languages (S-10).** Add a temporary ```rust and ```bash fenced block
   to a draft/post, rebuild, confirm both highlight sensibly, then remove.

## To add a language later

Re-vendor from npm and extend the concatenation (dependency-safe order) — see
the header comment in `assets/js/prism.js`. Fetch `prismjs` from
`registry.npmjs.org`, take `components/prism-<lang>.min.js`, append after its
deps. (lykn/LFE have no Prism grammar yet — LFE falls back to `lisp`, lykn to
plaintext until a custom grammar is written; that's a separate slice.)

## Report back

Per row S-01…S-10: `reproduced` / `failed` + evidence (built HTML snippet, a
screenshot or colour hex, network tab). The one that matters most: **S-07** —
does the code actually render in the brand palette? If yes, this slice closes.
