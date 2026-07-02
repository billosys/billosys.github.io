# Closing report — Slice 01 Articles blog

Closed 2026-07-01. Build gate: CC on stock Cobalt 0.20.2. CDC (Claude)
cross-checked all structural changes against the on-disk state.

## Verdict

**Delivered.** A working company blog at `/articles/` on stock Cobalt — landing,
per-post reading view, year-grouped archive, tag directory + per-tag archives,
RSS + Atom feeds, single-author bio, reachable from the marketing site. Clean
`cobalt build`, `deploy.sh` tree verified, no `docs/` leak.

## Per-row walk (reconciled)

L-01…L-19 → `reproduced` by CC on 0.20.2, `reconciled` by CDC. L-02 landed as
the documented fallback (see slice 02, which supersedes it). L-16 (search)
`deferred` by operator decision.

## What implementing it revealed (7 fixes CC made — scope-as-delivered)

The plan was authored against Cobalt behaviour that couldn't be tested in CDC's
sandbox; the real 0.20.2 build surfaced seven corrections, all now on disk:

1. **Syntax theme** → `base16-ocean.dark` (then superseded by slice 02): custom
   `.tmTheme` unloadable on 0.20.2.
2. **SCSS self-import** — `_blog.scss` renamed `_blog-components.scss` (an
   `@import "blog"` resolved to itself).
3. **`articles.liquid`** — `offset:1 limit:4` crashes the engine; replaced with
   `offset:1` + `{% break %}`.
4. **Tags (DD-2)** — the two-file design can't work; merged to LFE's single-file
   `paginator.indexes` pattern (`tags.liquid` deleted, `tag.liquid` rewritten).
   Tag permalink confirmed `/tags/<tag>/`.
5. **Permalink leading slash** — `post.permalink` has no leading `/` on 0.20.2;
   added across all templates + feeds.
6. **Feeds** — `layout: null` doesn't disable layout on 0.20.2; added a
   passthrough `_layouts/feed.liquid`.
7. **Reading time (DD-1)** — missing-key access throws; rewritten to compute
   fallback then override only if `minutes` present.

Plus a CDC catch: the `authors.yml` rename to **"Duncan McGreggor"** left posts
and template fallbacks on the single-g spelling (exact-match miss → dropped bio
card); aligned all posts + defaults to the authoritative spelling.

## Bubble-up to the project

- **Delivered its capability** as the roadmap defined it (minus search, deferred).
- **Carried forward:** slice 02 (syntax highlighting) — done. Deferred/candidate
  work now recorded at project level: **search/pagefind** (files wired, ignored),
  **self-host blog fonts** (slice-02 finding), and minor hardening
  (tag-directory article count lost on paginated pages; guard `data.minutes` in
  listings against a future post that omits it).
- **Version note:** live build/deploy is `deploy.sh` on local Cobalt 0.20.2; the
  uncommitted CI workflow still pins 0.19.7 — bump to 0.20.2+ before it goes live.
- **Silent-drop diff:** none undisclosed.
