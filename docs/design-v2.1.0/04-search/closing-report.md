# Closing report — Slice 04 Full-text search (Pagefind)

Closed 2026-07-01. Build gate: CC on stock Cobalt 0.20.2 + pagefind 1.5.2, live
`--serve` preview. CDC cross-checked on disk.

## Verdict

**Delivered.** `/search/` returns real, posts-only results from a self-hosted,
brand-themed Pagefind UI, built by the stock `cobalt build && pagefind --site
site` pipeline. CC confirmed live queries ("supervision", "raft", "distributed")
hit the right posts with zero list-page leakage; the `--serve` preview serves the
whole site on :1414; and the deploy path leaves a committable `site/pagefind/`
with no `pagefind.yml` leak. All 11 rows `reproduced` → `reconciled`; slices
01–03 intact.

## Per-row walk (reconciled)

P-01…P-11 → `reproduced` by CC, `reconciled` by CDC. Highlights: P-06 — Pagefind
"Indexed 5 pages, 506 words", honouring `data-pagefind-body`; P-08 — exactly the
5 posts, landing ignored; P-09 — UI accent = `--accent` ochre, zero external
requests.

## The cobalt-serve gotcha — resolved

The LFE-learned pitfall (cobalt serve wipes `site/pagefind/`) is designed around,
not hit: `scripts/preview.sh` uses `pagefind --site site --serve` (one-shot
build+index+serve), documented as the thing to use *instead of* `cobalt serve`.
CC's DD-B confirmed it serves the full site.

## Bubble-up to the project

1. **Delivered its capability:** full-text search, stock-tools-only, self-hosted.
2. **CC flag (resolved):** the missing-binary hint references
   `scripts/install-pagefind.sh`, which CC didn't see — because it was added
   *after* CC's checkout. It is now present + executable; hint is valid.
3. **DD-A note:** CC's pagefind is at `~/.cargo/bin/pagefind` → `cargo install
   pagefind` works as an install path (alongside the release binary that
   `install-pagefind.sh` fetches). Recorded for the docs.
4. **Silent-drop diff:** none. Out-of-scope items unchanged: file-watching dev,
   `pagefind_extended`, custom results UI.

## Project status after this slice

All four planned slices closed: **01 blog · 02 syntax highlighting · 03
self-hosted fonts · 04 search**. The blog is feature-complete and shippable via
`scripts/deploy.sh` (after `scripts/install-pagefind.sh` once). Remaining
candidates are cosmetic/marketing: author-avatar self-host, marketing-side
Google Fonts, guard `data.minutes` in listings, tag-directory article count, and
bumping the uncommitted CI workflow to Cobalt 0.20.2+.
