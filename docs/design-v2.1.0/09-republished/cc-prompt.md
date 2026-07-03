# CC assignment — verify the Republished notice (slice 09)

You are CC on stock **Cobalt 0.20.2**. CDC implemented a conditional "Republished"
notice on the article view; you verify it builds and renders per the mockup.

Plan: `docs/design-v2.1.0/09-republished/slice-doc.md`; rows: `ledger.md`.

## What changed (on disk)

- `_layouts/blog-post.liquid` — `{% if page.data.republished %}` block (between
  `</header>` and `.prose`): source link + `original_date | date: "%B %-d, %Y"` +
  license.
- `_sass/_blog-components.scss` — `.republished*` classes matching the mockup
  `workbench/blog-mockups/Blog Article (3b) - Republished.html`.

Test post already exists: `posts/2026/graph-theory-in-lfe-graffeo-erlang-knowledge.md`
(carries `data.republished` + `data.math: true`).

## Steps

1. **Build (RP-03).** `cobalt build` — exit 0, no warnings.
2. **Republished post (RP-04, DD-A).** Open the built graph-theory post. Confirm
   the notice reads: eyebrow **Republished**, then "Originally posted on **The LFE
   Blog** on **June 5, 2026**. Republished here **with permission**.", and the
   source name is an `<a href>` to the `source_url`. **Report the rendered date
   string** — the `original_date` is nested under `data.republished`; confirm the
   `date:` filter formatted it (if it rendered raw/empty, that's DD-A — report it).
3. **Style (RP-05).** The notice matches the mockup — surface-raised box, 2px
   accent left-border, rounded right, ↗ mono accent icon, uppercase mono eyebrow —
   and is legible in **both** light and dark (toggle).
4. **Absence (RP-06, DD-B).** Open a non-republished post (e.g. supervision-trees)
   — **no** notice, no empty box. `grep -c republished` on that built file = 0.
5. **No regression (RP-07).** Slices 01–08 intact.

## Note (out of scope, don't fix here)

`data.math: true` on that post implies math rendering. LFE used CDN KaTeX; Billo
is no-CDN, so math is a **separate** slice (self-hosted KaTeX). Ignore any
unrendered `$…$` for now.

## Report back

Per row RP-01…RP-07 + the rendered date string (DD-A). The ones that matter:
**RP-04** (notice renders correctly, date formatted) and **RP-06** (absent when
no metadata).
