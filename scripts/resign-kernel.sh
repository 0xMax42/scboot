#!/usr/bin/env bash
set -euo pipefail

SCRIPT_PATH="$(readlink -f -- "$0")"
SCRIPT_DIR="$(dirname -- "${SCRIPT_PATH}")"
# shellcheck source-path=./scripts
source "${SCRIPT_DIR}/lib.sh"

if (($# != 1)); then
    log_error "Usage: resign-kernel.sh <kernel-image>"
    exit 1
fi

SRC="${1}"
[[ -f "${SRC}" ]] || {
    log_info "Kernel ${SRC} missing, skipping."
    exit 0
}

mkdir -p "${KERNEL_HASH_DIR}"

BASENAME="$(basename -- "${SRC}")"
HASHFILE="${KERNEL_HASH_DIR}/${BASENAME}.sha256"

CUR_HASH=$(sha256sum "${SRC}" | awk '{print $1}')
STORED_HASH=""
[[ -f "${HASHFILE}" ]] && STORED_HASH="$(awk '{print $1}' "${HASHFILE}")"

if [[ "${CUR_HASH}" == "${STORED_HASH}" ]] &&
    sbverify --cert "${CRT}" "${SRC}" >/dev/null 2>&1; then
    log_info "Kernel ${BASENAME} already signed, skipping."
    exit 0
fi

log_info "Signing kernel ${BASENAME}"

TMP_FILE=""
TMP_SIGNED_FILE=""

cleanup() {
    local exit_code="$1"
    trap - EXIT INT TERM
    [[ -n "${TMP_FILE:-}" ]] && rm -f -- "${TMP_FILE}"
    [[ -n "${TMP_SIGNED_FILE:-}" ]] && rm -f -- "${TMP_SIGNED_FILE}"
    if [[ "${exit_code}" -ne 0 ]]; then
        log_error "Signing kernel ${BASENAME} failed."
    fi
    exit "${exit_code}"
}

trap 'cleanup "$?"' EXIT INT TERM

TARGET_DIR="$(dirname -- "${SRC}")"
TMP_FILE="$(mktemp --tmpdir="${TARGET_DIR}" --suffix=.efi scboot.XXXXXX)"
cp "${SRC}" "${TMP_FILE}"
sbattach --remove "${TMP_FILE}" >/dev/null 2>&1 || true

TMP_SIGNED_FILE="$(mktemp --tmpdir="${TARGET_DIR}" --suffix=.efi scboot.XXXXXX)"
sbsign --key "${KEY}" --cert "${CRT}" --output "${TMP_SIGNED_FILE}" "${TMP_FILE}"
rm -f -- "${TMP_FILE}"
TMP_FILE=""

mv "${TMP_SIGNED_FILE}" "${SRC}"
TMP_SIGNED_FILE=""

KERNEL_VER="${BASENAME#vmlinuz-}"
INITRD_SRC="${KERNEL_DST_DIR}/initrd.img-${KERNEL_VER}"

if [[ -f "${INITRD_SRC}" ]]; then
    log_info "Initrd remains unchanged: ${INITRD_SRC}"
else
    log_error "No matching initrd.img-${KERNEL_VER} found."
fi

NEW_HASH=$(sha256sum "${SRC}" | awk '{print $1}')
echo "${NEW_HASH}  ${SRC}" >"${HASHFILE}"

if command -v update-grub >/dev/null 2>&1; then
    log_info "Updating GRUB configuration..."
    update-grub
fi

log_info "Done: ${SRC} (signed)"
