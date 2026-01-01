#!/usr/bin/env bash
set -euo pipefail

SCRIPT_PATH="$(readlink -f -- "$0")"
SCRIPT_DIR="$(dirname -- "${SCRIPT_PATH}")"
# shellcheck source-path=./scripts
source "${SCRIPT_DIR}/lib.sh"
scboot_load_config

SCBOOT_KERNEL_SIGNED_ANY=0

sign_kernel() {
    local SRC="${1:-}"

    if [[ -z "${SRC}" ]]; then
        log_error "Kernel path is empty."
        return 1
    fi

    [[ -f "${SRC}" ]] || {
        log_info "Kernel ${SRC} missing, skipping."
        return 0
    }

    mkdir -p "${KERNEL_HASH_DIR}"

    local BASENAME HASHFILE CUR_HASH STORED_HASH
    BASENAME="$(basename -- "${SRC}")"
    HASHFILE="${KERNEL_HASH_DIR}/${BASENAME}.sha256"

    CUR_HASH="$(sha256sum "${SRC}" | awk '{print $1}')"
    STORED_HASH=""
    [[ -f "${HASHFILE}" ]] && STORED_HASH="$(awk '{print $1}' "${HASHFILE}")"

    local force_sign="${SCBOOT_FORCE_SIGN:-}"
    if [[ -z "${force_sign}" ]]; then
        if [[ "${CUR_HASH}" == "${STORED_HASH}" ]] &&
            sbverify --cert "${CRT}" "${SRC}" >/dev/null 2>&1; then
            log_info "Kernel ${BASENAME} already signed, skipping."
            return 0
        fi
    else
        log_info "Kernel ${BASENAME} resign forced via SCBOOT_FORCE_SIGN."
    fi

    log_info "Signing kernel ${BASENAME}"

    (
        local TMP_FILE=""
        local TMP_SIGNED_FILE=""

        cleanup() {
            local exit_code="${1:-$?}"
            trap - EXIT INT TERM
            if [[ -n "${TMP_FILE:-}" ]]; then
                rm -f -- "${TMP_FILE}"
                TMP_FILE=""
            fi
            if [[ -n "${TMP_SIGNED_FILE:-}" ]]; then
                rm -f -- "${TMP_SIGNED_FILE}"
                TMP_SIGNED_FILE=""
            fi
            if [[ "${exit_code}" -ne 0 ]]; then
                log_error "Signing kernel ${BASENAME} failed."
            fi
            return "${exit_code}"
        }

        # shellcheck disable=2154
        trap 'status=$?; cleanup "$status"; exit "$status"' EXIT INT TERM

        local TARGET_DIR
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

        local KERNEL_VER INITRD_SRC
        KERNEL_VER="${BASENAME#vmlinuz-}"
        INITRD_SRC="${KERNEL_DST_DIR}/initrd.img-${KERNEL_VER}"

        if [[ -f "${INITRD_SRC}" ]]; then
            log_info "Initrd remains unchanged: ${INITRD_SRC}"
        else
            log_error "No matching initrd.img-${KERNEL_VER} found."
        fi

        local NEW_HASH
        NEW_HASH="$(sha256sum "${SRC}" | awk '{print $1}')"
        echo "${NEW_HASH}  ${SRC}" >"${HASHFILE}"

        log_info "Done: ${SRC} (signed)"
        cleanup 0
    )
    local sign_rc=$?
    if ((sign_rc == 0)); then
        SCBOOT_KERNEL_SIGNED_ANY=1
    fi
    return "${sign_rc}"
}

sign_all_kernels() {
    local rc=0
    local found=0
    local kernel_rc=0
    local kernel_list=""

    kernel_list="$(mktemp)"

    if ! find /boot -maxdepth 1 -type f -name 'vmlinuz-*' -print0 >"${kernel_list}"; then
        rm -f -- "${kernel_list}"
        log_error "Failed to enumerate kernels under /boot."
        return 1
    fi

    while IFS= read -r -d '' kernel; do
        found=$((found + 1))
        sign_kernel "${kernel}"
        kernel_rc=$?
        if ((kernel_rc != 0)); then
            rc=1
        fi
    done <"${kernel_list}"

    rm -f -- "${kernel_list}"

    if [[ "${found}" -eq 0 ]]; then
        log_info "No kernel images found under /boot."
    else
        log_info "Processed ${found} kernel(s) under /boot."
    fi

    return "${rc}"
}

main_rc=0

if (($# == 0)); then
    sign_all_kernels || main_rc=$?
elif (($# == 1)); then
    sign_kernel "$1" || main_rc=$?
else
    log_error "Usage: resign-kernel.sh [kernel-image]"
    exit 1
fi

if [[ "${SCBOOT_KERNEL_SIGNED_ANY}" == "1" ]]; then
    if command -v update-grub >/dev/null 2>&1; then
        log_info "Updating GRUB configuration..."
        update-grub
    fi
fi

exit "${main_rc}"
