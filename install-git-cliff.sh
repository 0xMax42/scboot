#!/usr/bin/env bash
#
# install-git-cliff.sh – Download & install latest git-cliff (x86_64 Linux)
# Usage: sudo ./install-git-cliff.sh         # installiert neueste Version
#        sudo ./install-git-cliff.sh 2.8.0   # installiert v2.8.0

REPO="orhun/git-cliff"
INSTALL_DIR="/usr/local/bin"
ARCH="x86_64"          # amd64
OS="unknown-linux-gnu" # glibc-basiert

VERSION="${1:-latest}"

command -v curl  >/dev/null || { echo "curl fehlt"; exit 1; }
command -v tar   >/dev/null || { echo "tar fehlt";  exit 1; }

# ----------------------------------------------------------
# 1. Version ermitteln
# ----------------------------------------------------------
if [[ "$VERSION" == "latest" ]]; then
  VERSION=$(curl -sL "https://api.github.com/repos/${REPO}/releases/latest" \
            | grep -m1 '"tag_name":' \
            | sed -E 's/.*"v?([^"]+)".*/\1/')
fi
echo "📦 Down­loading git-cliff v${VERSION} …"

ASSET="git-cliff-${VERSION}-${ARCH}-${OS}.tar.gz"
URL="https://github.com/${REPO}/releases/download/v${VERSION}/${ASSET}"

# ----------------------------------------------------------
# 2. Herunterladen & entpacken
# ----------------------------------------------------------
TMP=$(mktemp -d)
curl -#L -o "${TMP}/${ASSET}" "$URL"
tar -C "$TMP" -xzf "${TMP}/${ASSET}"

# ----------------------------------------------------------
# 3. Installieren
# ----------------------------------------------------------
install -m755 "${TMP}/git-cliff" "${INSTALL_DIR}/git-cliff"

echo "✅ git-cliff $(git-cliff --version) wurde nach ${INSTALL_DIR} installiert."
