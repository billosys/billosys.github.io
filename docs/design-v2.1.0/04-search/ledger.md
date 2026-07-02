# Ledger — Slice 04 Full-text search (Pagefind)

Strength: `asserted` < `attested` (static) < `reproduced` (CC) < `reconciled`.

| ID | Criterion | Evidence / how | Open | Target |
|----|-----------|----------------|------|--------|
| P-01 | `search.liquid` no longer `ignore`d → builds to `/search/`; `pagefind.yml` still `ignore`d → not copied into `site/`. | `grep search.liquid _cobalt.yml` (absent); `grep pagefind.yml _cobalt.yml` (present); after build: `site/search/index.html` exists, `site/pagefind.yml` does NOT. | attested | reproduced |
| P-02 | Search link restored in blog nav. | `grep '/search/' _includes/blog-nav.liquid`. | attested | reconciled |
| P-03 | Post `<article>` carries `data-pagefind-body`; list/tag/archive pages do not. | `grep 'data-pagefind-body' _layouts/blog-post.liquid`. | attested | reconciled |
| P-04 | `scripts/deploy.sh` runs the `pagefind` binary (`pagefind --site site`) after `cobalt build`, before commit; fails loudly if pagefind absent. | read deploy.sh order. | attested | reproduced |
| P-05 | `scripts/preview.sh` present + executable: `cobalt build` → `pagefind --site site --serve`; documents "not cobalt serve". | `ls -l scripts/preview.sh`; run it. | attested | reproduced |
| P-06 | `cobalt build && pagefind --site site` succeeds; `site/pagefind/` written (pagefind-ui.js/css, wasm, index). | CC: run the two commands; `ls site/pagefind/`. | asserted | reproduced |
| P-07 | `/search/` returns a real result for a known term (e.g. "supervision", "raft"), linking to the right post. | CC: `preview.sh` → open `/search/`, query. | asserted | reproduced |
| P-08 | Only **posts** appear in results — no `/articles/` landing, `/archive/`, `/tags/` list pages. | CC: query a common word; inspect result URLs. | asserted | reproduced |
| P-09 | Search UI renders in brand palette (accent = ochre, surfaces/borders from tokens), self-hosted (no CDN request from `/search/`). | CC: open `/search/`; devtools network + computed colours. | asserted | reproduced |
| P-10 | Deploy path: after `deploy.sh`, the committed `site` tree contains `site/pagefind/`; no `site/pagefind.yml`. | CC: run/inspect deploy build; `ls site/pagefind*`. | asserted | reproduced |
| P-11 | Clean build; no regression to slices 01–03 (pages, feeds, highlighting, fonts intact). | CC. | asserted | reproduced |

## Open questions for CC

1. **DD-B:** Confirm `pagefind --site site --serve` serves the full site (so
   `/articles/…` and `/search/` both work) and the port (default 1414).
2. **DD-A:** Using the `pagefind` **binary** on PATH (per operator). Confirm the
   version and note any install friction for the docs.
3. Does `data-pagefind-body` correctly exclude the landing/tag/archive pages, or
   did any slip into the index (P-08)?

## Close (2026-07-01)
All rows P-01…P-11 **reconciled** — CC `reproduced` on Cobalt 0.20.2 + pagefind
1.5.2 (live `--serve`: real hits, posts-only, self-hosted, deploy tree clean),
CDC cross-checked on disk. CC's flag (missing `install-pagefind.sh`) resolved —
the script was added after CC's checkout and is now present. See `closing-report.md`.
