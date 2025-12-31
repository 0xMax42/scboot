#!/usr/bin/env bash
set -euo pipefail

SCRIPT_PATH="$(readlink -f -- "$0")"
SCRIPT_DIR="$(dirname -- "${SCRIPT_PATH}")"
# shellcheck source-path=./scripts
source "${SCRIPT_DIR}/lib.sh"

[[ -e "${GRUB_SRC}" ]] || {
    log_error "GRUB source file not found: ${GRUB_SRC}"
    exit 1
}
[[ -e "${KEY}" ]] || {
    log_error "Signing key not found: ${KEY}"
    exit 1
}
[[ -e "${CRT}" ]] || {
    log_error "Signing certificate not found: ${CRT}"
    exit 1
}

CUR_HASH=$(sha256sum "${GRUB_SRC}" | awk '{print $1}')
force_sign="${SCBOOT_FORCE_SIGN:-}"

if [[ -z "${force_sign}" ]]; then
    if [[ -f "${GRUB_HASH}" ]] && grep -q "${CUR_HASH}" "${GRUB_HASH}"; then
        log_info "GRUB binary unchanged, no resigning needed."
        exit 0
    fi
else
    log_info "GRUB resign forced via SCBOOT_FORCE_SIGN."
fi

log_info "GRUB binary changed, resigning..."

TMP_FILE=""
TMP_SIGNED_FILE=""

cleanup() {
    local exit_code="$1"
    trap - EXIT INT TERM
    [[ -n "${TMP_FILE:-}" ]] && rm -f -- "${TMP_FILE}"
    [[ -n "${TMP_SIGNED_FILE:-}" ]] && rm -f -- "${TMP_SIGNED_FILE}"
    if [[ "${exit_code}" -ne 0 ]]; then
        log_error "Resigning GRUB failed."
    fi
    exit "${exit_code}"
}

trap 'cleanup "$?"' EXIT INT TERM

TMP_FILE=$(mktemp --suffix=.efi)
TMP_SIGNED_FILE="${TMP_FILE}.signed"

# Remove old signatures from original
cp "${GRUB_SRC}" "${TMP_FILE}"
sbattach --remove "${TMP_FILE}" 2>/dev/null || true

# Resign
sbsign --key "${KEY}" --cert "${CRT}" --output "${TMP_SIGNED_FILE}" "${TMP_FILE}"
mv "${TMP_SIGNED_FILE}" "${GRUB_DST}"
TMP_SIGNED_FILE=""
rm -f "${TMP_FILE}"
TMP_FILE=""

# Update reference hash
mkdir -p "$(dirname -- "${GRUB_HASH}")"
echo "${CUR_HASH}  ${GRUB_SRC}" | tee "${GRUB_HASH}" >/dev/null

log_info "Done. New signature active in ${GRUB_DST}"
