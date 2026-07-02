# Ledger — Slice 03 Self-host blog fonts

Strength: `asserted` < `attested` (static) < `reproduced` (CC build) < `reconciled`.

| ID | Criterion | Evidence / how | Open | Target |
|----|-----------|----------------|------|--------|
| F-01 | Variable woff2 for Brygada 1918 (normal+italic) + Literata standard (normal+italic) + IBM Plex Mono 600 present in `assets/fonts/`. | `ls assets/fonts/`. | attested | reconciled |
| F-02 | `_sass/_blog-fonts.scss` declares `@font-face` for all three; imported by `blog.scss`. | `grep blog-fonts blog.scss`. | attested | reconciled |
| F-03 | Every `@font-face` + preload URL resolves to a real file. | static check (done). | attested | reconciled |
| F-04 | No `googleapis`/`gstatic` reference in any blog template (`blog-head`, blog layouts). | `grep -ri googleapis _includes _layouts/blog-*`. | attested | reconciled |
| F-05 | Clean `cobalt build`; `/blog.css` contains the `@font-face` rules; no regression to slices 01–02. | CC: build exit 0; `grep @font-face site/blog.css`. | asserted | reproduced |
| F-06 | On a blog page, fonts load 200 from `/assets/fonts/…woff2`; **zero requests to fonts.googleapis.com / gstatic**. | CC: devtools network on a post. | asserted | reproduced |
| F-07 | Text renders in Brygada 1918 (headings), Literata (body), IBM Plex Mono (meta/code) — not fallback serif/mono. | CC: computed `font-family` on h1 / prose / code. | asserted | reproduced |
| F-08 | Preloaded faces (Literata/Brygada normal) load without console warnings; `font-display: swap` (no invisible text). | CC: console + network. | asserted | reproduced |

## Notes / deferred

- **Author avatar** (`avatars.githubusercontent.com`) — the remaining external
  loaded resource on blog pages. Vendoring it (freeze image + `authors.yml`
  `avatar` field + template branch) is a separate operator decision.
- **Marketing `secondary.liquid`** still loads Google Fonts (Brygada/Lora/
  Recursive) — same gap on the marketing side; a marketing follow-up.

## Close (2026-07-01)
All rows F-01…F-08 **reconciled** — CC `reproduced` (live browser: zero Google
Fonts requests, all three families loaded per document.fonts), CDC cross-checked
on disk. See `closing-report.md`. Deferred (out of scope): author avatar,
marketing-side Google Fonts.
