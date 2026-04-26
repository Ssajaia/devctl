#!/usr/bin/env bash

set -euo pipefail

readonly INSTALL_DIR="/usr/local/bin"
readonly DEVCTL_LINK="${INSTALL_DIR}/devctl"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

_check_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        echo "This installer requires root privileges."
        echo "Run: sudo bash install.sh"
        exit 1
    fi
}

_make_executable() {
    chmod +x "${SCRIPT_DIR}/devctl.sh"
    chmod +x "${SCRIPT_DIR}/commands/"*.sh
    chmod +x "${SCRIPT_DIR}/utils/"*.sh
}

_install_symlink() {
    if [[ -L "${DEVCTL_LINK}" ]]; then
        rm -f "${DEVCTL_LINK}"
    fi
    ln -s "${SCRIPT_DIR}/devctl.sh" "${DEVCTL_LINK}"
}

_verify_install() {
    if command -v devctl &>/dev/null; then
        echo "devctl installed successfully at ${DEVCTL_LINK}"
        devctl --version
    else
        echo "Installation failed: devctl not found in PATH."
        exit 1
    fi
}

main() {
    echo "Installing devctl..."
    _check_root
    _make_executable
    _install_symlink
    _verify_install
    echo ""
    echo "Run 'devctl --help' to get started."
}

main "$@"
