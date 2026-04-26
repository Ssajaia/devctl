#!/usr/bin/env bash

set -euo pipefail

cmd_status() {
    local format="table"

    while [[ $# -gt 0 ]]; do
        case "${1}" in
            -h|--help)
                cat <<EOF

$(log_color "${CYAN}" "devctl status") — Show container status

USAGE:
    devctl status [options]

OPTIONS:
    --json          Output raw JSON format
    -h, --help      Show this help

EOF
                return 0
                ;;
            --json)
                format="json"
                shift
                ;;
            *)
                shift
                ;;
        esac
    done

    local root
    root="$(find_project_root)"
    validate_compose_exists "${root}"

    local compose_file
    compose_file="$(get_compose_file "${root}")"
    local project_name
    project_name="$(get_project_name "${root}")"

    log_header "Project Status: ${project_name}"
    log_verbose "Compose file: ${compose_file}"

    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_dry "docker compose -f \"${compose_file}\" -p \"${project_name}\" ps"
        return 0
    fi

    local container_count
    container_count="$(docker compose -f "${compose_file}" -p "${project_name}" ps -q 2>/dev/null | wc -l | tr -d ' ')"

    if [[ "${container_count}" -eq 0 ]]; then
        log_warn "No containers are running for this project."
        log_info "Run 'devctl up' to start the project."
        return 0
    fi

    if [[ "${format}" == "json" ]]; then
        docker compose -f "${compose_file}" -p "${project_name}" ps --format json
        return 0
    fi

    docker compose -f "${compose_file}" -p "${project_name}" ps

    log_divider

    local running
    running="$(docker compose -f "${compose_file}" -p "${project_name}" ps --status running -q 2>/dev/null | wc -l | tr -d ' ')"
    local stopped
    stopped="$(docker compose -f "${compose_file}" -p "${project_name}" ps --status exited -q 2>/dev/null | wc -l | tr -d ' ')"

    log_info "Running: $(log_color "${GREEN}" "${running}") | Stopped: $(log_color "${RED}" "${stopped}") | Total: ${container_count}"
}
