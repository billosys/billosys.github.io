# Slice 05 — Self-host the marketing fonts

_Plan-of-record. Pragmatic tier. Opened 2026-07-01. Closes the marketing-side
no-CDN gap flagged in slice 03's bubble-up._

## Goal

Serve all of the marketing site's typefaces from the site itself and remove its
runtime Google Fonts dependency — matching what slice 03 did for the blog.

## Findings that shaped the work

The marketing site uses **six** families. Three were already self-hosted
(`Fraunces`, `Source Serif 4`, `IBM Plex Mono` — `@font-face` in `_sass/_fonts.scss`);
three were pulled from Google Fonts via a `<link>` in `secondary.liquid`
(`Brygada 1918`, `Lora`, `Recursive`).

**Root-cause bug found (and fixed):** `secondary.scss` imported only `tokens` +
`secondary-page` — **not `fonts`** — so the built `site/secondary.css` had
**zero `@font-face` rules**. The marketing landing (which uses
`secondary.liquid` → `secondary.css`) was therefore getting Brygada/Lora/Recursive
*only* from the Google link, while Fraunces and Source Serif were silently
falling back to Georgia. Simply deleting the Google link would have left the
landing with no webfonts at all. The real fix is to make `secondary.css` carry
the `@font-face` rules.

## What changed

1. **Vendored** (Fontsource, npm) into `assets/fonts/`:
   - `Lora` — `lora-latin-wght-{normal,italic}.woff2` (variable weight).
   - `Recursive` — `recursive-latin-full-normal.woff2` (the **full** slice, one
     file carrying all axes the CSS uses: wght + slnt + CASL + MONO; ~305 KB).
   - `Brygada 1918` — already vendored in slice 03; reused, no new file.
2. **`_sass/_fonts.scss`** — added `@font-face` for Brygada 1918 (normal+italic),
   Lora (normal+italic), Recursive (full variable). Now declares all six families.
3. **`secondary.scss`** — added `@import "fonts";` (after `tokens`) so
   `secondary.css` includes the `@font-face` rules. **This is the load-bearing
   change** — it also fixes the pre-existing Fraunces/Source-Serif fallback bug.
4. **`_layouts/secondary.liquid`** — removed the Google Fonts `<link>` + the two
   `preconnect`s. (`default.liquid` → `main.css` already imported `fonts`; it was
   never affected.)

## Scope — out

- Author avatar (blog) — still a separate item.
- Non-latin subsets; a `preload` for the marketing hero face (parity with the
  existing no-preload marketing convention).
- IBM Plex Mono 600 for marketing (only 400/500 declared there; add if a bold
  mono use appears).

## Risks / decisions

- **DD-A `secondary.css` must contain the `@font-face`.** Verified via import
  chain; **CC confirms** `grep @font-face site/secondary.css` = 9 (6 families;
  Brygada/Lora/Fraunces/Source-Serif each have normal+italic, Recursive + the two
  IBM Plex Mono are single) after a build.
- **DD-B Recursive axes.** The `full` woff2 carries wght/slnt/CASL/MONO; the
  marketing components set them via `font-variation-settings`, unchanged. CC
  confirms the mono/casual rendering matches the previous Google-served look.
- **Size.** Recursive full is ~305 KB (all axes in one file) — the price of a
  4-axis variable face; acceptable and cached.

## Verification

Static (done): `secondary.scss` imports `fonts`; no `googleapis`/`gstatic` in any
live template; all eleven `@font-face` woff2 resolve. Build gate → CC
(`cc-prompt.md`): built `secondary.css` carries the `@font-face`; the landing
renders all six families self-hosted with **zero Google Fonts requests**; no
regression to the blog (slices 01–04) or `default.liquid`/`main.css`.

## Exit criteria

Marketing pages render in the six self-hosted families with no Google Fonts
network request, on a clean build; the blog is untouched.
