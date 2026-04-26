#!/usr/bin/env bash

set -euo pipefail

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly RESET='\033[0m'

readonly ICON_OK="✔"
readonly ICON_ERR="✖"
readonly ICON_WARN="⚠"
readonly ICON_INFO="➜"
readonly ICON_STEP="◆"
readonly ICON_DRY="◇"

log_color() {
    local color="${1}"
    local message="${2}"
    printf "%b%s%b" "${color}" "${message}" "${RESET}"
}

log_info() {
    printf "%b %b%s%b\n" "$(log_color "${CYAN}" "${ICON_INFO}")" "${RESET}" "${1}" "${RESET}"
}

log_success() {
    printf "%b %b%s%b\n" "$(log_color "${GREEN}" "${ICON_OK}")" "${GREEN}" "${1}" "${RESET}"
}

log_warn() {
    printf "%b %b%s%b\n" "$(log_color "${YELLOW}" "${ICON_WARN}")" "${YELLOW}" "${1}" "${RESET}"
}

log_error() {
    printf "%b %b%s%b\n" "$(log_color "${RED}" "${ICON_ERR}")" "${RED}" "${1}" "${RESET}" >&2
}

log_step() {
    printf "%b %b%s%b\n" "$(log_color "${MAGENTA}" "${ICON_STEP}")" "${BOLD}" "${1}" "${RESET}"
}

log_dry() {
    printf "%b %b[dry-run]%b %s\n" "$(log_color "${BLUE}" "${ICON_DRY}")" "${DIM}" "${RESET}" "${1}"
}

log_verbose() {
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        printf "%b%s%b\n" "${DIM}" "  ${1}" "${RESET}"
    fi
}

log_header() {
    local title="${1}"
    local width=50
    local line
    line="$(printf '─%.0s' $(seq 1 ${width}))"
    printf "\n%b%s%b\n" "${BOLD}${CYAN}" "${line}" "${RESET}"
    printf "%b  %s%b\n" "${BOLD}${CYAN}" "${title}" "${RESET}"
    printf "%b%s%b\n\n" "${BOLD}${CYAN}" "${line}" "${RESET}"
}

log_divider() {
    printf "%b%s%b\n" "${DIM}" "$(printf '─%.0s' $(seq 1 40))" "${RESET}"
}
