#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "$(readlink -f -- "$0")")" &> /dev/null && pwd)"
source "$SCRIPT_DIR/load_config.sh"

mkdir -p "$KERNEL_HASH_DIR"

SRC="$1"
BASENAME=$(basename "$SRC")
HASHFILE="$KERNEL_HASH_DIR/${BASENAME}.sha256"

# 1. Existenz prüfen
[[ -f "$SRC" ]] || exit 0

# 2. Aktuellen Hash des *unsignierten* Originals berechnen
CUR_HASH=$(sha256sum "$SRC" | awk '{print $1}')

# 3. Früh-Exit, falls bereits signiert und identisch
if [[ -f "$HASHFILE" ]] && grep -q "$CUR_HASH" "$HASHFILE"; then
    echo "[SecureBoot] Kernel $BASENAME bereits signiert – übersprungen."
    exit 0
fi

echo "[SecureBoot] Signiere Kernel: $BASENAME"

# 4. Temporäre Datei erzeugen und kopieren
TMP=$(mktemp --suffix=.efi)
cp "$SRC" "$TMP"

# 5. Alte Signatur entfernen (falls vorhanden)
sbattach --remove "$TMP" 2>/dev/null || true

# 6. Signieren in temporäre Datei
sbsign --key "$KEY" --cert "$CRT" --output "$TMP.signed" "$TMP"
rm -f "$TMP"

# 7. Ersetze Original durch signierte Version
mv "$TMP.signed" "$SRC"

# 8. Initrd kopieren (ohne Suffix!)
KERNEL_VER="${BASENAME#vmlinuz-}"
INITRD_SRC="$KERNEL_DST_DIR/initrd.img-$KERNEL_VER"

if [[ -f "$INITRD_SRC" ]]; then
    echo "[SecureBoot] Initrd bleibt unverändert: $INITRD_SRC"
else
    echo "[SecureBoot] WARNUNG: Kein passendes initrd.img-$KERNEL_VER gefunden." >&2
fi

# 9. Neuen Hash speichern
echo "$CUR_HASH  $SRC" > "$HASHFILE"

# 10. GRUB-Konfiguration aktualisieren
if command -v update-grub &>/dev/null; then
    echo "[SecureBoot] Aktualisiere GRUB-Konfiguration ..."
    update-grub
fi

echo "[SecureBoot] Fertig: $SRC (signiert)"
