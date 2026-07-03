# Slice 07 — Vendor author avatars (close the no-CDN goal)

_Plan-of-record. Pragmatic tier. Opened 2026-07-02. Closes the last external
request on the site: the blog author card's GitHub avatar._

## Goal

Self-host every contributing author's avatar so blog pages make **zero external
requests**, via a reusable script that works for any author added to
`_data/authors.yml` — not a one-off for Duncan.

## Approach

- **`scripts/fetch-avatars.sh`** (new, matches `fetch-fonts.sh` convention): for
  every `github_user:` in `_data/authors.yml`, download that user's GitHub avatar
  to `assets/images/authors/<user>.<ext>`, detecting the real image type
  (png/jpg/gif/webp) so the extension is honest. Then write the local path back
  into `authors.yml` as `avatar: /assets/images/authors/<user>.<ext>` (idempotent:
  replaces an existing `avatar:` line under `github_user`, else inserts one).
  Runs on the maintainer's machine (network + python3); vendored files are
  committed, so CI/deploy just serve them.
- **`_layouts/blog-post.liquid`** — author card prefers `author.avatar`
  (vendored, local) and falls back to `avatars.githubusercontent.com` only until
  an author has been vendored, then to initials. So the page always works; after
  running the script it's fully local.

## Why a script (not a manual download)

Avatars change and authors get added. A committed script means: add an author to
`authors.yml` with their `github_user`, run `./scripts/fetch-avatars.sh`, commit.
No hand-fetching, no guessing the file extension, no hand-editing the avatar path.

## Scope — out

- Resizing/optimising beyond GitHub's `?s=` param (256px is plenty for the 64px
  card; add an `AVATAR_SIZE` env if needed).
- Non-GitHub authors (no `github_user`) — they fall back to initials, unchanged.

## Risks / decisions

- **DD-A Extension is dynamic.** GitHub serves png or jpg; the script detects it
  (`file --mime-type`) and records the exact path in `authors.yml`, so the
  template needs no extension knowledge.
- **DD-B Sandbox couldn't vendor.** CDC's sandbox firewalls
  `avatars.githubusercontent.com`, so the avatar isn't fetched yet and
  `authors.yml` has no `avatar:` line — the card currently falls back to the CDN.
  **CC runs the script** on a networked machine to complete the vendoring.
- **DD-C Idempotency.** Re-running refreshes images and rewrites the `avatar:`
  line in place (no duplicates). Verify a second run is a clean no-op diff aside
  from possibly-updated image bytes.

## Verification (see `ledger.md`)

CC runs `./scripts/fetch-avatars.sh`: avatar file vendored under
`assets/images/authors/`, `authors.yml` gains the correct `avatar:` path, the
built author card `<img src>` is the local path, and a blog post makes **zero
requests to avatars.githubusercontent.com**. Clean build; no regression.

## Exit criteria

Author avatars served from the site; blog pages make no external requests; the
script works for any `github_user` in `authors.yml`.
