# Slice 01 — Articles blog

_Plan-of-record for the Billo Systems company blog. Pragmatic framework tier:
this slice-doc + `ledger.md` + `cc-prompt.md`, then build, then verify._

Author: Claude (CDC seat — plan/author/review). Executor: CC (build/verify on
a machine with stock Cobalt installed). Date opened: 2026-07-01.

## Goal

Stand up a company blog on the existing Cobalt site at `billo.systems`, using
**stock Cobalt only** (no Cobalt patches, no custom Rust CLI wrapper), rendered
through Claude Design's approved mockup templates and reachable at `/articles/`.

## Approach (decided with the operator)

- **Spine = the mockups.** `workbench/blog-mockups/templates/` is a Cobalt/Liquid
  port of the approved designs (landing 2a · article 3b · archive 1b · tags
  4a→4b), already written against Billo's conventions (`source: "."`, root-level
  layouts, OKLCH tokens, the marketing site's theme-toggle). It is the v1 spine.
- **LFE = a parts bin, not a template.** `lfe.github.io` is a *different* blog
  engine (its own visual design, `source: "src"`, `/blog/` routes, multi-author
  system). We do **not** clone it. We lift only specific, proven mechanics from
  it: automatic reading-time, RSS + Atom feed Liquid, the single-author bio
  block, pagefind wiring, and — critically — the *known-good* shape of Cobalt's
  `include: Tags` pagination (LFE is a working stock-Cobalt site of the same
  era, so its templates are ground truth for what Cobalt accepts).

## Scope — in

1. **Config** — turn on Cobalt's `posts` collection + `syntax_highlight` in
   `_cobalt.yml` (merged, not replaced; `ignore` for `site/` + `workbench/`
   preserved).
2. **Pages** — `articles.liquid` (landing), `archive.liquid`, `tags.liquid`
   (tag directory), `tag.liquid` (single-tag archive) at the source root.
3. **Layouts** — `_layouts/blog-base.liquid`, `_layouts/blog-post.liquid`.
4. **Includes** — `_includes/blog-head.liquid`, `blog-nav.liquid`,
   `blog-footer.liquid`.
5. **Styling** — `blog.scss` → `/blog.css`; `_sass/_blog.scss` (reads Billo's
   existing primitive tokens — verified present); `_syntaxes/billo-reading-dark.tmTheme`.
6. **Feeds** — `rss.xml` (`/rss.xml`, linked from blog-head) + `atom.xml`
   (`/atom.xml`), ported from LFE, retuned to single-author + `/articles/`.
7. **LFE-borrowed mechanics** — auto reading-time on the post view; single-author
   bio block; `_data/authors.yml` (one entry: Duncan).
8. **Sample content** — the 4 mockup posts (`posts/*.md`), frontmatter retuned:
   **tags only, no categories**.
9. **Marketing integration** — point the marketing footer "Engineering Blog"
   link (and add a nav entry) to `/articles/`.

## Scope — out (explicit non-goals)

- **Categories.** Operator decision: tags-only. No `categories:` in frontmatter,
  no category directory/pages. (LFE has both; we take only tags.)
- **URL back-compat.** No legacy-URL preservation is required (unlike the LFE
  migration). `/articles/` is a clean slate.
- **Custom CLI / Cobalt fork.** LFE's `lfesite` wrapper (prerender, validate,
  version-banner tooling) is **not** ported. Everything must work under stock
  `cobalt build`.
- **Multi-author machinery.** Single-author blog; the authors data file exists
  for the bio block and feed author name, not a browsable author index.
- **Search (pagefind).** Deferred to a later CC slice (operator decision). The
  templates + config exist (`search.liquid`, `pagefind.yml`) but are `ignore`d
  in `_cobalt.yml` and unlinked from the nav, so nothing search-related builds
  in v1 — they sit ready for the pagefind slice.

## Key design decisions & their risks

- **DD-1 Reading time.** Mechanism is auto-compute (LFE's
  `content | strip_html | split | size | divided_by: N`); `data.minutes` in
  frontmatter remains an optional override. Post view computes when `minutes`
  is absent. *Risk:* whether `post.content` is available inside the
  `collections.posts.pages` loop (index pages) is Cobalt-version-dependent →
  **CC to confirm**; if unavailable, index listings keep `data.minutes`.
- **DD-2 Single-tag pages (highest risk).** Primary approach = the mockups'
  two-file split: `tags.liquid` builds the directory with pure Liquid
  (`split`/`uniq`/`sort`/`contains` — version-independent, safe), and
  `tag.liquid` generates per-tag archives via `pagination: { include: Tags }`,
  reading `paginator.index_title` / `paginator.pages`. *Risk:* the generated
  per-tag **permalink** and the paginator field names shift between Cobalt
  releases, and a bare `include: Tags` file may also emit a stray index page.
  **Documented fallback:** LFE's proven single-file pattern — one paginated
  source that renders the directory from `paginator.indexes`
  (`.index_title` / `.index_permalink` / `.total_pages`) and each tag from
  `paginator.pages`. **CC to resolve empirically** and report which approach
  the installed Cobalt supports + the actual tag permalink.
- **DD-3 Pagefind — RESOLVED (deferred).** Search needs a `pagefind --site site`
  post-build step beyond `cobalt build`; operator chose to defer it to its own
  CC slice. `search.liquid` + `pagefind.yml` are `ignore`d and the nav link
  removed, so v1 stays a single `cobalt build`. Files remain wired for the
  follow-up slice.
- **DD-4 `/about/` nav link — RESOLVED.** The mockup nav's `/about/` link had no
  page; replaced with (deferred) Search, then Search removed too — so v1 blog
  nav is Latest / Archive / Tags. Add About/Search back when those pages exist.

## Verification approach

Static checks run in-sandbox (this environment cannot run Cobalt — crates.io,
rustup, and GitHub's release-asset host are firewalled): YAML well-formedness,
Liquid structural sanity, dangling-include / route-link consistency, SCSS import
resolution. The **build gate** is delegated to CC via `cc-prompt.md`: a real
`cobalt build`, a page-by-page render check, feed validity, and empirical
resolution of DD-1/DD-2. The slice closes only when CC reports a clean build and
the ledger rows are attested against that build.

## Exit criteria

See `ledger.md`. In one line: a clean `cobalt build`, all five page types render
at their intended permalinks with correct internal links, feeds validate, the
blog is reachable from the marketing site, and DD-1/DD-2 are resolved (not
assumed).
