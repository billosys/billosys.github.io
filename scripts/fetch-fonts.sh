#!/usr/bin/env bash
# Fetch the self-hosted woff2 font files from jsDelivr's Fontsource mirror.
# Idempotent: re-running overwrites existing files with the latest pinned
# major version (Fontsource @5.x).
#
# Usage:
#   ./scripts/fetch-fonts.sh          # from repo root
#
# Files land in ./assets/fonts/, which is where _sass/_fonts.scss looks.

set -euo pipefail

FONT_DIR="assets/fonts"
mkdir -p "$FONT_DIR"

# Pinned major versions — Fontsource 5.x is current at time of write.
FRAUNCES_VER="5"
SOURCE_SERIF_VER="5"
PLEX_MONO_VER="5"

BASE_URL="https://cdn.jsdelivr.net/npm"

declare -a FONTS=(
  "@fontsource-variable/fraunces@${FRAUNCES_VER}/files/fraunces-latin-wght-normal.woff2"
  "@fontsource-variable/fraunces@${FRAUNCES_VER}/files/fraunces-latin-wght-italic.woff2"
  "@fontsource-variable/source-serif-4@${SOURCE_SERIF_VER}/files/source-serif-4-latin-wght-normal.woff2"
  "@fontsource-variable/source-serif-4@${SOURCE_SERIF_VER}/files/source-serif-4-latin-wght-italic.woff2"
  "@fontsource/ibm-plex-mono@${PLEX_MONO_VER}/files/ibm-plex-mono-latin-400-normal.woff2"
  "@fontsource/ibm-plex-mono@${PLEX_MONO_VER}/files/ibm-plex-mono-latin-500-normal.woff2"
)

for path in "${FONTS[@]}"; do
  filename="$(basename "$path")"
  dest="$FONT_DIR/$filename"
  echo "  → $dest"
  curl -sSfL --retry 3 --max-time 30 -o "$dest" "$BASE_URL/$path"
done

echo
echo "Done. $(ls -1 "$FONT_DIR" | wc -l | tr -d ' ') files in $FONT_DIR/"
