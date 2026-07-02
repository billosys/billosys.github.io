# Slice 03 — Self-host blog fonts

_Plan-of-record. Pragmatic tier. Opened 2026-07-01. Resolves the bubble-up from
slice 02: the blog loaded Google Fonts, contradicting the no-CDN policy._

## Goal

Serve the blog's three typefaces from the site itself, matching the marketing
site's self-hosted-font convention, and remove the runtime Google Fonts
dependency from blog pages.

## What changed

1. **Vendored variable woff2** into `assets/fonts/` (Fontsource, npm):
   - Brygada 1918 (display) — `brygada-1918-latin-wght-{normal,italic}.woff2`
   - Literata (reading body) — `literata-latin-standard-{normal,italic}.woff2`
     (the "standard" slice carries both the opsz + wght axes)
   - IBM Plex Mono 600 — added to the existing self-hosted 400/500.
2. **`_sass/_blog-fonts.scss`** — `@font-face` for all three (variable weight
   ranges, `font-display: swap`), mirroring `_sass/_fonts.scss`. Imported by
   `blog.scss` between `tokens` and `blog-components`, so it compiles into
   `/blog.css`.
3. **`_includes/blog-head.liquid`** — removed the Google Fonts `<link>` + the two
   `preconnect`s; added `<link rel="preload">` for the two above-the-fold faces
   (Literata normal, Brygada normal).

## Scope — out

- **Author avatar** (`avatars.githubusercontent.com`) — still the one external
  *loaded* resource on blog pages. Vendoring it means freezing the image + adding
  an `avatar` field to `authors.yml` and a template branch. Left as a flagged
  follow-up for the operator (single request; his call whether to freeze it).
- **Marketing `secondary.liquid`** still loads Brygada 1918 / Lora / Recursive
  from Google Fonts — the same no-CDN gap on the *marketing* side. Out of this
  (blog) slice; noted for a marketing-side follow-up.
- Non-latin subsets (cyrillic/greek/vietnamese) — latin-only for now.

## Risks / decisions

- **DD-A Literata axes.** The `standard` woff2 carries opsz+wght; the browser
  applies opsz automatically by size. If a build/CC finds the optical sizing
  absent, switch the src to the `opsz` slice — but `standard` is the intended
  multi-axis file.
- **DD-B `font-display: swap`** matches the marketing convention (no invisible
  text); the two preloads cut the swap flash on the reading column.

## Verification

Static (done): no `googleapis`/`gstatic` in blog templates; `blog.scss` imports
`blog-fonts`; every `@font-face` + preload URL resolves to a real woff2. Build
gate → CC (`cc-prompt.md`): clean build, `/blog.css` carries the `@font-face`,
fonts load 200 from `/assets/fonts/`, **zero Google Fonts requests**, glyphs
render in Brygada/Literata/IBM Plex Mono.

## Exit criteria

Blog renders in the three self-hosted typefaces with no Google Fonts network
request, on a clean `cobalt build`, no regression to slices 01–02.
