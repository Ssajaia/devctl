#!/usr/bin/env bash

set -euo pipefail

cmd_up() {
    local extra_args=()

    while [[ $# -gt 0 ]]; do
        case "${1}" in
            -h|--help)
                cat <<EOF

$(log_color "${CYAN}" "devctl up") — Start containers

USAGE:
    devctl up [options]

OPTIONS:
    --build         Force rebuild before starting
    --force-recreate  Recreate containers even if unchanged
    -h, --help      Show this help

EOF
                return 0
                ;;
            --build)
                extra_args+=("--build")
                shift
                ;;
            --force-recreate)
                extra_args+=("--force-recreate")
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

    log_header "Starting Project"
    log_step "Project root: ${root}"
    log_step "Bringing containers up..."

    run_compose "${root}" up -d "${extra_args[@]+"${extra_args[@]}"}"

    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_warn "Dry-run mode: no containers were started."
        return 0
    fi

    log_success "Containers are up and running."
    log_divider

    local compose_file
    compose_file="$(get_compose_file "${root}")"
    local project_name
    project_name="$(get_project_name "${root}")"

    docker compose -f "${compose_file}" -p "${project_name}" ps 2>/dev/null || true
}
