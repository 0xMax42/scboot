#!/usr/bin/env bash
set -euo pipefail

SCRIPT_PATH="$(readlink -f -- "$0")"
SCRIPT_DIR="$(dirname -- "${SCRIPT_PATH}")"
# shellcheck source-path=./scripts
source "${SCRIPT_DIR}/lib.sh"

if [[ -z "${DKMS_CONFIG_FILE:-}" ]]; then
    log_error "DKMS configuration file path not set in scboot.conf"
    exit 1
fi
if [[ -z "${KEY:-}" ]]; then
    log_error "Signing key path not set in scboot.conf"
    exit 1
fi
if [[ -z "${CRT:-}" ]]; then
    log_error "Signing certificate path not set in scboot.conf"
    exit 1
fi

[[ -e "${DKMS_CONFIG_FILE}" ]] || {
    log_error "DKMS configuration file not found: ${DKMS_CONFIG_FILE}"
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

# Overwrite the DKMS configuration file with scboot settings
cat >"${DKMS_CONFIG_FILE}" <<EOF
# BEGIN scboot
sign_kernel_modules="yes"
mok_signing_key="${KEY}"
mok_certificate="${CRT}"
# END scboot
EOF
