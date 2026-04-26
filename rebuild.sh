#!/usr/bin/env bash

set -euo pipefail

cmd_rebuild() {
    local no_cache=false
    local service=""
    local extra_args=()

    if [[ "${REBUILD_NO_CACHE_DEFAULT:-false}" == "true" ]]; then
        no_cache=true
    fi

    while [[ $# -gt 0 ]]; do
        case "${1}" in
            -h|--help)
                cat <<EOF

$(log_color "${CYAN}" "devctl rebuild") — Rebuild and restart containers

USAGE:
    devctl rebuild [service] [options]

ARGUMENTS:
    service         Optional service name to rebuild

OPTIONS:
    --no-cache      Build without using cache
    -h, --help      Show this help

EOF
                return 0
                ;;
            --no-cache)
                no_cache=true
                shift
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

    log_header "Rebuilding Project"
    log_step "Project root: ${root}"

    if [[ -n "${service}" ]]; then
        validate_service_exists "${root}" "${service}"
        log_step "Target service: ${service}"
    fi

    if [[ "${no_cache}" == "true" ]]; then
        log_step "Cache: disabled (--no-cache)"
    fi

    log_step "Stopping containers..."
    run_compose "${root}" down

    local build_args=("--build")
    if [[ "${no_cache}" == "true" ]]; then
        build_args+=("--no-cache")
        log_verbose "Building without cache..."
        if [[ "${DRY_RUN:-false}" != "true" ]]; then
            if [[ -n "${service}" ]]; then
                run_compose "${root}" build --no-cache "${extra_args[@]+"${extra_args[@]}"}" "${service}"
            else
                run_compose "${root}" build --no-cache "${extra_args[@]+"${extra_args[@]}"}"
            fi
        else
            run_compose "${root}" build --no-cache "${extra_args[@]+"${extra_args[@]}"}"
        fi
    fi

    log_step "Starting rebuilt containers..."

    if [[ -n "${service}" ]]; then
        run_compose "${root}" up -d "${extra_args[@]+"${extra_args[@]}"}" "${service}"
    else
        run_compose "${root}" up -d --build "${extra_args[@]+"${extra_args[@]}"}"
    fi

    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_warn "Dry-run mode: no containers were rebuilt."
        return 0
    fi

    log_success "Rebuild complete. Containers are running."
    log_divider

    local compose_file
    compose_file="$(get_compose_file "${root}")"
    local project_name
    project_name="$(get_project_name "${root}")"

    docker compose -f "${compose_file}" -p "${project_name}" ps 2>/dev/null || true
}
