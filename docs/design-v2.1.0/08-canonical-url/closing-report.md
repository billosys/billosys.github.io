# Closing report — Slice 08 Canonical / OG URL fix

Closed 2026-07-02. Implemented + verified by CC on Cobalt 0.20.2; CDC reconciled
against the report.

## Verdict

**Delivered.** All five head URL expressions (canonical + `og:url` across
`blog-head.liquid`, `secondary.liquid`, `default.liquid`) now normalise the
permalink with `prepend: "/" | replace: "//", "/"`. Malformed URLs are gone: a
post's canonical is `https://billo.systems/articles/<yr>/<mo>/<slug>/`, index and
landing pages are single-slash, and `grep` finds **zero** `billo.systemsarticles`
/ `billo.systems//` in the built site. Feeds unchanged; no regression.

## Per-row walk (all reproduced → reconciled)

CU-01…CU-06 `reproduced` by CC. Root cause confirmed by the permalink asymmetry
CC reported: posts' `page.permalink` = `articles/2026/06/…` (no leading slash,
the 0.20.2 quirk) → old code fused it to the domain; index/landing = `/articles/`
or `/` (has one). `prepend`+`replace` yields exactly one leading slash in both
cases — which is why `remove_first` would have been wrong (it strips a post's
interior slash). Note CU-04: the post `<head>` carries canonical only (no
`og:url`), so nothing else to match there.

## Bubble-up to the project

Eight slices closed: 01 blog · 02 syntax highlighting · 03 blog fonts · 04
search · 05 marketing fonts · 06 shared footer · 07 author avatars · 08
canonical/OG URLs. **The site is now self-hosted end-to-end with well-formed
canonical + social metadata — no known defects.** Ready to ship
(`scripts/deploy.sh`). CC left changes uncommitted (operator's call).
