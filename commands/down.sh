#!/usr/bin/env bash

set -euo pipefail

cmd_down() {
    local extra_args=()
    local remove_volumes=false

    while [[ $# -gt 0 ]]; do
        case "${1}" in
            -h|--help)
                cat <<EOF

$(log_color "${CYAN}" "devctl down") — Stop containers

USAGE:
    devctl down [options]

OPTIONS:
    -v, --volumes   Also remove named volumes
    --rmi           Remove images used by services
    -h, --help      Show this help

EOF
                return 0
                ;;
            -v|--volumes)
                remove_volumes=true
                extra_args+=("--volumes")
                shift
                ;;
            --rmi)
                extra_args+=("--rmi" "all")
                shift
                ;;
            *)
                extra_args+=("${1}")
                shift
                ;;
        esac
    done

    local root
    root="$(find_project_root)"
    validate_compose_exists "${root}"

    log_header "Stopping Project"
    log_step "Project root: ${root}"

    if [[ "${remove_volumes}" == "true" ]]; then
        log_warn "Volumes will also be removed."
    fi

    log_step "Bringing containers down..."

    run_compose "${root}" down "${extra_args[@]+"${extra_args[@]}"}"

    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_warn "Dry-run mode: no containers were stopped."
        return 0
    fi

    log_success "Containers stopped and removed."
}
