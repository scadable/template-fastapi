#!/usr/bin/env bash
set -euo pipefail

# Global variables (can be overridden via arguments)
ENV_FILE=".env"

print_usage() {
    printf "Usage: %s [path_to_env_file]\n" "$0"
    return 0
}

parse_args() {
    if [[ $# -gt 1 ]]; then
        printf "Error: Too many arguments.\n" >&2
        print_usage
        return 1
    fi

    if [[ $# -eq 1 ]]; then
        ENV_FILE=$1
    fi

    return 0
}

cleanup() {
    # Placeholder for cleanup logic if needed in the future
    return 0
}

trap 'cleanup' EXIT INT TERM

load_dot_env_to_env() {
    local env_file
    env_file=$1

    if [[ ! -f "$env_file" ]]; then
        printf "Environment file '%s' not found. Skipping loading of environment variables.\n" "$env_file" >&2
        return 1
    fi

    if [[ ! -r "$env_file" ]]; then
        printf "Environment file '%s' is not readable. Check permissions.\n" "$env_file" >&2
        return 1
    fi

    printf "Loading environment variables from: %s\n" "$env_file"
    set -a
    # shellcheck disable=SC1090
    source "$env_file"
    set +a

    return 0
}

main() {
    parse_args "$@" || return 1

    if ! load_dot_env_to_env "$ENV_FILE"; then
        printf "Failed to load environment file '%s'.\n" "$ENV_FILE" >&2
        return 1
    fi

    printf "Environment successfully loaded from '%s'.\n" "$ENV_FILE"
    return 0
}

main "$@"
