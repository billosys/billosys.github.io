# Ledger — Slice 05 Self-host marketing fonts

Strength: `asserted` < `attested` (static) < `reproduced` (CC) < `reconciled`.

| ID | Criterion | Evidence / how | Open | Target |
|----|-----------|----------------|------|--------|
| M-01 | `Lora` (normal+italic) + `Recursive` (full) woff2 vendored in `assets/fonts/`. | `ls assets/fonts/`. | attested | reconciled |
| M-02 | `_sass/_fonts.scss` declares `@font-face` for all six families (Fraunces, Source Serif 4, IBM Plex Mono, Brygada 1918, Lora, Recursive). | `grep font-family _sass/_fonts.scss`. | attested | reconciled |
| M-03 | `secondary.scss` imports `fonts`. | `grep '@import "fonts"' secondary.scss`. | attested | reconciled |
| M-04 | No `googleapis`/`gstatic` in any live template (`secondary.liquid` link removed; `default.liquid` never had it). | `grep -ri googleapis _layouts _includes` (excl. workbench). | attested | reconciled |
| M-05 | Every `@font-face` src resolves to a real woff2. | static check (done). | attested | reconciled |
| M-06 | Clean build; **`site/secondary.css` contains the `@font-face` rules** (was 0 before). **[DD-A]** | CC: `grep -c @font-face site/secondary.css` ≥ 6. | asserted | reproduced |
| M-07 | Marketing landing loads its fonts from `/assets/fonts/`; **zero requests to fonts.googleapis.com / gstatic**. | CC: devtools network on the landing. | asserted | reproduced |
| M-08 | Landing renders all six families (incl. Fraunces/Source Serif, previously falling back to Georgia) — `document.fonts` shows them loaded. | CC: computed font-family + document.fonts. | asserted | reproduced |
| M-09 | Recursive's mono/casual/slant rendering matches the previous Google-served look (axes via font-variation-settings still work). **[DD-B]** | CC: eyeball a Recursive element. | asserted | reproduced |
| M-10 | No regression: blog (slices 01–04) unchanged; `default.liquid`/`main.css` unaffected. | CC. | asserted | reproduced |

## Notes

- Recursive `full` woff2 ≈ 305 KB (all four axes in one file) — expected for a
  4-axis variable face.
- This slice also fixed a **pre-existing** bug: `secondary.css` had no
  `@font-face`, so Fraunces/Source Serif fell back to Georgia on the landing.
