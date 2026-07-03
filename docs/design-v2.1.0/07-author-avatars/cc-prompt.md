# CC assignment — vendor author avatars (slice 07) — RUN + verify

You are CC on a networked machine (stock Cobalt 0.20.2). This closes the last
external request on the site: the blog author card's GitHub avatar. CDC wrote the
script + template but **couldn't run it** (its sandbox firewalls
`avatars.githubusercontent.com`), so your job is to run it and verify.

Plan: `docs/design-v2.1.0/07-author-avatars/slice-doc.md`; rows: `ledger.md`.

## What's on disk

- `scripts/fetch-avatars.sh` (new, executable) — downloads each `github_user`'s
  GitHub avatar into `assets/images/authors/<user>.<ext>` (type detected) and
  writes `avatar: /assets/images/authors/<user>.<ext>` back into `_data/authors.yml`.
- `_layouts/blog-post.liquid` — author card prefers `author.avatar`, falls back
  to the CDN, then initials.

## Steps

1. **Run it.** `./scripts/fetch-avatars.sh`. Confirm it downloads `@oubiwann`
   and prints the saved path (AV-03). `ls -l assets/images/authors/` shows
   `oubiwann.png` or `oubiwann.jpg`.
2. **authors.yml updated (AV-04).** `git diff _data/authors.yml` shows an
   `avatar: /assets/images/authors/oubiwann.<ext>` line under Duncan's
   `github_user`, correctly indented, no duplicate.
3. **Build + local src (AV-05).** `cobalt build`, exit 0. In a built post
   (e.g. `site/articles/2026/06/supervision-trees/index.html`), the author-card
   `<img src>` is `/assets/images/authors/oubiwann.<ext>` — not
   `avatars.githubusercontent.com`.
4. **Zero external requests (AV-06).** Open a post in a browser; DevTools
   Network — no request to `avatars.githubusercontent.com` (nor any other
   external host: fonts, prism, etc. all local). This is the whole point.
5. **Idempotent (AV-07).** Run `./scripts/fetch-avatars.sh` again; `git diff
   _data/authors.yml` is clean (no new/duplicate `avatar:` line); at most the
   image bytes differ.
6. **No regression (AV-08).** Slices 01–06 still good (footer, fonts, search,
   highlighting).

## Report back

Per row AV-01…AV-08 + the detected extension for @oubiwann. The one that matters
most: **AV-06** — a blog post with zero external requests. If it's green, the
site is fully self-hosted and this slice closes.
