# Closing report — Slice 03 Self-host blog fonts

Closed 2026-07-01. Build gate: CC on stock Cobalt 0.20.2 (live browser render).
CDC cross-checked on disk.

## Verdict

**Delivered.** The blog serves Brygada 1918, Literata, and IBM Plex Mono from
`/assets/fonts/`; CC confirmed **zero requests to fonts.googleapis.com /
gstatic** on a post, `document.fonts` shows all three actually loaded (not
fallback), and every `@font-face` carries `font-display: swap`. All eight rows
`reproduced` → `reconciled`; no regression to slices 01–02.

## Per-row walk (reconciled)

F-01…F-08 → `reproduced` by CC, `reconciled` by CDC. Key: F-06 (no Google Fonts
requests, woff2 200 from the site), F-07 (computed font-family = the three
self-hosted families). CC's note that only 5 of 7 woff2 were fetched on that page
is correct lazy loading (IBM Plex Mono 500/600 weren't needed by the content),
not a gap.

## Bubble-up to the project

1. **Delivered its piece:** the no-CDN gap slice 02 flagged is closed *for the
   blog* — fonts fully self-hosted.
2. **Still open (disclosed, out of scope):**
   - **Author avatar** — `avatars.githubusercontent.com` is the sole remaining
     external loaded resource on blog pages. Vendoring = freeze image + an
     `authors.yml` `avatar` field + a template branch. Operator decision.
   - **Marketing `secondary.liquid`** — still loads Brygada/Lora/Recursive from
     Google Fonts. Same no-CDN gap on the marketing side; candidate marketing
     slice (Brygada is already vendored now and could be shared).
3. **Silent-drop diff:** none.

## Project status after this slice

Blog (01) + syntax highlighting (02) + self-hosted fonts (03) all closed.
Remaining candidate work: pagefind **search** (wired, ignored, needs a deploy
step); **avatar** self-host; **marketing-fonts** self-host; minor hardening
(guard `data.minutes` in listings; tag-directory article count); bump the
uncommitted CI workflow to Cobalt 0.20.2+.
