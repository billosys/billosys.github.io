# Closing report — Slice 07 Vendor author avatars

Closed 2026-07-02. Script run + verified by CC on a networked machine; CDC
reconciled against the report + on-disk state.

## Verdict

**Delivered.** `scripts/fetch-avatars.sh` vendored `@oubiwann`'s avatar
(`assets/images/authors/oubiwann.png`, image/png, 86,788 B), wrote
`avatar: /assets/images/authors/oubiwann.png` into `_data/authors.yml`, and the
author card now serves it locally. **AV-06 green: a blog post makes zero external
resource requests** — every `src`/`url()`/`@font-face`/preload is a local `/…`
path; the only remaining `https://` are anchor `href=` profile links (user
clicks, not page requests). The site no longer reaches any external host at
render time.

## Per-row walk (all reproduced → reconciled)

AV-01…AV-08 `reproduced` by CC. Highlights: AV-04 (one correctly-indented
`avatar:` line, no duplicate), AV-05 (all 5 built posts' `<img src>` = the local
path), AV-07 (second run byte-identical — idempotent), AV-08 (no regression).
Detected extension: `.png` (the script's type-detection worked as designed).

## Notes

- **Verification method:** AV-06 was confirmed by static analysis of the built
  HTML/CSS (exhaustive grep of resource-loading references), not a live DevTools
  Network capture — conclusive here since there are no remaining external
  resource references. A browser check is optional belt-and-suspenders.
- **Out-of-scope bug CC spotted (tracked separately):** the post `<head>`
  canonical/OG URL renders malformed — `https://billo.systemsarticles/2026/…`
  (missing slash) because `page.permalink` has no leading slash on Cobalt 0.20.2
  (the same quirk slice 01 fixed in body links + feeds, but the `blog-head`
  canonical/OG lines were missed). It's an `href`/`meta` value, not a request, so
  it doesn't affect this slice — but it's a real SEO/social defect worth a small
  follow-up. Fix: `{{ site.base_url }}/{{ page.permalink | remove_first: "/" }}`
  (robust whether or not the permalink carries a leading slash).

## Bubble-up to the project

Seven slices closed: 01 blog · 02 syntax highlighting · 03 blog fonts · 04
search · 05 marketing fonts · 06 shared footer · 07 author avatars. **The
no-CDN goal is fully closed** — the site is self-hosted end to end. Remaining
tracked item: the canonical/OG leading-slash fix (candidate slice 08, trivial).
CC has not committed; committing is the operator's call.
