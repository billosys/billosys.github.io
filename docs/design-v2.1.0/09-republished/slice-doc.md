# Slice 09 — Republished notice

_Plan-of-record. Pragmatic tier. Opened 2026-07-02. CDC implemented; CC verifies._

## Goal

Show a "Republished" notice on the article view **only** when a post carries
`data.republished` metadata — for pieces first published elsewhere (e.g. The LFE
Blog) and re-run here with permission.

## Frontmatter contract

```yaml
data:
  republished:
    source_name: The LFE Blog
    source_url: https://lfe.io/blog/…/
    original_date: 2026-06-05 10:08:00 -0600
    license: "with permission"
```

## What changed

- **`_layouts/blog-post.liquid`** — a conditional block between the article
  `</header>` and `.prose`: `{% if page.data.republished %}` renders the notice,
  else nothing. Renders `source_name` as a link to `source_url`, the
  `original_date` via `| date: "%B %-d, %Y"`, and the `license` phrase.
- **`_sass/_blog-components.scss`** — `.republished*` classes matching the mockup
  `workbench/blog-mockups/Blog Article (3b) - Republished.html`: an `<aside>`
  (surface-raised, `--rule` border, 2px `--accent` left-border, rounded right),
  an ↗ mono accent icon, a mono uppercase `--accent-ink` "Republished" eyebrow,
  and a body line in `--ink-secondary`.

Design values are token-based (`--surface-raised`, `--accent`, `--font-*`,
`--step-*`, `--ink-*`, `--rule*`) so the notice themes correctly in dark/light.

## Scope — out

- **`math: true`** (also in the example frontmatter) — implies math rendering
  (LFE used CDN KaTeX). Billo is no-CDN, so math needs **self-hosted KaTeX** — a
  separate slice, not this one.
- Optional `license` handling — currently the sentence assumes `license` is
  present (per the schema). If it should be droppable, guard it in a follow-up.

## Risks / decisions

- **DD-A Nested date rendering.** `original_date` sits under
  `data.republished`; YAML parses it as a timestamp. The `date:` filter should
  format it either way (string or datetime) → CC confirms the rendered date reads
  "June 5, 2026".
- **DD-B Absence = no banner.** Posts without `data.republished` (the 4 sample
  posts) must render with **no** notice and no empty box.

## Verification (see `ledger.md`)

CC: build; the example post
(`posts/2026/graph-theory-in-lfe-graffeo-erlang-knowledge.md`) shows the notice
with correct source link + formatted date + license, styled per the mockup, in
both themes; the 4 non-republished posts show nothing. Clean build; no regression.

## Exit criteria

Republished notice renders correctly and conditionally, matching the mockup, in
both themes; absent on non-republished posts.
