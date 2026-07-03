# Ledger — Slice 07 Vendor author avatars

Strength: `asserted` < `attested` (static) < `reproduced` (CC runs it) < `reconciled`.

| ID | Criterion | Evidence / how | Open | Target |
|----|-----------|----------------|------|--------|
| AV-01 | `scripts/fetch-avatars.sh` exists, executable; reads `github_user`s from `authors.yml`, downloads to `assets/images/authors/<user>.<ext>`, detects real type, writes `avatar:` back into `authors.yml`. | file present + `chmod +x`; read. | attested | reconciled |
| AV-02 | `blog-post.liquid` author card prefers `author.avatar`, falls back to the GitHub CDN, then initials. | grep. | attested | reconciled |
| AV-03 | Running the script vendors Duncan's avatar: `assets/images/authors/oubiwann.<ext>` exists (png or jpg). **[DD-B]** | CC: run script; `ls assets/images/authors/`. | asserted | reproduced |
| AV-04 | `authors.yml` gains `avatar: /assets/images/authors/oubiwann.<ext>` under Duncan's `github_user`. | CC: read authors.yml after run. | asserted | reproduced |
| AV-05 | Clean `cobalt build`; built author card `<img src>` = the local path (not the CDN URL). | CC: grep a built post HTML. | asserted | reproduced |
| AV-06 | A blog post page makes **zero requests to avatars.githubusercontent.com** (nor any other external host). | CC: devtools network on a post. | asserted | reproduced |
| AV-07 | Idempotent: a second run leaves `authors.yml` diff-clean (only image bytes may change), no duplicate `avatar:` lines. **[DD-C]** | CC: run twice; `git diff` authors.yml. | asserted | reproduced |
| AV-08 | No regression to slices 01–06. | CC. | asserted | reproduced |

## Note

CDC could not run the script (sandbox firewalls `avatars.githubusercontent.com`),
so the avatar isn't vendored yet and the card falls back to the CDN until CC runs
`./scripts/fetch-avatars.sh` (DD-B).

## Close (2026-07-02)
AV-01…AV-08 **reconciled** — CC ran `fetch-avatars.sh` (@oubiwann → oubiwann.png,
image/png), authors.yml updated (1 avatar line, idempotent), all posts' author
card served locally; **AV-06 green — a blog post makes zero external resource
requests.** No-CDN goal fully closed. See `closing-report.md`. Follow-up (out of
scope): canonical/OG leading-slash fix in blog-head (candidate slice 08).
