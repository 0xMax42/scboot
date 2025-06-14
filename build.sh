#!/bin/bash
set -euo pipefail

###############################################################################
# Ensure Debian build tools are installed
###############################################################################
REQUIRED_PKGS=(build-essential devscripts debhelper curl tar)

missing=()
for pkg in "${REQUIRED_PKGS[@]}"; do
  dpkg -s "$pkg" &>/dev/null || missing+=("$pkg")
done

if (( ${#missing[@]} )); then
  echo "🔧 Installing missing build packages: ${missing[*]}"
  sudo apt-get update -qq
  sudo apt-get install -y --no-install-recommends "${missing[@]}"
fi

./install-git-cliff.sh || {
  echo "❌ Failed to install git-cliff. Please check the script or install manually." >&2
  exit 1
}

###############################################################################
# Ensure git-cliff is available (installed e.g. via cargo)
###############################################################################
if ! command -v git-cliff &>/dev/null; then
  echo "❌ git-cliff not found! Please install via 'cargo install git-cliff' or download a binary release." >&2
  exit 1
fi
###############################################################################

DIST_DIR="dist"

# Generate changelog
git cliff --config cliff.debian.toml

# Determine package name and version
PKG_NAME=$(dpkg-parsechangelog --show-field Source)
PKG_VERSION=$(dpkg-parsechangelog --show-field Version)

# Build the package
echo "🔧 Building Debian package..."
dpkg-buildpackage -us -uc

# Prepare output directory
mkdir -p "$DIST_DIR"
rm -rf "$DIST_DIR"/*

# Move build artefacts
for file in ../${PKG_NAME}_${PKG_VERSION}_*.deb \
            ../${PKG_NAME}_${PKG_VERSION}_*.buildinfo \
            ../${PKG_NAME}_${PKG_VERSION}_*.changes \
            ../${PKG_NAME}_${PKG_VERSION}.dsc \
            ../${PKG_NAME}_${PKG_VERSION}.tar.*; do
  [[ -f "$file" ]] && { mv "$file" "$DIST_DIR/"; echo "📦 Moved $(basename "$file") → $DIST_DIR/"; }
done

echo "✅ Build complete. Output in $DIST_DIR/"
