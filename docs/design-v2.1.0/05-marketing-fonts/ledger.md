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
| M-08 | Landing renders its three **actual** families (Lora / Brygada 1918 / Recursive) self-hosted, not fallback. Fraunces/Source Serif are **not used** on the landing (their `@font-face` ship in secondary.css but are never applied or fetched). | CC: computed font-family + document.fonts. | asserted | reproduced (corrected) |
| M-09 | Recursive's mono/casual/slant rendering matches the previous Google-served look (axes via font-variation-settings still work). **[DD-B]** | CC: eyeball a Recursive element. | asserted | reproduced |
| M-10 | No regression: blog (slices 01–04) unchanged; `default.liquid`/`main.css` unaffected. | CC. | asserted | reproduced |

## Notes

- Recursive `full` woff2 ≈ 305 KB (all four axes in one file) — expected for a
  4-axis variable face.
- **Retraction (CC review):** an earlier draft claimed this fixed a
  Fraunces/Source-Serif "Georgia fallback" bug on the landing. Incorrect — the
  landing never uses those two (`_secondary-page.scss` references only
  Lora/Brygada/Recursive). Their `@font-face` now ship in `secondary.css` but are
  unused/unfetched (harmless). Candidate cleanup: a marketing-only fonts partial
  (Lora/Brygada/Recursive) would drop the two dead families — not worth it now.

## Close (2026-07-01)
M-01…M-10 **reconciled** — CC `reproduced` (secondary.css: 11 @font-face, was 0;
zero Google Fonts requests; Recursive axes work). M-08 corrected per CC review
(landing uses Lora/Brygada/Recursive only; no Fraunces/Source-Serif fallback bug —
claim retracted). See `closing-report.md`.
