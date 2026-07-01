# Ledger — Slice 01 Articles blog

Grep-verifiable acceptance criteria. Strength ladder:
`asserted` < `attested` < `reproduced` < `reconciled`.

- **asserted** — claimed by the author (CDC), not yet run.
- **attested** — checked by a static tool in-sandbox (no Cobalt).
- **reproduced** — confirmed by CC against a real `cobalt build`.
- **reconciled** — CC's build result cross-checked against this ledger by CDC.

Closer ≠ verifier: rows that need a build are authored `asserted`, raised to
`reproduced` by CC, and `reconciled` by CDC at slice close. No row is dropped;
count at close must equal count at open.

| ID | Criterion | Evidence / how verified | Strength (open) | Strength (target) |
|----|-----------|-------------------------|-----------------|-------------------|
| L-01 | `_cobalt.yml` has a `posts` collection (`dir: posts`, `order: Desc`, default layout `blog-post.liquid`) and keeps `ignore` for `site/**` + `workbench/**`. | `grep -A8 '^posts:' _cobalt.yml`; YAML parses. | asserted | reconciled |
| L-02 | `syntax_highlight` enabled with the custom theme; `_syntaxes/billo-reading-dark.tmTheme` present at root. | `grep syntax_highlight _cobalt.yml`; `cobalt debug highlight themes` lists "Billo Reading Dark". | asserted | reproduced |
| L-03 | Five page types exist at source root: `articles.liquid`, `archive.liquid`, `tags.liquid`, `tag.liquid`, plus post layout. | `ls articles.liquid archive.liquid tags.liquid tag.liquid _layouts/blog-post.liquid`. | asserted | attested |
| L-04 | Includes present and referenced with matching names (no dangling `include`). | static: every `{% include 'X' %}` resolves to `_includes/X`. | asserted | attested |
| L-05 | `blog.scss` compiles to `/blog.css`; `_sass/_blog.scss` imports resolve; all `var(--…)` tokens exist in `_sass/_tokens.scss`. | static token cross-check (done: space/step/neutral/green/ochre all present); confirmed by build producing `site/blog.css`. | attested | reproduced |
| L-06 | `cobalt build` completes with no errors or warnings. | CC: `cobalt build` exit 0, clean stderr. | asserted | reproduced |
| L-07 | Landing renders at `/articles/`: featured lead + recent list + earlier-writing list; all post links resolve. | CC: open `site/articles/index.html`; links 200. | asserted | reproduced |
| L-08 | Each post renders via `blog-post.liquid` with tag chips, meta, prose, prev/next; prev/next resolve to real neighbours. | CC: open a `site/…/post.html`; check prev/next hrefs. | asserted | reproduced |
| L-09 | Archive renders at `/archive/`, year-grouped, newest-first, count correct. | CC: open `site/archive/index.html`. | asserted | reproduced |
| L-10 | Tag **directory** renders at `/tags/` with per-tag counts (pure-Liquid aggregation). | CC: open `site/tags/index.html`; counts match posts. | asserted | reproduced |
| L-11 | **Single-tag** pages generate, one per tag, at a permalink the tag-chip links point to (`/tags/<tag>/`), listing exactly the posts carrying that tag. **[DD-2 — resolve empirically]** | CC: confirm generated permalink + paginator fields; if mismatch, apply the LFE `paginator.indexes` fallback and report. | asserted | reproduced |
| L-12 | Reading time shows on the post view, auto-computed when `data.minutes` is absent. **[DD-1]** | CC: post with no `minutes` shows a computed value; confirm whether `post.content` is usable in index loops. | asserted | reproduced |
| L-13 | `/rss.xml` generates and is well-formed (valid RSS 2.0, correct item links/dates). | CC: `xmllint --noout site/rss.xml`; spot-check links. | asserted | reproduced |
| L-14 | `/atom.xml` generates and is well-formed (valid Atom, single-author name resolved). | CC: `xmllint --noout site/atom.xml`. | asserted | reproduced |
| L-15 | Sample posts carry **tags only, no `categories:`**; frontmatter valid; author resolves to Duncan. | static: `grep -L 'categories' posts/*.md` = all; YAML parses. | asserted | attested |
| L-16 | Pagefind: `pagefind.yml` present and scoped to the blog output; index builds. **[DD-3 — extra post-build step]** | CC: `pagefind --site site` (or npx) succeeds; search returns a known post. | asserted | reproduced |
| L-17 | Blog reachable from the marketing site: footer "Engineering Blog" link + a nav entry point to `/articles/`. | static: `grep '/articles/' _layouts/secondary.liquid`. | asserted | attested |
| L-18 | Theme toggle works on blog pages and shares the `billo-theme` localStorage key with the marketing site (no flash). | CC: toggle persists across marketing ↔ blog navigation. | asserted | reproduced |
| L-19 | Both deploy paths publish the blog to expected locations: `scripts/deploy.sh` (→ `site` branch) and `.github/workflows/deploy.yml` (→ Pages artifact, **Cobalt pinned 0.19.7**). `docs/` excluded; `CNAME` present. Pagefind step decision recorded. | CC: run/inspect a build per Step 8; verify tree + no `docs/` leak. | asserted | reproduced |

## Open questions for CC (fold results back here)

1. **DD-2:** Under the installed Cobalt (target: latest stock, ~v0.20.4), does a
   root `tag.liquid` with `pagination: { include: Tags }` generate per-tag pages
   at `/tags/<tag>/`? What are the real paginator field names? Does it also emit
   a stray index page that collides with the hand-rolled `tags.liquid`? If the
   two-file approach fights the engine, switch to LFE's single-file
   `paginator.indexes` pattern and report the diff.
2. **DD-1:** Is `post.content` available (and word-countable) inside
   `{% for post in collections.posts.pages %}` on index pages, or only as
   `page.content` on the post itself?
3. **DD-3:** Is an extra pagefind build step acceptable, or should search be
   deferred to keep the build a single `cobalt build`?
