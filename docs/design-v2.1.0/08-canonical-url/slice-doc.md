# Slice 08 — Fix malformed canonical / OG URLs

_Plan-of-record. Pragmatic tier. Opened 2026-07-02. Fixes the SEO/social defect
CC spotted while closing slice 07._

## Goal

Every page's `<link rel="canonical">` and `og:url` should be a well-formed
absolute URL. Today, on pages whose `page.permalink` has no leading slash (blog
**posts** on Cobalt 0.20.2), they render as
`https://billo.systemsarticles/2026/06/…` — the domain fused to the path with no
slash. This hurts SEO (canonical) and link unfurls (`og:url`).

## Root cause

The five head tags concatenate `{{ site.base_url }}{{ page.permalink }}` with no
separator. `site.base_url` has no trailing slash, and on 0.20.2 `page.permalink`
has **no leading slash for posts** (the same quirk slice 01 fixed in body links +
feeds) but **does** carry one for index pages defined with `permalink: /articles/`
in frontmatter. So a naive `{{ base_url }}/{{ permalink }}` would double-slash the
index pages, and `remove_first: "/"` would wrongly strip an *interior* slash on
posts. The fix must normalise to exactly one leading slash regardless.

## Fix

Replace, in all five locations, the URL expression with:

```liquid
{{ site.base_url }}{{ page.permalink | prepend: "/" | replace: "//", "/" }}
```

- post permalink `articles/2026/06/slug/` → `/articles/2026/06/slug/` → `https://billo.systems/articles/2026/06/slug/`
- index permalink `/articles/` → `//articles/` → `/articles/` → `https://billo.systems/articles/`
- landing `/` → `//` → `/` → `https://billo.systems/`

`prepend` + `replace` are core Liquid filters (present in Cobalt's `liquid`). The
filter runs on the permalink **only** (base_url is concatenated after), so it
can't touch `https://`.

## Locations (5)

1. `_includes/blog-head.liquid` — canonical (blog posts + index pages).
2. `_layouts/secondary.liquid` — `og:url` + canonical (marketing landing).
3. `_layouts/default.liquid` — `og:url` + canonical (unused by content today, but
   fix for correctness).

Feeds (`rss.liquid`, `atom.liquid`) already use `{{ site.base_url }}/{{ post.permalink }}`
(slice 01) and are correct — **leave them**.

## Scope — out

- Changing how Cobalt generates permalinks. This is a template-level normalisation.

## Verification

CC: `cobalt build`; grep the built HTML — **zero** occurrences of
`billo.systemsarticles` (or any `billo.systems` immediately followed by a
non-slash); canonical on a post = `https://billo.systems/articles/<yr>/<mo>/<slug>/`,
on the landing = `https://billo.systems/`; no `https:://` or `systems//articles`
double-slash; feeds still valid. Report the actual `page.permalink` value for a
post vs an index page (confirms the normalisation).

## Exit criteria

Canonical + `og:url` are well-formed absolute URLs on posts, index pages, and the
marketing landing; clean build; no regression.
