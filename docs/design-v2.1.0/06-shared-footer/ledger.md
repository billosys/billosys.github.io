# Ledger — Slice 06 Shared footer

**CC implements**, then verifies. Strength: `asserted` (plan) < `attested`
(static) < `reproduced` (CC build/browser) < `reconciled` (CDC).

| ID | Criterion | Evidence / how | Target |
|----|-----------|----------------|--------|
| SF-01 | `_includes/site-footer.liquid` exists = the marketing footer markup (brand col + Solutions/Resources/Contact + `.footer-bar`). | file present; matches prior `secondary.liquid` footer. | reproduced |
| SF-02 | `_sass/_site-footer.scss` exists = `.footer*` CSS + `--surface-footer`/`--ft-*` token defs (both `[data-theme]` variants), moved out of `_secondary-page.scss`. | file present; `_secondary-page.scss` no longer defines them. | reproduced |
| SF-03 | `secondary.liquid` renders the footer via `{% include 'site-footer.liquid' %}` (no inline `<footer class="footer">`). | grep. | reproduced |
| SF-04 | `secondary.scss` **and** `blog.scss` both `@import "site-footer"`. | grep both. | reproduced |
| SF-05 | Blog footer swapped to the shared footer: `blog-footer.liquid` includes `site-footer.liquid` **and** still contains the theme-toggle `<script>`. **[DD-A]** | grep; read. | reproduced |
| SF-06 | Lora + Recursive `@font-face` present in the blog CSS path (`_blog-fonts.scss`); `blog.css` build carries them. **[DD-B]** | `grep -c @font-face site/blog.css` up by 3 (Lora ×2 + Recursive); footer computed font-family = Lora/Recursive on a blog page. | reproduced |
| SF-07 | Clean `cobalt build`, no warnings. | CC. | reproduced |
| SF-08 | **Marketing footer visually unchanged** after the refactor (structure + colours + fonts identical to before). **[DD-D]** | CC: compare landing footer before/after (screenshot or DOM+computed styles). | reproduced |
| SF-09 | **Blog footer visually matches** the marketing footer — same columns, colours, fonts, spacing — on a blog page. | CC: side-by-side landing vs a post. | reproduced |
| SF-10 | Footer themes correctly in **both** light and dark on **both** marketing and blog (tokens resolve in both stylesheets). **[DD-C]** | CC: toggle each; `--surface-footer`/`--ft-*` compute to the green ladder. | reproduced |
| SF-11 | Blog light/dark **toggle still works** (script preserved; `#themeToggle` in nav drives it). **[DD-A]** | CC: click toggle on a post; persists across nav. | reproduced |
| SF-12 | No regression to slices 01–05 (blog pages/feeds/highlighting/fonts/search; marketing landing). | CC. | reproduced |
| SF-13 | Dead `.blog-footer*` rules removed from `_blog-components.scss` (or explicitly left with a note). | grep. | reproduced |
| SF-14 | Shared footer's Resources column includes an `RSS → /rss.xml` link (operator-decided). | grep `site-footer.liquid`; visible on both landing + blog footer. | reproduced |
| SF-15 | Copyright year is dynamic: `{{ site.time \| date: "%Y" \| default: "2026" }}`. CC reports whether `site.time` resolves on 0.20.2 or falls back. **[DD-F]** | read `site-footer.liquid`; check rendered year in built HTML. | reproduced |

## Operator decisions — LOCKED

1. **DD-E:** **Add** an `RSS → /rss.xml` link to the shared footer's Resources
   column. (Appears on marketing too — fine.)
2. **DD-F:** **Compute the year dynamically** via
   `{{ site.time | date: "%Y" | default: "2026" }}`. Verify `site.time` populates
   on 0.20.2; if not, it renders `2026` via the default (note it).

## Open questions for CC

1. **DD-D:** After extracting the footer CSS/markup, is the marketing landing
   footer pixel-identical? If any rule was left behind in `_secondary-page.scss`
   (e.g. a selector nested under a marketing-only parent), report it.
2. **DD-C:** Do `--ft-*`/`--surface-footer` resolve on the blog once the partial
   is imported, or did a light/dark block get missed in the move?
