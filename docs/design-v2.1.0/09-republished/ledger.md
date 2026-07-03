# Ledger — Slice 09 Republished notice

Strength: `asserted` < `attested` (static) < `reproduced` (CC build) < `reconciled`.

| ID | Criterion | Evidence / how | Open | Target |
|----|-----------|----------------|------|--------|
| RP-01 | `blog-post.liquid` has an `{% if page.data.republished %}` block between `</header>` and `.prose`, rendering source link + `date`-filtered `original_date` + license. | grep. | attested | reconciled |
| RP-02 | `.republished*` CSS present in `_blog-components.scss`; all `var(--…)` tokens exist. | static token check (done). | attested | reconciled |
| RP-03 | Clean `cobalt build`, no warnings. | CC. | asserted | reproduced |
| RP-04 | The example post renders the notice: eyebrow "Republished", "Originally posted on **The LFE Blog** on June 5, 2026. Republished here with permission.", source is a link to the `source_url`. **[DD-A]** | CC: open the built post. | asserted | reproduced |
| RP-05 | Notice styled per mockup (surface-raised box, 2px accent left-border, ↗ icon, mono eyebrow) and legible in **both** themes. | CC: view + toggle. | asserted | reproduced |
| RP-06 | The 4 non-republished sample posts render **no** notice (no empty box). **[DD-B]** | CC: open one; grep for `republished` = none. | asserted | reproduced |
| RP-07 | No regression to slices 01–08. | CC. | asserted | reproduced |

## Notes

- `math: true` (in the example frontmatter) is **out of scope** — it implies
  self-hosted KaTeX (no-CDN), a separate slice.
- If CC finds the nested `original_date` doesn't format (DD-A), the fix is to
  quote it as a string in frontmatter or adjust the filter — report the rendered
  value.
