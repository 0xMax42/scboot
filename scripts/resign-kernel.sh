#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "$(readlink -f -- "$0")")" &> /dev/null && pwd)"
source "$SCRIPT_DIR/load_config.sh"

mkdir -p "$KERNEL_HASH_DIR"

SRC="$1"
BASENAME=$(basename "$SRC")
SIGNED="$KERNEL_DST_DIR/${BASENAME}.signed"
HASHFILE="$KERNEL_HASH_DIR/${BASENAME}.sha256"

# 1. Existenz prüfen
[[ -f "$SRC" ]] || exit 0

# 2. Aktuellen Hash des Originals berechnen
CUR_HASH=$(sha256sum "$SRC" | awk '{print $1}')

# 3. Früh-Exit, falls bereits signiert und identisch
if [[ -f "$SIGNED" && -f "$HASHFILE" ]] && grep -q "$CUR_HASH" "$HASHFILE"; then
    echo "[SecureBoot] Kernel $BASENAME bereits signiert – übersprungen."
    exit 0
fi

echo "[SecureBoot] Signiere neuen Kernel: $BASENAME"

TMP=$(mktemp --suffix=.efi)
cp "$SRC" "$TMP"
sbattach --remove "$TMP" 2>/dev/null || true

# 4. Kernel signieren
sbsign --key "$KEY" --cert "$CRT" --output "$SIGNED" "$TMP"
rm -f "$TMP"

# 5. Initrd ermitteln und kopieren
KERNEL_VER=$(echo "$BASENAME" | sed 's/^vmlinuz-//')
INITRD_SRC="$KERNEL_DST_DIR/initrd.img-$KERNEL_VER"
INITRD_DST="$KERNEL_DST_DIR/initrd.img-$KERNEL_VER.signed"

if [[ -f "$INITRD_SRC" ]]; then
    cp "$INITRD_SRC" "$INITRD_DST"
    echo "[SecureBoot] Initrd kopiert: $INITRD_DST"
else
    echo "[SecureBoot] WARNUNG: Kein passendes initrd.img-$KERNEL_VER gefunden." >&2
fi

# 6. Hash speichern
echo "$CUR_HASH  $SRC" > "$HASHFILE"

# 7. GRUB aktualisieren
if command -v update-grub &>/dev/null; then
    echo "[SecureBoot] Aktualisiere GRUB-Konfiguration ..."
    update-grub
fi

echo "[SecureBoot] Fertig: $SIGNED"