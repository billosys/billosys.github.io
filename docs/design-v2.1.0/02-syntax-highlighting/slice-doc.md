# Slice 02 — Brand-matched syntax highlighting

_Plan-of-record. Pragmatic tier: this + `ledger.md` + `cc-prompt.md`, then build,
then verify. CDC authors; CC builds/verifies on a machine with Cobalt 0.20.2._
Opened 2026-07-01. Depends on slice 01 (blog) being in place.

## Goal

Render code blocks in Claude Design's bespoke palette (green panel, ochre
keywords, green functions/strings) — the look the `_syntaxes/billo-reading-dark.tmTheme`
was meant to give — on **stock Cobalt 0.20.2**, which cannot load that theme.

## Why the server-side theme is impossible here (the finding)

Cobalt delegates highlighting to the `engarde` crate
(`pub use engarde::Syntax as SyntaxHighlight`). `SyntaxHighlight::new()` takes
**no arguments**, so the theme set is fixed at construction to syntect's
built-ins; `verify_theme` → `has_theme(name)` hard-errors the build on any name
that isn't one of the ~7 defaults (`base16-ocean.dark`, `base16-*`,
`InspiredGitHub`, `Solarized (dark|light)`). There is **no config key, folder
scan, or env var** to add a custom `.tmTheme`. Confirmed empirically (every name
Duncan tried → "unsupported") and by reading `src/syntax_highlight.rs` at
tag v0.20.2. The mockup README's "_syntaxes/ is scanned" premise is false for
this release.

## Approach (operator-approved: "if Prism.js is the standard, use it")

Move highlighting to the client, driven by the existing design tokens:

1. `_cobalt.yml`: `syntax_highlight.enabled: false` → fenced blocks emit clean
   `<pre><code class="language-*">` (no baked syntect colours; the green
   `--code-bg` panel now shows because nothing overrides it inline).
2. **Self-hosted Prism.js** at `/assets/js/prism.js` — a curated build (core +
   the languages this blog uses), vendored from `prismjs@1.30.0` (npm), MIT.
   No CDN (matches the site's self-hosted-asset convention; see `assets/fonts/`).
   Loaded by `blog-post.liquid` only (code appears only in posts), `defer`;
   Prism auto-highlights on load.
3. **Token-mapped CSS** in `_sass/_blog-components.scss`: Prism token classes
   (`.token.keyword`, `.token.function`, …) → the `--code-kw/fn/var/num/com/punc/key`
   OKLCH tokens the bespoke palette was derived from. So the palette stays live
   in the tokens (adapts per light/dark theme) rather than baked sRGB.

Note the sibling **lykn** site uses the same `enabled: false` base but a bespoke
5KB `prose-highlight.js` — that was special-cased for lykn's own s-expression
syntax. For Billo's Erlang/Rust/etc. content, Prism's real grammars are the
right general tool (operator decision).

## Scope

- **In:** the three changes above; curated Prism languages: markup, css, clike,
  javascript, c, cpp, go, bash, json, yaml, python, rust, erlang, elixir, lisp,
  clojure, sql, toml, docker, diff, markdown (+ regex). LICENSE vendored.
- **Out:** a Prism *plugin* set (line-numbers, copy-button, toolbar) — can be
  added later. A custom Prism grammar for **lykn/LFE** specifically — deferred;
  LFE code would fall back to `lisp`, lykn to plaintext until a grammar is added.

## Key decisions & risks

- **DD-A `enabled: false` output shape.** Assumes Cobalt 0.20.2 with the flag
  off emits `<pre><code class="language-x">` (Prism-ready). The engarde `Raw`
  path in the source shows exactly this shape. **CC confirms on the real build.**
- **DD-B Curated vs autoloader.** Chose a single concatenated file (fewer
  requests, no runtime CDN) over the autoloader. Adding a language later = extend
  the build (documented in `cc-prompt.md`). Dependency order baked in.
- **DD-C `.code-figure` chrome.** The manual filename/lang wrapper still frames
  code; Prism highlights the inner `<code class="language-*">` the same way.

## Verification

Static in-sandbox: JS asset present + non-empty, script wired in `blog-post.liquid`,
`enabled: false`, token-map CSS references only existing `--code-*` tokens.
Build gate → CC (`cc-prompt.md`): clean build, code emits language classes,
Prism highlights the Erlang sample in the brand palette (green panel, ochre
keywords), no CDN requests, both light/dark themes legible.

## Exit criteria

See `ledger.md`: brand-palette highlighting renders on the post view from
self-hosted assets, on a clean `cobalt build`, with no regression to slice 01.
