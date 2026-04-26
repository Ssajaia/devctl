#!/usr/bin/env bash

set -euo pipefail

validate_docker_installed() {
    if ! command -v docker &>/dev/null; then
        log_error "Docker is not installed or not in PATH."
        log_info "Install Docker: https://docs.docker.com/get-docker/"
        exit 1
    fi
    log_verbose "Docker found: $(command -v docker)"
}

validate_docker_running() {
    if ! docker info &>/dev/null; then
        log_error "Docker daemon is not running."
        log_info "Start Docker and try again."
        exit 1
    fi
    log_verbose "Docker daemon is running."
}

validate_compose_exists() {
    local root="${1}"
    local compose_file="${COMPOSE_FILE:-}"
    local found=false

    local candidates=(
        "${compose_file}"
        "${root}/docker-compose.yml"
        "${root}/docker-compose.yaml"
        "${root}/compose.yaml"
    )

    for f in "${candidates[@]}"; do
        if [[ -n "${f}" && -f "${f}" ]]; then
            found=true
            log_verbose "Compose file: ${f}"
            break
        fi
    done

    if [[ "${found}" == "false" ]]; then
        log_error "No docker compose file found in: ${root}"
        exit 1
    fi
}

validate_service_exists() {
    local root="${1}"
    local service="${2}"
    local compose_file
    compose_file="$(get_compose_file "${root}")"
    local project_name
    project_name="$(get_project_name "${root}")"

    local services
    services="$(docker compose -f "${compose_file}" -p "${project_name}" config --services 2>/dev/null || true)"

    if ! echo "${services}" | grep -qx "${service}"; then
        log_error "Service '${service}' not found in compose file."
        log_info "Available services:"
        echo "${services}" | while IFS= read -r s; do
            log_info "  ${s}"
        done
        exit 1
    fi
}
