#!/usr/bin/env bash
# Install the Pagefind binary (standalone — no npm/npx, no Homebrew formula).
#
# Pagefind ships prebuilt binaries on GitHub Releases; there is no `brew`
# formula. This fetches the `pagefind` binary for the current OS/arch and
# installs it. Used by scripts/deploy.sh + scripts/preview.sh, and by CI.
#
# Usage:
#   ./scripts/install-pagefind.sh                 # latest pinned version → /usr/local/bin
#   PAGEFIND_VERSION=v1.5.2 ./scripts/install-pagefind.sh
#   PAGEFIND_BIN_DIR="$HOME/.local/bin" ./scripts/install-pagefind.sh   # no sudo
#   PAGEFIND_FLAVOR=extended ./scripts/install-pagefind.sh              # CJK/broad-language build
#
# Docs: https://pagefind.app/docs/installation/

set -euo pipefail

VERSION="${PAGEFIND_VERSION:-v1.5.2}"
FLAVOR="${PAGEFIND_FLAVOR:-base}"          # base | extended
BIN_DIR="${PAGEFIND_BIN_DIR:-/usr/local/bin}"

# OS/arch → Rust target triple used by Pagefind's release assets.
os="$(uname -s)"; arch="$(uname -m)"
case "$arch" in arm64|aarch64) cpu=aarch64 ;; x86_64|amd64) cpu=x86_64 ;; *) echo "unsupported arch: $arch" >&2; exit 1 ;; esac
case "$os" in
  Darwin) triple="${cpu}-apple-darwin" ;;
  Linux)  triple="${cpu}-unknown-linux-musl" ;;
  *) echo "unsupported OS: $os (install manually from GitHub Releases)" >&2; exit 1 ;;
esac

case "$FLAVOR" in base) name="pagefind" ;; extended) name="pagefind_extended" ;; *) echo "PAGEFIND_FLAVOR must be base|extended" >&2; exit 1 ;; esac

asset="${name}-${VERSION}-${triple}.tar.gz"
url="https://github.com/Pagefind/pagefind/releases/download/${VERSION}/${asset}"

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
echo "→ Downloading $asset …"
curl -sSL --fail "$url" -o "$tmp/pagefind.tar.gz"
tar xzf "$tmp/pagefind.tar.gz" -C "$tmp"

# The extended tarball names the binary pagefind_extended; install it as `pagefind`.
src="$tmp/pagefind"; [ -f "$src" ] || src="$tmp/pagefind_extended"
[ -f "$src" ] || { echo "error: pagefind binary not found in $asset" >&2; exit 1; }
chmod +x "$src"

mkdir -p "$BIN_DIR"
if [ -w "$BIN_DIR" ]; then mv "$src" "$BIN_DIR/pagefind"; else sudo mv "$src" "$BIN_DIR/pagefind"; fi

# macOS: clear the quarantine flag so Gatekeeper doesn't block the unsigned binary.
if [ "$os" = "Darwin" ]; then xattr -d com.apple.quarantine "$BIN_DIR/pagefind" 2>/dev/null || true; fi

echo "→ Installed: $("$BIN_DIR/pagefind" --version 2>/dev/null || echo "$BIN_DIR/pagefind")"
command -v pagefind >/dev/null 2>&1 || echo "note: ensure $BIN_DIR is on your PATH."
