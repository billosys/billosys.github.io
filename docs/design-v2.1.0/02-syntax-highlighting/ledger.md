# Ledger — Slice 02 Syntax highlighting

Strength: `asserted` (author) < `attested` (static, in-sandbox) < `reproduced`
(CC on real `cobalt build`) < `reconciled` (CDC cross-check at close).

| ID | Criterion | Evidence / how | Open | Target |
|----|-----------|----------------|------|--------|
| S-01 | `syntax_highlight.enabled: false` in `_cobalt.yml`. | `grep -A1 syntax_highlight _cobalt.yml`. | attested | reconciled |
| S-02 | Self-hosted Prism at `assets/js/prism.js` (non-empty) + `prism.LICENSE`; no CDN reference in templates. | `ls -l assets/js/`; `grep -rn cdn _includes _layouts` = none. | attested | reconciled |
| S-03 | `blog-post.liquid` loads `/assets/js/prism.js` (defer); posts only. | `grep prism.js _layouts/blog-post.liquid`. | attested | attested |
| S-04 | Token-map CSS in `_blog-components.scss` references only `--code-*` tokens that exist. | static token check (done). | attested | reconciled |
| S-05 | Clean `cobalt build` (exit 0, no warnings); no regression to slice 01. | CC. | asserted | reproduced |
| S-06 | With highlighting off, a fenced block emits `<pre><code class="language-erlang">` (Prism-ready), not syntect inline spans. **[DD-A]** | CC: inspect built `supervision-trees` HTML. | asserted | reproduced |
| S-07 | Prism highlights the Erlang sample in the **brand palette**: green `--code-bg` panel, ochre keywords, green strings/functions. | CC: open post in browser; spot-check colours vs tokens. | asserted | reproduced |
| S-08 | `/assets/js/prism.js` is served (copied by Cobalt to `site/assets/js/`); loads with no console error; **no external/CDN network request**. | CC: devtools network + console. | asserted | reproduced |
| S-09 | Both light and dark themes keep code legible (panel pinned dark by design in both). | CC: toggle on a post. | asserted | reproduced |
| S-10 | Curated language set highlights correctly for a spot sample beyond Erlang (e.g. a ```rust and a ```bash block). | CC: add a temp fenced block or test post. | asserted | reproduced |

## Open questions for CC

1. **DD-A:** Confirm `enabled: false` on 0.20.2 yields `<pre><code class="language-x">`
   (language class preserved from the fence). If the class is dropped, Prism
   can't hook — report and we add a fence→class fixup.
2. Any Prism console error from the concatenated build order? (order is
   dependency-safe: core → markup/css/clike → markup-templating → javascript →
   c → cpp → go → …; markdown last.)
3. Is a copy-to-clipboard / line-numbers plugin wanted for v1, or deferred?

## Close (2026-07-01)
All rows S-01…S-10 **reconciled** — CC `reproduced` (incl. live headless-browser
colour check, S-07), CDC cross-checked on disk. See `closing-report.md`. Bubble-up:
candidate slice 03 = self-host blog fonts (Google Fonts still external, vs the
stated no-CDN policy).
