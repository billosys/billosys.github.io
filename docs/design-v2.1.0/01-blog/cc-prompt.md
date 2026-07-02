# CC assignment — build & verify the Articles blog (stock Cobalt)

You are CC, running on a machine with **stock Cobalt installed** — the live
deploy path is `scripts/deploy.sh` using the local `cobalt`, currently
**v0.20.2** (the `.github/workflows/deploy.yml` CI file is uncommitted / not in
use; when it is adopted it should pin 0.20.2+). Verify against **0.20.2**. Run
`cobalt --version` to confirm; if it differs, tell CDC so we target the right
one. The version-sensitive features below (DD-2 tag pagination, paginator field
names, custom-`_syntaxes/` scanning) are the ones to watch. CDC (Claude)
authored the blog against the mockup
spine + borrowed LFE mechanics but could not run Cobalt in its sandbox
(crates.io / rustup / GitHub release-assets all firewalled). Your job is the
build gate: run it, confirm the ledger rows that need a real build, and resolve
two version-sensitive design decisions empirically. Report results back so CDC
can `reconcile` the ledger and close the slice.

Repo: `billosys.github.io` (the Cobalt site; `source: "."`, output `site/`).
Do **not** patch Cobalt or add a custom CLI — stock `cobalt build` only.
Plan-of-record: `docs/design-v2.1.0/01-blog/slice-doc.md`; rows: `ledger.md`.

## Step 1 — Build

```bash
cd billosys.github.io
cobalt build 2>&1 | tee /tmp/cobalt-build.log
```

Report: exit code, and the full stderr/stdout. **Warnings count as findings**
(L-06). If the build fails, paste the first error verbatim — do not paper over
it; that is the signal we need.

## Step 2 — Page render checks (L-07…L-10)

Confirm these were generated and open each:

- `site/articles/index.html` — featured lead + "Recent" list + "Earlier
  writing" list; every post link resolves.
- `site/archive/index.html` — year-grouped, newest-first; count matches the 4
  sample posts.
- `site/tags/index.html` — tag directory with per-tag counts (pure-Liquid
  aggregation; should "just work").
- a post, e.g. `site/articles/2026/06/supervision-trees/index.html` — tag chips,
  meta line with reading time, prose, author card, prev/next.

## Step 3 — Resolve DD-2 (single-tag pages) ⚠ highest-value question

`tag.liquid` uses `pagination: { include: Tags }` and reads
`paginator.index_title` / `paginator.pages`. Under the installed Cobalt:

1. Does it generate one page per tag, and at what **permalink**? The tag chips
   throughout the templates link to `/tags/<tag>/` (e.g. `/tags/erlang/`).
   Does the generated permalink match?
2. What are the actual paginator field names (index title, pages) in this
   version?
3. Does the bare `include: Tags` file **also** emit a stray index page that
   collides with the hand-rolled `tags.liquid` directory at `/tags/`?

If the two-file approach fights the engine, switch to LFE's **proven single-file
pattern** (see `lfe.github.io/src/_layouts/blog-tags.liquid` +
`src/blog/tags.md`): one paginated source that renders the directory from
`paginator.indexes` (`.index_title` / `.index_permalink` / `.total_pages`) and
each tag from `paginator.pages`, with `permalink_suffix: "./{{num}}/"`. Report
which approach this Cobalt supports and the exact tag permalink so CDC can make
every `href="/tags/<tag>/"` match.

## Step 4 — Resolve DD-1 (reading time)

`blog-post.liquid` auto-computes reading time from `page.content` when
`data.minutes` is absent. Confirm: temporarily remove `data.minutes` from one
post — does the post still show a sensible "N min read"? Separately, report
whether `post.content` is available and word-countable inside
`{% for post in collections.posts.pages %}` on the index pages (if yes, we can
drop the manual `data.minutes` from the listings too; if no, they stay).

## Step 5 — Feeds (L-13, L-14)

```bash
xmllint --noout site/rss.xml && echo "rss well-formed"
xmllint --noout site/atom.xml && echo "atom well-formed"
```

Also confirm `post.permalink` in the feed `<link>`s is a rooted path (leading
`/`) so `{{ site.base_url }}{{ post.permalink }}` yields a clean URL with no
double slash. If Cobalt's `post.permalink` has no leading slash, tell CDC and
we'll add it.

## Step 6 — Syntax theme (L-02)

```bash
cobalt debug highlight themes | grep -i "Billo Reading Dark" \
  && echo "custom theme loaded" \
  || echo "custom theme NOT loaded — fall back to base16-ocean.dark in _cobalt.yml"
```

## Step 7 — Search is OUT OF SCOPE for this slice

Pagefind search is **deferred to a separate, later CC task** (operator's call).
For this slice, `search.liquid` and `pagefind.yml` are `ignore`d in `_cobalt.yml`
and the Search nav link is removed, so **no `/search/` page and no `/pagefind/`
assets should build**. Do not run pagefind here. If you see a `site/search/`
directory in the output, that's a defect — report it (it means the ignore did
not take). The files stay in the repo, wired and ready for the pagefind slice.

## Step 8 — Deploy-path integration (L-19)

The live deploy path is `scripts/deploy.sh` — it clears the `site/` worktree,
runs `cobalt build` (destination `site`), and commits + pushes the `site`
branch. After a run, confirm the tree contains: `site/articles/index.html`,
`site/archive/index.html`, `site/tags/index.html`, per-tag pages,
`site/rss.xml`, `site/atom.xml`, `site/blog.css`, and posts at
`site/articles/<yr>/<mo>/<slug>/index.html`. Confirm `site/CNAME` is present
(copied from the source root) and that **no `docs/`, `search/`, or `pagefind.yml`
leaked into the output**.

(`.github/workflows/deploy.yml` is **uncommitted / not in use** today; if adopted
it builds with `--destination _site` and should pin Cobalt 0.20.2+. Ignore
unless/until it's the live path.)

## Report back

For each ledger row L-01…L-18: `reproduced` / `failed` / `deferred` + evidence
(a command's output, a generated path, a permalink). Flag anything that needed a
code change so CDC can fold it into the templates and `reconcile` the ledger.
The two answers that matter most: **the real tag permalink (DD-2)** and **a
clean build log (L-06)**.
