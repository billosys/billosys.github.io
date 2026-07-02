# Closing report — Slice 06 Shared footer

Closed 2026-07-01. Implemented by CC; alignment fixes + reconcile by CDC;
visually confirmed by the operator.

## Verdict

**Delivered.** One footer — `_includes/site-footer.liquid` (markup) +
`_sass/_site-footer.scss` (CSS + tokens) — imported by both `secondary.scss` and
`blog.scss`, rendering identically on the marketing site and the blog, both
themes, with the blog's theme-toggle preserved and RSS + a dynamic year added.

## Per-row walk

SF-01…SF-15 `reproduced`. Two corrections at close:

- **SF-09 corrected (was over-optimistic).** CC's screenshot comparison passed
  "visually identical", but the blog footer was **not** aligned: the shared
  footer depended on element resets that only marketing's `_base.scss` provides.
  The blog stylesheet has no global reset, so on the blog the footer's
  `<ul class="footer-links">` kept the UA `padding-inline-start: 40px` + top
  margin (links indented and dropped), the `<h4>`/`<p>` kept default margins, and
  text inherited `line-height: 1.75` (vs marketing's `--leading-body` 1.65). Fix:
  made `_site-footer.scss` **self-sufficient** — reset its own `.footer-links`
  (margin/padding), `.footer-heading` + `.footer-tagline` margins, pinned
  `.footer { line-height: var(--leading-body) }`, and `.footer-logo { display:
  block }`. All are no-ops on marketing (its base already provides them), so no
  regression; operator confirmed the blog footer now lines up.
- **SF-13:** the flagged `.blog-footer` "leftover" was a false positive — only a
  comment referenced it; the rules were removed. Clean.

## Lesson (bubble-up)

A **shared component must not depend on the host stylesheet's base resets.** The
footer looked identical in the shared CSS but rendered differently because the
two host stylesheets normalise elements differently. Verifying "identical" needs
a real cross-context render *and* a check of inherited/base styles — a screenshot
diff alone missed a 40px indent. The durable fix is component self-sufficiency
(reset your own `ul`/`p`/`h*` margins, pin line-height), which also future-proofs
the footer against either stylesheet changing its base.

## Project status

Six slices closed: 01 blog · 02 syntax highlighting · 03 blog fonts · 04 search ·
05 marketing fonts · 06 shared footer. The only remaining external request
site-wide is the blog author's GitHub avatar.
