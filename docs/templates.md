# Articles — Cobalt blog templates

Template-ready port of the approved blog mockups, wired to Cobalt's built-in
post collection. Design decisions locked with the mockups in the parent
folder:

| Page              | Design | Template |
|-------------------|--------|----------|
| Landing `/articles/` | **2a** — featured lead → recent (full) → earlier (compact) | `articles.liquid` |
| Article view      | **3b** — reading column + margin sidenotes | `_layouts/blog-post.liquid` |
| Archive `/archive/` | **1b** — year-grouped ledger | `archive.liquid` |
| Tags `/tags/`     | **4a** — tag directory with counts | `tags.liquid` |
| Single tag `/tags/<tag>/` | **4b** — single-tag archive | `tag.liquid` |

Type system: **Brygada 1918** (display) · **Literata** (long-form body) ·
**IBM Plex Mono** (metadata + code). Manual dark/light toggle (same widget as
the marketing site), set before first paint to avoid a flash. All colours read
the site's existing OKLCH primitive tokens.

## File map

```
blog.scss                      → compiles to /blog.css   (put at source root)
_sass/_blog.scss               → reading tokens + all component classes
_includes/blog-head.liquid     → <head>: fonts, css, pre-paint theme, meta
_includes/blog-nav.liquid      → sticky masthead + theme toggle
_includes/blog-footer.liquid   → footer + toggle behaviour script
_layouts/blog-base.liquid      → shell for index pages (nav + main + footer)
_layouts/blog-post.liquid      → the 3b article view (posts default layout)
articles.liquid                → /articles/  (landing, design 2a)
archive.liquid                 → /archive/   (design 1b)
tags.liquid                    → /tags/      (design 4a)
tag.liquid                     → /tags/<tag>/ (design 4b, tag pagination)
posts/*.md                     → 4 sample posts (real frontmatter + code)
_syntaxes/billo-reading-dark.tmTheme → palette-matched syntect theme
_cobalt.additions.yml          → blocks to merge into your _cobalt.yml
```

## Install

1. Copy `blog.scss` and the `_sass/`, `_includes/`, `_layouts/`, `posts/`
   files into the repo root (merging with the existing `_sass` / `_includes`
   / `_layouts`). Copy `articles.liquid`, `archive.liquid`, `tags.liquid`,
   `tag.liquid` to the source root next to `index.liquid`.
