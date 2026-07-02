# CC assignment — verify self-hosted marketing fonts (slice 05)

You are CC on stock **Cobalt 0.20.2**. The blog (slices 01–04) is closed; this
slice self-hosts the **marketing** site's fonts and removes its Google Fonts
dependency. CDC authored the changes; you run the build gate.

Plan: `docs/design-v2.1.0/05-marketing-fonts/slice-doc.md`; rows: `ledger.md`.

## What changed (on disk)

- `assets/fonts/`: `lora-latin-wght-{normal,italic}.woff2`,
  `recursive-latin-full-normal.woff2` (Brygada already present from slice 03).
- `_sass/_fonts.scss`: `@font-face` for Brygada 1918, Lora, Recursive added
  (now all six marketing families).
- `secondary.scss`: `@import "fonts";` added — **the load-bearing change**;
  `secondary.css` previously had **zero** `@font-face`.
- `_layouts/secondary.liquid`: Google Fonts `<link>` + preconnects removed.

## Steps

1. **Build (M-06).** `cobalt build` → exit 0. Then the key check:
   `grep -c @font-face site/secondary.css` — must be ≥ 6 (was 0 before). Also
   confirm `site/main.css` still has its 6 (default.liquid path unaffected).
2. **Network (M-07).** Open the marketing landing (`/`) in a browser; DevTools
   Network. Fonts load 200 from `/assets/fonts/`; **zero requests to
   fonts.googleapis.com / gstatic**.
3. **Rendering (M-08, M-09).** `document.fonts` (or computed font-family) shows
   all six loaded — especially Fraunces + Source Serif, which previously fell
   back to Georgia on this page. Eyeball a Recursive element (mono/casual) — it
   should look as it did with Google Fonts (axes via font-variation-settings).
4. **No regression (M-10).** Blog pages (slices 01–04) unchanged; the landing's
   layout/type looks right.

## Report back

Per row M-01…M-10: `reproduced` / `failed` + evidence. The one that matters
most: **M-06/M-07** — `secondary.css` carries the `@font-face` and the landing
makes zero Google Fonts requests. Flag anything that needed a change.
