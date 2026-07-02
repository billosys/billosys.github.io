# CC assignment — verify full-text search (slice 04)

You are CC on stock **Cobalt 0.20.2** (the `scripts/deploy.sh` version). Slices
01–03 are closed. This slice turns on Pagefind search with **stock tools only**
(no custom CLI, no Cobalt change). CDC authored the changes; you run the build
gate — including the local-preview path, since that's where search historically
broke.

Plan: `docs/design-v2.1.0/04-search/slice-doc.md`; rows: `ledger.md`.
Read the **gotcha** in the slice-doc first: `cobalt serve` clobbers
`site/pagefind/` — do NOT use it to test search.

## What changed (on disk)

- `_cobalt.yml`: `search.liquid` un-ignored (builds to `/search/`);
  `pagefind.yml` stays ignored (read from project root, not copied to `site/`).
- `_includes/blog-nav.liquid`: Search link restored.
- `_layouts/blog-post.liquid`: `data-pagefind-body` on the post `<article>`.
- `search.liquid`: self-hosted Pagefind UI, themed via `--pagefind-ui-*`.
- `scripts/deploy.sh`: `pagefind --site site` after `cobalt build`.
- `scripts/preview.sh` (new): `cobalt build` → `pagefind --site site --serve`.

## Steps

1. **Index (P-06).** `cobalt build` then `pagefind --site site` (the **binary**
   on PATH — that's the chosen approach; the scripts do not use npx). Confirm
   exit 0 and `ls site/pagefind/` shows `pagefind-ui.js`, `pagefind-ui.css`,
   wasm, and the index fragments. Note the pagefind version + any install
   friction (DD-A).
2. **Preview + query (P-07, P-08).** Run `./scripts/preview.sh`; open the served
   site (default `http://localhost:1414`) → `/search/`. Query "supervision" and
   "raft" — confirm real hits linking to the right posts, and that **only posts**
   appear (no `/articles/` landing, `/archive/`, `/tags/`). Confirm `--serve`
   serves the whole site (DD-B).
3. **UI + self-hosting (P-09).** On `/search/`: results styled in the brand
   palette (ochre accent, token surfaces/borders); DevTools Network shows the
   pagefind assets load from the site — no CDN.
4. **No leak (P-01).** Confirm `site/search/index.html` exists and
   `site/pagefind.yml` does **not**.
5. **Deploy path (P-10).** Simulate `scripts/deploy.sh` (or read it and run the
   build+index portion): the resulting `site/` contains `site/pagefind/`, ready
   to commit. Don't push.
6. **No regression (P-11).** Slices 01–03 still good (pages, feeds, code
   highlighting, self-hosted fonts).

## Report back

Per row P-01…P-11: `reproduced` / `failed` + evidence (an `ls site/pagefind/`,
a screenshot or result URL list, the pagefind version/source). The one that
matters most: **P-07/P-08** — real hits, posts only. Flag anything that needed a
change so CDC can fold it in and reconcile.
