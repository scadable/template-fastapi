#!/usr/bin/env bash
#
# cleanup.sh – Tear down the local development environment.
# Removes the database container & volume, virtual-env, .env, caches, and coverage.
#

set -o errexit
set -o nounset
set -o pipefail

# ------------------------------------------------------------------------------
# Globals
# ------------------------------------------------------------------------------
DB_COMPOSE_FILE="./infra/local/docker-compose.db.yaml"
VENV_DIR="./venv"
ENV_FILE=".env"
COVERAGE_FILES=(.coverage htmlcov coverage.xml)
PYCACHE_PATTERN="__pycache__"

# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------
command_exists() {
    command -v "$1" &>/dev/null
}

remove_directory() {
    local dir=$1
    if [[ -d "$dir" ]]; then
        printf "Removing directory: %s\n" "$dir"
        rm -rf -- "$dir" || {
            printf "Failed to remove directory '%s'.\n" "$dir" >&2
            return 1
        }
    fi
}

remove_file() {
    local file=$1
    if [[ -f "$file" ]]; then
        printf "Removing file: %s\n" "$file"
        rm -f -- "$file" || {
            printf "Failed to remove file '%s'.\n" "$file" >&2
            return 1
        }
    fi
}

# ------------------------------------------------------------------------------
# Tasks
# ------------------------------------------------------------------------------
stop_and_remove_database() {
    if ! command_exists docker; then
        printf "Docker not found. Skipping database teardown.\n"
        return 0
    fi

    if [[ -f "$DB_COMPOSE_FILE" ]]; then
        printf "Stopping and removing database (docker-compose)...\n"
        docker compose -f "$DB_COMPOSE_FILE" down -v --remove-orphans || {
            printf "Failed to tear down database containers.\n" >&2
            return 1
        }
    else
        printf "Database compose file '%s' not found. Skipping.\n" "$DB_COMPOSE_FILE"
    fi
}

remove_virtualenv() {
    remove_directory "$VENV_DIR"
    remove_directory ".venv"
}

clean_env_file() {
    remove_file "$ENV_FILE"
}

clean_pycache() {
    printf "Removing Python caches…\n"
    find . -type d -name "$PYCACHE_PATTERN" -prune -exec rm -rf -- {} + || {
        printf "Failed to remove __pycache__ directories.\n" >&2
        return 1
    }
}

clean_coverage() {
    printf "Removing coverage artifacts…\n"
    for file in "${COVERAGE_FILES[@]}"; do
        remove_directory "$file"
        remove_file "$file"
    done
}

# ------------------------------------------------------------------------------
# Signal Handling
# ------------------------------------------------------------------------------
cleanup_on_exit() {
    printf "\nCleanup interrupted. Exiting.\n" >&2
}
trap cleanup_on_exit SIGINT SIGTERM

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
main() {
    stop_and_remove_database       || return 1
    remove_virtualenv              || return 1
    clean_env_file                 || return 1
    clean_pycache                  || return 1
    clean_coverage                 || return 1
    printf "✅  Development environment cleaned up successfully.\n"
}

main "$@"
