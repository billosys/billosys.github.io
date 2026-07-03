# Ledger — Slice 08 Canonical / OG URL fix

**CC implements + verifies.** Strength: `asserted` < `attested` < `reproduced` < `reconciled`.

| ID | Criterion | Evidence / how | Target |
|----|-----------|----------------|--------|
| CU-01 | All 5 head URL expressions use `{{ site.base_url }}{{ page.permalink \| prepend: "/" \| replace: "//", "/" }}` — in `blog-head.liquid` (canonical), `secondary.liquid` (og:url + canonical), `default.liquid` (og:url + canonical). | grep the 3 files. | reproduced |
| CU-02 | Clean `cobalt build`, no warnings; `prepend`/`replace` filters accepted. | CC. | reproduced |
| CU-03 | **Zero** malformed URLs in built HTML: no `billo.systemsarticles`, no `billo.systems//`, no domain-fused-to-path anywhere. | `grep -rE 'billo\.systems[^/"]' site/ ` returns nothing (besides the bare `https://billo.systems"` canonical/og on the landing). | reproduced |
| CU-04 | Canonical on a **post** = `https://billo.systems/articles/<yr>/<mo>/<slug>/`; `og:url` matches. | CC: read a built post `<head>`. | reproduced |
| CU-05 | Canonical on an **index page** (`/articles/`, `/tags/`, `/archive/`) and the **marketing landing** are well-formed (single slash). | CC: read built `<head>`s. | reproduced |
| CU-06 | Feeds still valid (unchanged); no regression to slices 01–07. | CC: `xmllint` feeds; spot-check pages. | reproduced |

## Note for CC

Report the raw `page.permalink` value for a post vs an index page — that confirms
why the normalisation is needed and that it's doing the right thing.

## Close (2026-07-02)
CU-01…CU-06 **reconciled** — CC implemented the `prepend:"/" | replace:"//","/"`
normalisation across all 5 head tags; zero malformed URLs in the built site, post
canonical is a clean absolute URL, feeds unchanged, no regression. Permalink
asymmetry confirmed (posts no leading slash; index pages have one). See
`closing-report.md`.
