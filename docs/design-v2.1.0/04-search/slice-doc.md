# Slice 04 — Full-text search (Pagefind)

_Plan-of-record. Pragmatic tier. Opened 2026-07-01. Un-defers the search that
slices 01–03 left wired-but-ignored._

## Goal

Ship working full-text search on the blog with **stock tools only** (no custom
Rust CLI, no Cobalt change) — indexed at build time, self-hosted, brand-themed —
and give a local-preview path that actually works, avoiding the pitfall that bit
the LFE blog.

## The gotcha (learned from the LFE blog — the reason this is its own slice)

Pagefind is a **post-build** indexer: after Cobalt renders HTML into `site/`,
`pagefind --site site` scans it and writes the index into **`site/pagefind/`**.
That composes fine with a one-shot `cobalt build`. It does **not** compose with
`cobalt serve`: Cobalt's dev server rebuilds into a fresh output on every change
and wipes it, so it clobbers `site/pagefind/` — the search box loads but returns
nothing. LFE hid this inside a custom `lfesite serve` (build → pagefind →
static-serve → watch); its `serve.rs` says so verbatim. Billo has no such CLI,
so we solve it with stock tools instead.

## Approach

1. **Un-defer the page/config.** Remove `search.liquid` from `_cobalt.yml`
   `ignore` (it builds to `/search/`). Keep `pagefind.yml` **ignored** — pagefind
   reads it from the project root at index time; it must not be copied into
   `site/`. Restore the **Search** link in `blog-nav.liquid`.
2. **Scope the index to posts.** `data-pagefind-body` on the post `<article>`
   (blog-post.liquid) → Pagefind indexes only posts, not the list/tag/archive
   pages. `pagefind.yml` `exclude_selectors` still strips nav/footer/author-card.
3. **Deploy** (`scripts/deploy.sh`): after `cobalt build`, run
   `pagefind --site site` before the `git add`/commit of the `site` worktree.
   One-shot build → no clobber. Uses the **`pagefind` binary on PATH** (operator
   decision — not npx); the script fails loudly with an install hint if absent.
4. **Local preview** (`scripts/preview.sh`, new): `cobalt build` then
   `pagefind --site site --serve`. Pagefind's `--serve` builds the index **and**
   statically serves `site/` (default `localhost:1414`), so the whole blog +
   search work together. **Do not use `cobalt serve` for search.** One-shot; no
   file-watch (re-run after edits — acceptable for the blog's cadence).
5. **Brand-themed UI.** `search.liquid` uses the self-hosted Pagefind UI
   (`/pagefind/pagefind-ui.{js,css}`) themed via its `--pagefind-ui-*` custom
   properties mapped to the blog's OKLCH tokens (`--accent`, `--surface-raised`,
   `--rule`, `--tag-bg`, `--font-body`). No CDN — assets are served from the site,
   consistent with slice 03's no-CDN goal.

## Scope — out

- **File-watching local dev** (LFE's watcher) — needs a watcher tool/loop; the
  re-run-`preview.sh` cadence is fine for v1.
- **`pagefind_extended`** (CJK/large-language index) — English content → base
  `pagefind` suffices.
- **Custom results UI** via the Pagefind JS API — the themed default UI is v1.

## Risks / decisions

- **DD-A pagefind binary.** Deploy/preview use the **`pagefind` binary on PATH**
  (operator's choice, not npx). Both scripts fail with an install hint if it's
  missing (https://pagefind.app/docs/installation/). Standard distribution, not a
  custom tool.
- **DD-B `--serve` port/behaviour.** Assumes `pagefind --serve` serves the full
  `--site` dir (it does, on :1414). CC confirms.
- **DD-C Deploy ordering.** pagefind must run **after** `cobalt build` and
  **before** `git add` in the `site` worktree; `deploy.sh` clears `site/` at the
  top, so each deploy is a clean build+index (no stale index). CC confirms the
  committed tree contains `site/pagefind/`.

## Verification

Static (done): search page un-ignored, pagefind.yml still ignored, nav link
present, `data-pagefind-body` on posts, deploy.sh order build→index→commit,
preview.sh executable, UI themed. Build gate → CC (`cc-prompt.md`): run
`deploy.sh`'s build+index locally, confirm `site/pagefind/` exists and `/search/`
returns a real hit; confirm `preview.sh` serves search working; confirm no
`site/pagefind.yml` leak and list pages absent from results.

## Exit criteria

`/search/` returns real results from a self-hosted, brand-themed UI after the
stock `cobalt build && pagefind --site site` pipeline; `deploy.sh` publishes the
index; `preview.sh` previews it locally; `cobalt serve` is documented as the
thing not to use. No regression to slices 01–03.
