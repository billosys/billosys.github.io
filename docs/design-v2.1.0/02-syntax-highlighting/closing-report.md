# Closing report — Slice 02 Syntax highlighting

Closed 2026-07-01. Build gate: CC on stock Cobalt 0.20.2 (the live `deploy.sh`
version). CDC (Claude) cross-checked against the on-disk state.

## Verdict

**Delivered.** Code blocks render in Claude Design's bespoke palette — green
`--green-950` panel, `--ochre-300` keywords, `--green-300` functions/strings,
`--ochre-400` numerics — confirmed by CC via headless Chromium computing the
live token colours (S-07). All ten ledger rows `reproduced` on a clean build;
no regression to slice 01.

## Per-row walk (all reconciled)

S-01…S-10 → `reproduced` by CC, `reconciled` by CDC. Key ones: S-06 confirmed
`enabled: false` preserves the fence's `language-*` class (DD-A resolved — no
fence→class fixup needed); S-07 confirmed the brand palette live; S-08 confirmed
Prism is served from the site with zero external requests; S-09 legible in both
themes. S-10 confirmed rust + bash beyond the Erlang sample.

## Design decisions, final

- DD-A (output shape) — resolved: language class preserved. 
- DD-B (curated vs autoloader) — curated single file; dependency order sound (no
  Prism console errors).
- DD-C (`.code-figure`) — unaffected; Prism highlights the inner `<code>`.
- Q3 (clipboard/line-number plugins) — none added; **product decision deferred**
  to the operator.

## Bubble-up to the project

1. **Delivered its piece:** the blog now has brand-matched, self-hosted syntax
   highlighting on stock Cobalt — the capability slice 01 left as base16 fallback.
2. **Revealed (new — feeds a future slice):** CC's network capture shows the blog
   still loads **Google Fonts** (`fonts.googleapis.com`/`gstatic.com`) for
   Brygada 1918 + Literata, and the **GitHub avatar** (`avatars.githubusercontent.com`)
   in the author card — both external. `blog-head.liquid` itself cites a
   "no-CDN policy," and the marketing site already self-hosts its fonts
   (`assets/fonts/*.woff2`). This is a **pre-existing** contradiction, not caused
   by this slice (Prism is fully self-hosted), but it's a real gap against the
   stated policy → candidate **slice 03: self-host blog fonts** (Brygada 1918,
   Literata; IBM Plex Mono is already in `assets/fonts/`) and decide the avatar
   (self-host or drop).
3. **Silent-drop diff:** none. Scope delivered as specified; lykn/LFE custom
   Prism grammar was explicitly out-of-scope (LFE → `lisp` fallback, lykn →
   plaintext until a grammar slice).
