#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "$(readlink -f -- "$0")")" &> /dev/null && pwd)"
source "$SCRIPT_DIR/load_config.sh"

mkdir -p "$KERNEL_HASH_DIR"

SRC="$1"
BASENAME=$(basename "$SRC")
HASHFILE="$KERNEL_HASH_DIR/${BASENAME}.sha256"

# 1. Datei muss existieren
[[ -f "$SRC" ]] || exit 0

# 2. Aktuellen Hash des (signierten oder unsignierten) Kernels berechnen
CUR_HASH=$(sha256sum "$SRC" | awk '{print $1}')

# 3. Gespeicherten Hash laden (falls vorhanden)
STORED_HASH=""
[[ -f "$HASHFILE" ]] && STORED_HASH=$(awk '{print $1}' "$HASHFILE")

# 4. Prüfen, ob bereits korrekt signiert *und* unverändert
if [[ "$CUR_HASH" == "$STORED_HASH" ]] \
   && sbverify --cert "$CRT" "$SRC" &>/dev/null; then
    echo "[SecureBoot] Kernel $BASENAME bereits korrekt signiert – übersprungen."
    exit 0
fi

echo "[SecureBoot] Signiere Kernel: $BASENAME"

# 5. Temporäre Arbeitskopie anlegen
TMP=$(mktemp --suffix=.efi)
cp "$SRC" "$TMP"

# 5a. Alte Signatur aus der Kopie entfernen (falls vorhanden)
sbattach --remove "$TMP" 2>/dev/null || true

# 6. Signieren → Ergebnis in zweite Temp-Datei
SIGNED_TMP=$(mktemp --suffix=.efi)
sbsign --key "$KEY" --cert "$CRT" --output "$SIGNED_TMP" "$TMP"
rm -f "$TMP"

# 7. Atomar ersetzen (mv ist auf demselben FS atomar)
mv "$SIGNED_TMP" "$SRC"

# 8. Initrd: unverändert übernehmen (kein .signed Suffix mehr)
KERNEL_VER="${BASENAME#vmlinuz-}"
INITRD_SRC="$KERNEL_DST_DIR/initrd.img-$KERNEL_VER"

if [[ -f "$INITRD_SRC" ]]; then
    echo "[SecureBoot] Initrd bleibt unverändert: $INITRD_SRC"
else
    echo "[SecureBoot] WARNUNG: Kein passendes initrd.img-$KERNEL_VER gefunden." >&2
fi

# 9. Neuen Hash des *signierten* Kernels berechnen & speichern
NEW_HASH=$(sha256sum "$SRC" | awk '{print $1}')
echo "$NEW_HASH  $SRC" > "$HASHFILE"

# 10. GRUB updaten, falls vorhanden
if command -v update-grub &>/dev/null; then
    echo "[SecureBoot] Aktualisiere GRUB-Konfiguration …"
    update-grub
fi

echo "[SecureBoot] Fertig: $SRC (signiert)"
