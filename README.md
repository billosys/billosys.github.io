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
assets/          Fonts, images, and other static assets
scripts/         Setup, fonts, deploy
```

## First-time setup

```bash
cargo install cobalt-bin              # one-time
chmod +x scripts/*.sh                 # one-time
./scripts/setup-site-worktree.sh      # creates orphan `site` branch + ./site/ worktree
git push -u origin site               # publish the site branch
./scripts/fetch-fonts.sh              # pulls Fontsource .woff2 into assets/fonts/
```

Then in the GitHub repo: Settings → Pages → source branch `site`.

## Local development

```bash
cobalt build                          # build into ./site/
cobalt serve                          # watch + local server at http://localhost:3000
```

## Deploy

```bash
./scripts/deploy.sh                   # build, commit to site branch, push
```

## Branches

- `main` — source of truth (development branch).
- `site` — orphan branch holding built output; what GitHub Pages serves.
- `legacy-2014-template` — pre-2026 Bootstrap template, archived.
