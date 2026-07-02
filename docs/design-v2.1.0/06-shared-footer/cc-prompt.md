# CC assignment — one shared footer across the site (slice 06) — IMPLEMENT + verify

You are CC on stock **Cobalt 0.20.2**. Slices 01–05 are closed. This slice
**you implement** (then verify): give the blog the marketing site's footer, as a
**single shared source** so they can't drift. CDC wrote the plan — read
`docs/design-v2.1.0/06-shared-footer/slice-doc.md` first; rows in `ledger.md`.

No Cobalt change, no custom CLI. Do **not** restyle the footer — unify it.

## The three gotchas (read before you start)

1. **Preserve the theme toggle.** `_includes/blog-footer.liquid` carries the
   `<script>` that drives the blog nav's `#themeToggle`. The marketing footer has
   no such script. If you drop it, the blog's light/dark toggle dies. Keep it.
2. **Blog needs the footer's fonts.** The footer uses **Lora** + **Recursive**.
   Those are self-hosted but only in `secondary.css`/`main.css`. `blog.css` lacks
   them → without adding `@font-face`, the blog footer renders in fallback fonts.
3. **Don't regress the marketing footer.** You're extracting its markup + CSS;
   the landing footer must look identical afterward.

## Steps

1. **Extract markup → `_includes/site-footer.liquid`.** Move the
   `<footer class="footer">…</footer>` block out of `_layouts/secondary.liquid`
   into a new include, verbatim. In `secondary.liquid`, replace it with
   `{% include 'site-footer.liquid' %}`. Leave secondary.liquid's toggle/reveal
   `<script>` where it is.

2. **Extract CSS + tokens → `_sass/_site-footer.scss`.** Move from
   `_sass/_secondary-page.scss`: (a) all `.footer*` rules, and (b) the footer
   token definitions — `--surface-footer`, `--ft-border`, `--ft-text`,
   `--ft-heading`, `--ft-bar-bdr`, `--ft-copy` — **including both their
   `[data-theme="dark"]` and `[data-theme="light"]` blocks**. Delete them from
   `_secondary-page.scss`.

3. **Import the partial in both stylesheets.** Add `@import "site-footer";` to
   **`secondary.scss`** and to **`blog.scss`**. (Order: after `tokens`/`fonts`,
   before/with the page components.)

4. **Add the footer fonts to the blog.** In `_sass/_blog-fonts.scss`, add
   `@font-face` for **Lora** (`lora-latin-wght-{normal,italic}.woff2`, weight
   `400 700`, normal+italic) and **Recursive**
   (`recursive-latin-full-normal.woff2`, weight `300 800`, normal). The woff2
   already exist in `assets/fonts/` (slice 05). Match the existing `@font-face`
   style (format woff2, `font-display: swap`).

5. **Swap the blog footer, keep the script.** Rewrite `_includes/blog-footer.liquid`
   to be a thin wrapper: `{% include 'site-footer.liquid' %}` **followed by the
   existing theme-toggle `<script>` unchanged**. (Blog layouts already include
   `blog-footer.liquid`, so leave `blog-base.liquid`/`blog-post.liquid` alone.)

6. **Remove dead CSS.** Delete the now-unused `.blog-footer*` rules from
   `_sass/_blog-components.scss` (SF-13).

## Verify (report per row SF-01…SF-13)

- **Build:** `cobalt build` exit 0, no warnings.
- **DD-D marketing unchanged:** the landing (`/`) footer looks identical to
  before — same columns/colours/fonts/spacing. This is the one most likely to
  bite; check computed styles if unsure.
- **DD-C / SF-09 / SF-10 blog match + theme:** on a post, the footer matches the
  landing footer, and toggling light/dark themes the footer correctly on **both**
  pages (`--surface-footer` / `--ft-*` resolve to the green ladder in each).
- **DD-B / SF-06 fonts:** `grep -c @font-face site/blog.css` rose by 3; the blog
  footer's computed `font-family` is Lora/Recursive, not fallback.
- **DD-A / SF-11 toggle:** clicking `#themeToggle` on a blog page still flips the
  theme and persists (`billo-theme`).
- **SF-12 no regression:** blog pages/feeds/highlighting/search + landing all fine.

## Operator decisions — LOCKED (implement these, don't default)

- **Add RSS to the footer.** In the shared `site-footer.liquid`, add an
  `<a href="/rss.xml">RSS</a>` link to the **Resources** column (alongside
  Engineering Blog → `/articles/`). It will show on marketing pages too — intended.
- **Dynamic year.** In the copyright line, use
  `{{ site.time | date: "%Y" | default: "2026" }}` instead of hardcoded `2026`.
  Report whether `site.time` actually resolves to the current year on Cobalt
  0.20.2 or falls through to the `2026` default (SF-15, DD-F) — either is
  acceptable; we just want to know.

## Report back

Per row + the two DD questions in `ledger.md`. The ones that matter most:
**SF-08** (marketing footer unchanged), **SF-09/SF-10** (blog footer matches, both
themes), **SF-11** (toggle still works).
