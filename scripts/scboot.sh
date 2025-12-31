#!/usr/bin/env bash
set -euo pipefail

SCRIPT_PATH="$(readlink -f -- "$0")"
SCRIPT_DIR="$(dirname -- "${SCRIPT_PATH}")"

# shellcheck source-path=./scripts
source "${SCRIPT_DIR}/lib.sh"

VERSION_FILE="${SCRIPT_DIR}/VERSION"

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
    cat "${VERSION_FILE}"
}

#=== HELP START ===
# scboot
#
# Usage:
#   scboot [options]
#
# Options:
#   -h, --help       Show this help message and exit
#   -v, --version    Show scboot version and exit
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
"")
    show_help
    exit 0
    ;;
*)
    log_error "Unknown option: $1"
    echo
    show_help
    exit 1
    ;;
esac
