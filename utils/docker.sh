#!/usr/bin/env bash

set -euo pipefail

find_project_root() {
    local dir="${PWD}"
    local compose_file="${COMPOSE_FILE:-docker-compose.yml}"

    while [[ "${dir}" != "/" ]]; do
        if [[ -f "${dir}/${compose_file}" ]] || [[ -f "${dir}/compose.yaml" ]] || [[ -f "${dir}/docker-compose.yaml" ]]; then
            echo "${dir}"
            return 0
        fi
        dir="$(dirname "${dir}")"
    done

    log_error "No compose file found in '${PWD}' or any parent directory."
    log_info "Looked for: docker-compose.yml, docker-compose.yaml, compose.yaml"
    exit 1
}

get_compose_file() {
    local root="${1}"
    local candidates=(
        "${COMPOSE_FILE:-}"
        "${root}/docker-compose.yml"
        "${root}/docker-compose.yaml"
        "${root}/compose.yaml"
    )

    for f in "${candidates[@]}"; do
        if [[ -n "${f}" && -f "${f}" ]]; then
            echo "${f}"
            return 0
        fi
    done

    log_error "No compose file found in project root: ${root}"
    exit 1
}

get_project_name() {
    local root="${1}"

    if [[ -n "${PROJECT_NAME:-}" ]]; then
        echo "${PROJECT_NAME}"
        return 0
    fi

    if [[ -f "${root}/.env" ]]; then
        local name
        name="$(grep -E '^COMPOSE_PROJECT_NAME=' "${root}/.env" 2>/dev/null | cut -d= -f2 | tr -d '"' | tr -d "'" || true)"
        if [[ -n "${name}" ]]; then
            echo "${name}"
            return 0
        fi
    fi

    basename "${root}" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g'
}

run_compose() {
    local root="${1}"
    shift
    local compose_file
    compose_file="$(get_compose_file "${root}")"
    local project_name
    project_name="$(get_project_name "${root}")"

    local cmd="docker compose -f \"${compose_file}\" -p \"${project_name}\""

    log_verbose "Project root: ${root}"
    log_verbose "Compose file: ${compose_file}"
    log_verbose "Project name: ${project_name}"
    log_verbose "Command: ${cmd} $*"

    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_dry "${cmd} $*"
        return 0
    fi

    eval "${cmd}" "$@"
}

get_running_containers() {
    local root="${1}"
    local compose_file
    compose_file="$(get_compose_file "${root}")"
    local project_name
    project_name="$(get_project_name "${root}")"

    docker compose -f "${compose_file}" -p "${project_name}" ps --format json 2>/dev/null || true
}