2. Merge `_cobalt.additions.yml` into `_cobalt.yml` (see that file's comments).
3. Add a nav link to the blog from the marketing site (e.g. **Writing →
   `/articles/`** in `secondary.liquid`).
4. `cobalt build` and open `/articles/`.

## Post frontmatter

```yaml
---
title: Supervision Trees Are a Philosophy, Not a Feature
description: The dek/standfirst shown on cards and under the title.
published_date: 2026-06-18 09:00:00 -0600
tags: [erlang, otp]
data:
  author: Duncan McGregor
  minutes: 11          # reading time (Cobalt doesn't compute this)
---
```

- **Reading time** is manual (`data.minutes`) — Cobalt has no word-count
  filter. If you'd rather automate it, add a tiny build step or a data file.
- **Margin sidenotes**: drop `<aside class="sidenote">…</aside>` inline in the
  markdown; it floats into the right column on wide screens and collapses
  inline on narrow ones. See `posts/supervision-trees.md`.
- **Code with a filename bar**: a plain ```` ```erlang ```` fence is styled by
  `.prose > pre`. For the full chrome (filename + language tag), wrap it:

  ```html
  <figure class="code-figure">
    <div class="code-figure__bar">
      <span class="code-figure__name">bank_sup.erl</span>
      <span class="code-figure__lang">Erlang</span>
    </div>
    <pre><code>…your code…</code></pre>
  </figure>
  ```

## Math (KaTeX)

Set `data.math: true` in a post's frontmatter to load **KaTeX** on that post
(and only that post — `blog-post.liquid` guards on the flag, so posts without it
pay nothing). Write LaTeX inline with `$…$` and display with `$$…$$`; KaTeX
renders it in the browser on load.

KaTeX is **vendored, not CDN-loaded** (matches the site's no-CDN policy):
`scripts/fetch-katex.sh` downloads a pinned release into `assets/katex/`
(CSS + JS + auto-render + woff2 fonts). Re-run it to refresh or bump the
version; commit the result.

⚠ **Backslash-before-punctuation must be doubled.** Cobalt's markdown
(pulldown-cmark, not configurable on 0.20.2) runs *before* KaTeX and strips the
backslash from any `\` + ASCII-punctuation escape — so `\{`, `\}`, `\;`, `\,`,
`\_`, `\|`, `\%`, `\#`, `\&` reach KaTeX as bare `{`, `}`, `;`, … and render
wrong. Backslash-before-*letter* (`\to`, `\frac`, `\mathrm`, `\in`, …) is safe.
Double the punctuation ones in source so one backslash survives:

```latex
$$\\{(s,c) \to c \\;:\\; \text{card}(s,c)\\}$$   ← authored as \\{  \\;  \\}
$\mathrm{asserted\\_by}$                          ← authored as \\_
```

Verify a post's math renders by extracting the `$…$` spans from the built HTML
and running them through `katex.renderToString(expr, {throwOnError:true})` — a
clean pass means the browser will render them. (Trade-off: the doubled
backslashes are Cobalt-specific and won't render on GitHub's markdown preview;
if source portability matters, a build-time preprocessor is the alternative.)

## Verify against your Cobalt version ⚠

Two things shift between Cobalt releases and can't be confirmed without a
build here:

1. **Tag pagination** (`tag.liquid`). It uses `pagination: { include: Tags }`
   and reads `paginator.index_title` / `paginator.pages`. If your version names
   these differently, adjust the two references at the top of `tag.liquid`.
   The tag-chip links assume tag pages live at `/tags/<tag>/` — make the
   generated permalink match (or update the links in `blog-post.liquid`,
   `articles.liquid`, `archive.liquid`, `tags.liquid`).
2. **Prev/next** in `blog-post.liquid` finds the current post by index in
   `collections.posts.pages`. If your version exposes `page.previous` /
   `page.next`, swapping to those is simpler.

The tag directory (`tags.liquid`) aggregates counts with only core Liquid
(`split` / `uniq` / `sort` + `contains`), so it needs no plugins.

## Palette-matched code highlighting

Shipped: **`_syntaxes/billo-reading-dark.tmTheme`** — a syntect theme whose
colours are the sRGB renderings of the site's OKLCH tokens (ochre keywords,
green functions/strings, cream variables, neutral operators, on the
`green-950` panel).

Wire it up:

1. Put `_syntaxes/billo-reading-dark.tmTheme` at the project root.
2. In `_cobalt.yml`: `syntax_highlight: { enabled: true, theme: "Billo Reading Dark" }`
   (that string is the theme's internal `<key>name</key>`, not the filename).
3. Confirm Cobalt loaded it: `cobalt debug highlight themes` should list
   **Billo Reading Dark**. If it doesn't, your Cobalt build may not scan
   `_syntaxes/` for themes — in that case keep `base16-ocean.dark` and the
   `.code-figure` CSS chrome still frames it cleanly.

**Why the code panel stays dark in light mode:** syntect bakes one theme's
colours into the HTML at build time, so a single theme serves both site
modes. Rather than fight that, `_blog.scss` pins the code panel to the dark
palette in both themes — a dark code block on the cream light theme is a
deliberate, high-legibility pattern. (A runtime light/dark code swap would
need class-based highlighter output, which Cobalt/syntect doesn't emit.)

Want a `.sublime-syntax` for Erlang or any language `cobalt debug highlight
syntaxes` doesn't list? Drop it in the same `_syntaxes/` folder.
