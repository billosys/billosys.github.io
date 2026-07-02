# CC assignment — verify self-hosted blog fonts (slice 03)

You are CC on stock **Cobalt 0.20.2** (the `scripts/deploy.sh` version). Slices
01–02 are closed. This slice moves the blog's three typefaces from Google Fonts
to self-hosted woff2. CDC authored the changes; you run the build gate.

Plan: `docs/design-v2.1.0/03-fonts/slice-doc.md`; rows: `ledger.md`.

## What changed (on disk)

- `assets/fonts/`: `brygada-1918-latin-wght-{normal,italic}.woff2`,
  `literata-latin-standard-{normal,italic}.woff2`, `ibm-plex-mono-latin-600-normal.woff2`
  (added to existing 400/500). Fontsource, MIT/OFL.
- `_sass/_blog-fonts.scss`: `@font-face` for all three; imported by `blog.scss`.
- `_includes/blog-head.liquid`: Google Fonts `<link>` + preconnects removed;
  `<link rel="preload">` added for Literata + Brygada normal.

## Steps

1. **Build.** `cobalt build` → exit 0, no warnings (F-05). Confirm
   `grep -c @font-face site/blog.css` ≥ 7 and slices 01–02 still render.
2. **Network (F-06).** Open a post in a browser; DevTools Network. Confirm the
   woff2 load 200 from `/assets/fonts/…`, and there are **zero requests to
   `fonts.googleapis.com` or `fonts.gstatic.com`**. (The GitHub avatar in the
   author card is a known, separate external request — not part of this slice.)
3. **Rendering (F-07).** Computed `font-family`: an `<h1>` → "Brygada 1918";
   `.prose` body → "Literata"; `.article-meta` / code → "IBM Plex Mono". Not the
   fallback serif/monospace.
4. **Swap/preload (F-08).** No console warning about the preloads; text is
   visible immediately (font-display: swap), upgrading to the webfont.

## Report back

Per row F-01…F-08: `reproduced` / `failed` + evidence (network list, computed
font-family). The one that matters most: **F-06** — zero Google Fonts requests,
fonts served from the site.
