#!/usr/bin/env bash
set -euo pipefail

SIGN_KERNEL="@SYM_SCBOOT_SIGN_KERNEL@"
SIGN_GRUB="@SYM_SCBOOT_SIGN_GRUB@"

SCRIPT_PATH="$(readlink -f -- "$0")"
SCRIPT_DIR="$(dirname -- "${SCRIPT_PATH}")"

# shellcheck source-path=./scripts
source "${SCRIPT_DIR}/lib.sh"

VERSION_FILE="${SCRIPT_DIR}/VERSION"

usage_error() {
    log_error "$1"
    echo
    show_help
    exit 1
}

run_sign_command() {
    local target="${1:-}"
    case "${target}" in
    all)
        SCBOOT_INFO_ON_CONSOLE="true" "${SIGN_GRUB}"
        SCBOOT_INFO_ON_CONSOLE="true" "${SIGN_KERNEL}"
        ;;
    grub)
        SCBOOT_INFO_ON_CONSOLE="true" "${SIGN_GRUB}"
        ;;
    kernel)
        SCBOOT_INFO_ON_CONSOLE="true" "${SIGN_KERNEL}"
        ;;
    *)
        usage_error "Usage: scboot sign {all|grub|kernel}"
        ;;
    esac
}

show_help() {
    sed -n '/^#=== HELP START ===/,/^#=== HELP END ===/ {
    /^#=== HELP START ===/d
    /^#=== HELP END ===/d
    s/^#//
    p
  }' "$0"
}

print_version() {
    if [[ ! -f "${VERSION_FILE}" ]]; then
        log_error "VERSION file not found: ${VERSION_FILE}"
        exit 1
    fi
    version=$(<"${VERSION_FILE}")
    echo "scboot version ${version}"
}

#=== HELP START ===
# scboot
#
# Usage:
#   scboot [options] [command]
#
# Options:
#   -h, --help             Show this help message and exit
#   -v, --version          Show scboot version and exit
#
# Commands:
#   sign all               Sign GRUB and all kernels
#   sign grub              Sign GRUB only
#   sign kernel            Sign kernels only
#
# Description:
#   scboot is a Secure Boot helper utility providing tools for
#   GRUB, kernel, and DKMS signing workflows.
#
#   This command currently serves as the main CLI entrypoint.
#   Functional subcommands will be added incrementally.
#=== HELP END ===

case "${1:-}" in
-h | --help)
    show_help
    exit 0
    ;;
-v | --version)
    print_version
    exit 0
    ;;
sign)
    shift
    run_sign_command "${1:-}"
    ;;
"")
    show_help
    exit 0
    ;;
*)
    usage_error "Unknown option or command: ${1}"
    ;;
esac
