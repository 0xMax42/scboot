#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="/etc/scboot/scboot.conf"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "[scboot] Fehler: Konfigurationsdatei $CONFIG_FILE nicht gefunden!" >&2
  exit 1
fi

# INI-artige Datei einlesen (key=value)
# Kommentare (# oder ;) werden ignoriert
while IFS='=' read -r key value; do
  key="${key%%\#*}"                 # Entferne alles nach #
  key="${key%%;*}"                 # Entferne alles nach ;
  key="$(echo -n "$key" | xargs)"  # Trim
  value="$(echo -n "$value" | xargs)"
  [[ -z "$key" ]] && continue
  export "$key"="$value"
done < "$CONFIG_FILE"
