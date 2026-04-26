#!/usr/bin/env bash

set -euo pipefail

readonly DEVCTL_VERSION="1.0.0"
readonly DEVCTL_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

source "${DEVCTL_DIR}/utils/logger.sh"
source "${DEVCTL_DIR}/utils/docker.sh"
source "${DEVCTL_DIR}/utils/validator.sh"
source "${DEVCTL_DIR}/config/default.conf"

VERBOSE=false
DRY_RUN=false
COMMAND=""
COMMAND_ARGS=()

_load_project_config() {
    local dir="${PWD}"
    while [[ "${dir}" != "/" ]]; do
        if [[ -f "${dir}/.devctlrc" ]]; then
            source "${dir}/.devctlrc"
            return 0
        fi
        dir="$(dirname "${dir}")"
    done
}

_load_env_file() {
    local dir
    dir="$(find_project_root 2>/dev/null)" || return 0
    if [[ -f "${dir}/.env" ]]; then
        set -a
        source "${dir}/.env"
        set +a
    fi
}

_resolve_alias() {
    local cmd="${1}"
    case "${cmd}" in
        start|up|u)         echo "up" ;;
        stop|down|d)        echo "down" ;;
        log|logs|l)         echo "logs" ;;
        build|rebuild|r)    echo "rebuild" ;;
        ps|stat|status|s)   echo "status" ;;
        *)                  echo "${cmd}" ;;
    esac
}

_print_version() {
    log_info "devctl version ${DEVCTL_VERSION}"
}

_print_help() {
    cat <<EOF

$(log_color "${CYAN}" "devctl") — Docker Project Manager v${DEVCTL_VERSION}

$(log_color "${YELLOW}" "USAGE:")
    devctl [OPTIONS] <command> [args]

$(log_color "${YELLOW}" "COMMANDS:")
    up                  Start containers (docker compose up -d)
    down                Stop and remove containers
    logs [service]      Stream logs, optionally filtered by service
    rebuild             Rebuild images and restart containers
    status              Show running containers for this project

$(log_color "${YELLOW}" "OPTIONS:")
    -h, --help          Show this help message
    -v, --verbose       Enable verbose output
    -n, --dry-run       Print commands without executing them
    --version           Show version

$(log_color "${YELLOW}" "ALIASES:")
    up:      start, u
    down:    stop, d
    logs:    log, l
    rebuild: build, r
    status:  ps, stat, s

$(log_color "${YELLOW}" "PROJECT CONFIG:")
    Place a .devctlrc file in your project root to override defaults.
    Supports: COMPOSE_FILE, PROJECT_NAME, DEFAULT_SERVICE

$(log_color "${YELLOW}" "EXAMPLES:")
    devctl up
    devctl logs api
    devctl rebuild --no-cache
    devctl status
    devctl --dry-run up
    devctl --verbose down

EOF
}

_parse_global_flags() {
    local args=()
    while [[ $# -gt 0 ]]; do
        case "${1}" in
            -h|--help)
                _print_help
                exit 0
                ;;
            --version)
                _print_version
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            --)
                shift
                COMMAND_ARGS+=("$@")
                break
                ;;
            -*)
                args+=("${1}")
                shift
                ;;
            *)
                args+=("${1}")
                shift
                ;;
        esac
    done

    if [[ ${#args[@]} -gt 0 ]]; then
        COMMAND="$(_resolve_alias "${args[0]}")"
        COMMAND_ARGS+=("${args[@]:1}")
    fi
}

_dispatch_command() {
    local cmd="${1}"

    validate_docker_installed
    validate_docker_running

    case "${cmd}" in
        up)
            source "${DEVCTL_DIR}/commands/up.sh"
            cmd_up "${COMMAND_ARGS[@]+"${COMMAND_ARGS[@]}"}"
            ;;
        down)
            source "${DEVCTL_DIR}/commands/down.sh"
            cmd_down "${COMMAND_ARGS[@]+"${COMMAND_ARGS[@]}"}"
            ;;
        logs)
            source "${DEVCTL_DIR}/commands/logs.sh"
            cmd_logs "${COMMAND_ARGS[@]+"${COMMAND_ARGS[@]}"}"
            ;;
        rebuild)
            source "${DEVCTL_DIR}/commands/rebuild.sh"
            cmd_rebuild "${COMMAND_ARGS[@]+"${COMMAND_ARGS[@]}"}"
            ;;
        status)
            source "${DEVCTL_DIR}/commands/status.sh"
            cmd_status "${COMMAND_ARGS[@]+"${COMMAND_ARGS[@]}"}"
            ;;
        "")
            _print_help
            exit 0
            ;;
        *)
            log_error "Unknown command: '${cmd}'"
            log_info "Run 'devctl --help' for a list of commands."
            exit 1
            ;;
    esac
}

main() {
    _load_project_config || true
    _load_env_file || true
    _parse_global_flags "$@"

    export VERBOSE DRY_RUN DEVCTL_DIR

    _dispatch_command "${COMMAND}"
}

main "$@"