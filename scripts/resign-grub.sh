#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "$(readlink -f -- "$0")")" &> /dev/null && pwd)"
source "$SCRIPT_DIR/load_config.sh"

# 1. Quelle vorhanden?
[[ -e "$GRUB_SRC" ]] || { echo "[SecureBoot] $GRUB_SRC fehlt – Abbruch." >&2; exit 0; }

# 2. Aktuellen Hash des *unsignierten* Originals berechnen
CUR_HASH=$(sha256sum "$GRUB_SRC" | awk '{print $1}')

# 3. Früh-Exit, falls Hash unverändert
if [[ -f "$GRUB_HASH" ]] && grep -q "$CUR_HASH" "$GRUB_HASH"; then
    echo "[SecureBoot] Keine GRUB-Änderung – Signieren übersprungen."
    exit 0
fi

echo "[SecureBoot] GRUB hat sich geändert – resigniere …"

TMP=$(mktemp --suffix=.efi)

# 4. Alte Signaturen von Original entfernen
cp "$GRUB_SRC" "$TMP"
sbattach --remove "$TMP" 2>/dev/null || true

# 5. Neu signieren
sbsign --key "$KEY" --cert "$CRT" --output "$TMP.signed" "$TMP"
mv "$TMP.signed" "$GRUB_DST"
rm -f "$TMP"

# 6. Referenz-Hash aktualisieren
mkdir -p "$(dirname "$GRUB_HASH")"
echo "$CUR_HASH  $GRUB_SRC" | sudo tee "$GRUB_HASH" >/dev/null

echo "[SecureBoot] Fertig. Neue Signatur aktiv in $GRUB_DST"