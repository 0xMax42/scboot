#!/usr/bin/env bash
set -euo pipefail

SRC=/boot/efi/EFI/ubuntu/grubx64.efi
DST=/boot/efi/EFI/scboot/grubx64.efi
KEY=/root/.secureboot/keys/DB.key
CRT=/root/.secureboot/keys/DB.crt
HASHFILE=/var/lib/secureboot/grub.sha256

# 1. Quelle vorhanden?
[[ -e "$SRC" ]] || { echo "[SecureBoot] $SRC fehlt – Abbruch." >&2; exit 0; }

# 2. Aktuellen Hash des *unsignierten* Originals berechnen
CUR_HASH=$(sha256sum "$SRC" | awk '{print $1}')

# 3. Früh-Exit, falls Hash unverändert
if [[ -f "$HASHFILE" ]] && grep -q "$CUR_HASH" "$HASHFILE"; then
    echo "[SecureBoot] Keine GRUB-Änderung – Signieren übersprungen."
    exit 0
fi

echo "[SecureBoot] GRUB hat sich geändert – resigniere …"

TMP=$(mktemp --suffix=.efi)

# 4. Alte Signaturen von Original entfernen
cp "$SRC" "$TMP"
sbattach --remove "$TMP" 2>/dev/null || true

# 5. Neu signieren
sbsign --key "$KEY" --cert "$CRT" --output "$TMP.signed" "$TMP"
mv "$TMP.signed" "$DST"
rm -f "$TMP"

# 6. Referenz-Hash aktualisieren
echo "$CUR_HASH  $SRC" | sudo tee "$HASHFILE" >/dev/null

echo "[SecureBoot] Fertig. Neue Signatur aktiv in $DST"