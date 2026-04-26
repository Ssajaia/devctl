#!/usr/bin/env bash

set -euo pipefail

cmd_logs() {
    local service="${DEFAULT_SERVICE:-}"
    local tail="${LOG_TAIL_LINES:-100}"
    local follow=true
    local extra_args=()

    while [[ $# -gt 0 ]]; do
        case "${1}" in
            -h|--help)
                cat <<EOF

$(log_color "${CYAN}" "devctl logs") — Stream container logs

USAGE:
    devctl logs [service] [options]

ARGUMENTS:
    service         Optional service name to filter logs

OPTIONS:
    --no-follow     Print logs and exit (don't stream)
    --tail <n>      Number of lines to show from end (default: 100)
    -h, --help      Show this help

EOF
                return 0
                ;;
            --no-follow)
                follow=false
                shift
                ;;
            --tail)
                tail="${2:?'--tail requires a number'}"
                shift 2
                ;;
            -*)
                extra_args+=("${1}")
                shift
                ;;
            *)
                service="${1}"
                shift
                ;;
        esac
    done

    local root
    root="$(find_project_root)"
    validate_compose_exists "${root}"

    local follow_flag=""
    if [[ "${follow}" == "true" ]]; then
        follow_flag="--follow"
    fi

    if [[ -n "${service}" ]]; then
        log_header "Logs: ${service}"
        validate_service_exists "${root}" "${service}"
        run_compose "${root}" logs ${follow_flag} --tail="${tail}" "${extra_args[@]+"${extra_args[@]}"}" "${service}"
    else
        log_header "Logs: All Services"
        run_compose "${root}" logs ${follow_flag} --tail="${tail}" "${extra_args[@]+"${extra_args[@]}"}"
    fi
}
