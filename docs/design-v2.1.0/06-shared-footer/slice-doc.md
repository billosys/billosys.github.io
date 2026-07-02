# Slice 06 — One footer across the whole site

_Plan-of-record. Pragmatic tier. Opened 2026-07-01. **CC implements this slice**
(not just verifies); CDC authored the plan. Depends on slices 01–05._

## Goal

Give the blog the marketing site's footer, so the footer is consistent
everywhere. Do it as a **single shared source** (one markup fragment, one CSS
partial) rather than a copy — so the two can't drift apart later. "The same" is
achieved by *sharing*, not duplicating.

## Why this is more than a copy-paste (the finagling)

The marketing footer and the blog footer live in different worlds, and three
dependencies don't currently reach the blog:

1. **Markup** is inline in `_layouts/secondary.liquid` (`<footer class="footer">…`),
   not a shared include. The blog uses `_includes/blog-footer.liquid`.
2. **CSS + tokens.** The `.footer*` rules live in `_sass/_secondary-page.scss`
   (compiled only into `secondary.css`). They depend on footer-specific tokens —
   `--surface-footer`, `--ft-border`, `--ft-text`, `--ft-heading`, `--ft-bar-bdr`,
   `--ft-copy` — defined there under **both** `[data-theme="dark"]` and
   `[data-theme="light"]`. **Blog pages load `blog.css`, not `secondary.css`**, so
   none of this reaches the blog today.
3. **Fonts.** The footer uses **Lora** and **Recursive** directly. Those are
   self-hosted (slice 05) but wired only into `secondary.css`/`main.css` — **not
   `blog.css`** (the blog only self-hosts Brygada/Literata/IBM Plex Mono).

And one thing must be **preserved**: `_includes/blog-footer.liquid` also carries
the **theme-toggle behaviour `<script>`** that the blog nav's toggle button
(`#themeToggle`) depends on. The marketing footer markup does *not* contain it
(marketing's toggle script is inline in `secondary.liquid`). If the blog footer
is swapped out naively, the blog's light/dark toggle breaks.

## Approach (single shared source)

Create two shared artifacts and point both sides at them:

- **`_includes/site-footer.liquid`** — the footer **markup**, moved verbatim from
  `secondary.liquid` (the `.footer` block: brand col + Solutions/Resources/Contact
  columns + `.footer-bar` copy/legal).
- **`_sass/_site-footer.scss`** — the footer **CSS** (`.footer*` rules) **and** the
  footer **token definitions** (`--surface-footer` + `--ft-*`, both `[data-theme]`
  variants), moved from `_secondary-page.scss`. Imported by **both**
  `secondary.scss` and `blog.scss`, so the footer renders identically in both
  stylesheets.

Wiring:
- `secondary.liquid`: replace the inline `<footer class="footer">…</footer>` with
  `{% include 'site-footer.liquid' %}`. Leave its toggle/reveal script as-is.
- `_secondary-page.scss`: remove the moved `.footer*` rules + footer token defs
  (now shared). `secondary.scss`: `@import "site-footer";`.
- `blog.scss`: `@import "site-footer";` (footer CSS + tokens reach `blog.css`).
- **Blog fonts:** add `@font-face` for **Lora** + **Recursive** to the blog font
  path (`_sass/_blog-fonts.scss`, reusing the slice-05 woff2 in `assets/fonts/`),
  so the footer's Lora/Recursive render on the blog instead of falling back.
- **Preserve the toggle:** `_includes/blog-footer.liquid` becomes a thin wrapper —
  `{% include 'site-footer.liquid' %}` followed by the **existing theme-toggle
  `<script>` unchanged**. Blog layouts already include `blog-footer.liquid`, so
  they need no edit. (Alternatively move the script into the blog layouts and
  delete `blog-footer.liquid` — wrapper is lower-churn.)
- Remove the now-dead `.blog-footer*` rules from `_blog-components.scss`
  (cleanup; leaving them is harmless but confusing).

## Key decisions & risks (for CC to watch)

- **DD-A Preserve the theme toggle.** The blog's light/dark toggle must still work
  after the swap — the toggle `<script>` must survive (keep it in the thin
  `blog-footer.liquid`). Verify by toggling on a blog page.
- **DD-B Footer fonts on the blog.** Without Lora/Recursive `@font-face` in
  `blog.css`, the blog footer would render in fallback fonts and **not match**.
  Adding them is required for "looks the same".
- **DD-C Theme tokens in both stylesheets.** The moved `--ft-*`/`--surface-footer`
  defs (both `[data-theme]` variants) must land in the shared partial so both
  `secondary.css` and `blog.css` carry them. Verify the footer themes correctly on
  **both** marketing and blog when toggling.
- **DD-D No marketing regression.** This *refactors* the marketing footer (extracts
  markup + CSS); the marketing footer must look **byte-for-byte the same** after.
  This is the highest-risk side effect — verify the landing footer is unchanged.
- **DD-E Link set — DECIDED: add RSS.** The shared footer replaces the blog's
  quick-links (RSS / Archive / email) with the marketing columns (Solutions /
  Resources / Contact). Per the operator, **add an `RSS → /rss.xml` link to the
  Resources column** (which already has Engineering Blog → `/articles/`). Since it
  is now in the *shared* footer, marketing pages show the RSS link too — that's
  fine/desirable.
- **DD-F Year — DECIDED: compute dynamically.** The shared footer's copyright uses
  `{{ site.time | date: "%Y" | default: "2026" }}` (the pattern the blog footer
  already used) instead of a hardcoded `2026`. **Caveat to verify:** Cobalt must
  populate `site.time` at build for this to be truly dynamic; if it doesn't, the
  `| default: "2026"` keeps it rendering (just not auto-advancing). CC confirms
  which — if `site.time` is empty on 0.20.2, note it and we treat the year as a
  known static-until-rebuilt value (a build-time injection would be a separate,
  out-of-scope nicety).

## Scope — out

- Redesigning the footer. This slice unifies, it doesn't restyle.
- The author-avatar / other no-CDN items (separate).

## Verification (see `ledger.md`)

Shared include + partial exist and are used by both sides; **marketing footer
visually unchanged**; **blog footer visually matches** marketing (structure,
colours, fonts) in **both** themes; blog theme-toggle still works; Lora/Recursive
load on blog pages; clean build; no regression to slices 01–05.

## Exit criteria

One footer fragment + one footer CSS partial, rendered identically on marketing
and blog, both themes; blog toggle intact; no visual change to the marketing
footer; clean `cobalt build`.
