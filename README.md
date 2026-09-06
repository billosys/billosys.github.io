# billo.systems

Source for [billo.systems](https://billo.systems/) — the Billo Systems calling-card site.

Built with [Cobalt](https://cobalt-org.github.io/) (Rust static-site generator, Liquid templates).

## Layout

```
_cobalt.yml      Site config
_layouts/        Liquid page templates
_sass/           SCSS partials (tokens, primitives, base, landing)
main.scss        Entry stylesheet (compiles to /main.css)
index.liquid     Landing page
assets/          Static assets — self-hosted: fonts/, katex/, js/ (Prism), images/authors/
scripts/         Setup, asset-vendoring, preview, deploy
```

The blog (`/articles/`) and its templates are documented in `docs/templates.md`.

## First-time setup

```bash
cargo install cobalt-bin              # one-time
chmod +x scripts/*.sh                 # one-time
./scripts/fetch-fonts.sh              # Fontsource .woff2 → assets/fonts/
./scripts/fetch-katex.sh              # KaTeX JS/CSS/woff2 → assets/katex/  (math posts)
./scripts/fetch-avatars.sh            # author GitHub avatars → assets/images/authors/
./scripts/install-pagefind.sh         # Pagefind binary on PATH (search indexer)
```

GitHub Pages deploys from the custom GitHub Actions workflow in
`.github/workflows/deploy.yml`. In the GitHub repo, Settings → Pages should use
GitHub Actions as the build and deployment source.

## Self-hosted assets (no CDN)

Everything the pages load at render time is served from this site — no third-party
CDN. Each asset family has a vendoring script (re-run to refresh / bump a pinned
version, then commit the result):

| Script | Vendors | Into | Notes |
|--------|---------|------|-------|
| `fetch-fonts.sh` | Fraunces, Source Serif, IBM Plex Mono, Brygada 1918, Literata, Lora, Recursive (Fontsource woff2) | `assets/fonts/` | `@font-face` in `_sass/_fonts.scss` + `_sass/_blog-fonts.scss` |
| `fetch-katex.sh` | KaTeX (`katex.min.{js,css}`, `auto-render.min.js`, fonts) | `assets/katex/` | Loaded **only** on posts with `data.math: true` (guarded in `blog-post.liquid`). Detail + the pulldown-cmark backslash gotcha: `docs/templates.md` § Math (KaTeX) |
| `fetch-avatars.sh` | each `github_user`'s avatar from `_data/authors.yml` | `assets/images/authors/` | Writes the local path back into `authors.yml`; author card prefers it |
| `install-pagefind.sh` | the Pagefind search binary | PATH | Used by `preview.sh` and CI to build the search index |

Prism (client-side syntax highlighting) is likewise vendored at `assets/js/prism.js`.

## Local development

```bash
./scripts/preview.sh                  # build + Pagefind index + serve at http://localhost:1414
```

> Use `preview.sh`, **not** `cobalt serve`, for a full local preview: `cobalt serve`
> rebuilds into a temp dir and wipes `site/pagefind/`, so search returns nothing under
> it. `preview.sh` runs `cobalt build` then `pagefind --site site --serve`. For a
> quick no-search build, plain `cobalt build` still works.

## Deploy

```bash
git push origin main                  # deploys through GitHub Actions
make deploy                           # optional: manually dispatch the workflow for main
```

## Branches

- `main` — source of truth (development branch).
- `site` — legacy orphan branch that held built output before the GitHub Actions deployment.
- `legacy-2014-template` — pre-2026 Bootstrap template, archived.
