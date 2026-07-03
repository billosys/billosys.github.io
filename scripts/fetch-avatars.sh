#!/usr/bin/env bash
# Vendor contributing authors' avatars locally — no runtime CDN.
#
# For every `github_user:` in _data/authors.yml, downloads that user's GitHub
# avatar into assets/images/authors/<user>.<ext> (real image type detected) and
# writes the local path back into authors.yml as `avatar:`. The blog author card
# prefers `author.avatar`, so once vendored the page stops hitting
# avatars.githubusercontent.com.
#
# Idempotent: re-run to refresh, or after adding a new author to authors.yml.
# Runs on the maintainer's machine (needs network + python3); the vendored
# files are committed, so CI/deploy just serve them.
#
# Usage:   ./scripts/fetch-avatars.sh
# Env:     AVATAR_SIZE=256   (px; GitHub avatar `?s=` size)

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

AUTHORS="_data/authors.yml"
DIR="assets/images/authors"
SIZE="${AVATAR_SIZE:-256}"
mkdir -p "$DIR"

users="$(grep -oE 'github_user:[[:space:]]*[A-Za-z0-9._-]+' "$AUTHORS" | awk '{print $2}' | sort -u)"
[ -n "$users" ] || { echo "No github_user entries in $AUTHORS — nothing to do."; exit 0; }

for user in $users; do
  tmp="$(mktemp)"
  echo "  → @$user"
  curl -sSfL --retry 3 --max-time 30 -o "$tmp" "https://avatars.githubusercontent.com/${user}?s=${SIZE}&v=4"
  case "$(file -b --mime-type "$tmp")" in
    image/png)  ext=png ;;
    image/jpeg) ext=jpg ;;
    image/gif)  ext=gif ;;
    image/webp) ext=webp ;;
    *) echo "     ! unexpected image type for @$user — skipping"; rm -f "$tmp"; continue ;;
  esac
  rm -f "$DIR/$user".*          # drop any stale copy with a different extension
  mv "$tmp" "$DIR/$user.$ext"
  echo "     $DIR/$user.$ext"
done

# Write the local avatar paths back into authors.yml (idempotent: replaces an
# existing `avatar:` line that sits directly under github_user, else inserts one).
python3 - "$AUTHORS" "$DIR" <<'PY'
import sys, os, re, glob
authors, adir = sys.argv[1], sys.argv[2]
lines = open(authors, encoding="utf-8").read().split("\n")
out, i = [], 0
while i < len(lines):
    line = lines[i]; out.append(line)
    m = re.match(r"^(\s*)github_user:\s*([A-Za-z0-9._-]+)\s*$", line)
    if m:
        indent, user = m.groups()
        found = sorted(glob.glob(os.path.join(adir, user + ".*")))
        if found:
            out.append(f"{indent}avatar: /{found[0]}")
            if i + 1 < len(lines) and re.match(rf"^{indent}avatar:\s", lines[i + 1]):
                i += 2; continue   # replaced the old avatar line
    i += 1
open(authors, "w", encoding="utf-8").write("\n".join(out))
print(f"  → updated {authors}")
PY

echo
echo "Done. $(ls -1 "$DIR" 2>/dev/null | wc -l | tr -d ' ') avatar(s) in $DIR/"
