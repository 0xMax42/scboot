#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# scboot library
# Common functions and configuration loader for scboot scripts
# ------------------------------------------------------------

SCBOOT_LOG_TAG="scboot"
CONFIG_FILE="@DST_SCBOOT_CONF@"
INFO_ON_CONSOLE=${SCBOOT_INFO_ON_CONSOLE:-false}

# ------------------------------------------------------------
# Logging helpers (systemd journal)
# ------------------------------------------------------------

# Detect logger backend once
if command -v systemd-cat >/dev/null 2>&1; then
  _scboot_log() {
    systemd-cat -t "${SCBOOT_LOG_TAG}"
  }
elif command -v logger >/dev/null 2>&1; then
  _scboot_log() {
    logger -t "${SCBOOT_LOG_TAG}"
  }
else
  _scboot_log() {
    : # no-op fallback
  }
fi

# ------------------------------------------------------------
# Public logging API
# ------------------------------------------------------------

log_info() {
  # Log only to journal
  _scboot_log <<<"$*"
  if [[ "${INFO_ON_CONSOLE}" == "true" ]]; then
    echo "[scboot] $*"
  fi
}

log_success() {
  # Log to journal
  _scboot_log <<<"SUCCESS: $*"
  # And show to user
  echo "[scboot] SUCCESS: $*"
}

log_error() {
  # Log to journal
  _scboot_log <<<"ERROR: $*"
  # And show to user
  echo "[scboot] ERROR: $*" >&2
}

# ------------------------------------------------------------
# Configuration loading
# ------------------------------------------------------------

# Forward declarations for ShellCheck (values loaded from config)
# shellcheck disable=SC2034
GRUB_SRC=
# shellcheck disable=SC2034
GRUB_DST=
# shellcheck disable=SC2034
GRUB_HASH=
# shellcheck disable=SC2034
KEY=
# shellcheck disable=SC2034
CRT=
# shellcheck disable=SC2034
DER=
# shellcheck disable=SC2034
KERNEL_DST_DIR=
# shellcheck disable=SC2034
KERNEL_HASH_DIR=
# shellcheck disable=SC2034
DKMS_CONFIG_FILE=

SCBOOT_REQUIRED_VARS=(
  KEY
  CRT
  DER
  GRUB_SRC
  GRUB_DST
  GRUB_HASH
  KERNEL_DST_DIR
  KERNEL_HASH_DIR
  DKMS_CONFIG_FILE
)

_scboot_require_config_file() {
  if [[ ! -f "${CONFIG_FILE}" ]]; then
    log_error "Configuration file ${CONFIG_FILE} missing."
    exit 1
  fi
}

_scboot_parse_config_file() {
  # Read INI-like file (key=value); ignore # and ; comments.
  local key value
  while IFS='=' read -r key value; do
    key="${key%%\#*}"
    key="${key%%;*}"
    key="$(echo -n "${key}" | xargs)"
    value="$(echo -n "${value}" | xargs)"
    [[ -z "${key}" ]] && continue
    export "${key}"="${value}"
  done <"${CONFIG_FILE}"
}

_scboot_validate_required_vars() {
  local missing_vars=()
  local var
  for var in "${SCBOOT_REQUIRED_VARS[@]}"; do
    if [[ -z "${!var:-}" ]]; then
      missing_vars+=("${var}")
    fi
  done

  if ((${#missing_vars[@]})); then
    log_error "Missing configuration values: ${missing_vars[*]}"
    exit 1
  fi
}

scboot_load_config() {
  _scboot_require_config_file
  _scboot_parse_config_file
  _scboot_validate_required_vars
}
