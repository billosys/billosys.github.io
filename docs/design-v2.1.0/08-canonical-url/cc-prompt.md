# CC assignment — fix malformed canonical / OG URLs (slice 08) — IMPLEMENT + verify

You are CC on stock **Cobalt 0.20.2**. Quick, high-priority SEO/social fix you
spotted closing slice 07: on blog **posts**, `<link rel="canonical">` and
`og:url` render as `https://billo.systemsarticles/2026/06/…` — domain fused to
path, no slash — because `page.permalink` has no leading slash on 0.20.2 while
`site.base_url` has no trailing slash.

Plan: `docs/design-v2.1.0/08-canonical-url/slice-doc.md`; rows: `ledger.md`.

## The fix (all 5 locations)

Replace `{{ site.base_url }}{{ page.permalink }}` with:

```liquid
{{ site.base_url }}{{ page.permalink | prepend: "/" | replace: "//", "/" }}
```

This normalises the permalink to exactly one leading slash and works whether or
not it already has one (posts don't; index pages defined with `permalink:
/articles/` do). Do **not** use `remove_first: "/"` — it would strip an *interior*
slash on posts. The filter runs on the permalink only, so it can't touch
`https://`.

**Locations:**
1. `_includes/blog-head.liquid` — the `canonical` line (blog posts + index pages).
2. `_layouts/secondary.liquid` — the `og:url` line **and** the `canonical` line.
3. `_layouts/default.liquid` — the `og:url` line **and** the `canonical` line.

**Leave the feeds alone** — `rss.liquid` / `atom.liquid` already use
`{{ site.base_url }}/{{ post.permalink }}` (slice 01) and are correct.

## Verify (report per row CU-01…CU-06)

1. `cobalt build` — exit 0, no warnings (the `prepend`/`replace` filters are core
   Liquid; confirm they're accepted).
2. **Zero malformed URLs:** `grep -rEo 'https://billo\.systems[^/"]{1,20}' site/`
   returns nothing. In particular no `billo.systemsarticles` and no
   `billo.systems//`.
3. **Post head:** open a built post (e.g.
   `site/articles/2026/06/supervision-trees/index.html`) — canonical + og:url =
   `https://billo.systems/articles/2026/06/supervision-trees/`.
4. **Index + landing:** canonical on `site/articles/index.html`, `site/tags/index.html`,
   and the marketing landing are well-formed (single slash, e.g.
   `https://billo.systems/articles/` and `https://billo.systems/`).
5. **No regression:** feeds still `xmllint`-clean; pages/highlighting/search/footer fine.
6. Report the raw `page.permalink` for a post vs an index page (confirms the fix).

## Report back

Per row CU-01…CU-06. The one that matters: **CU-03/CU-04** — no malformed URLs,
and a post's canonical is a clean absolute URL.
