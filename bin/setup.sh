#!/usr/bin/env bash

# This script is incharge of setting up the environment for the project
PYTHON_VERSION="3.12"
VENV_PATH="./venv/bin/activate"



# Setting up python
setup_python() {
    local python_bin;

    if ! python_bin=$(command -v "python$PYTHON_VERSION"); then
        printf "Python %s not found in PATH. Attempting to use 'python3'...\n" "$PYTHON_VERSION" >&2

        if ! python_bin=$(command -v python3); then
            printf "Python 3 is not installed or not found in PATH.\n" >&2
            return 1
        fi
    fi

    if ! "$python_bin" -c "import sys; exit(0) if sys.version_info[:2] == (${PYTHON_VERSION//./,}) else exit(1)"; then
        printf "Python version mismatch. Found %s, expected %s.\n" "$("$python_bin" --version 2>&1)" "$PYTHON_VERSION" >&2
        return 1
    fi

    export PYTHON_EXEC="$python_bin"
    printf "Using Python executable: %s\n" "$PYTHON_EXEC"
    return 0
}

# set up venv
setup_venv() {
    local venv_file=$1

    printf "Setting up virtual environment at: %s\n" "$venv_file"

    if [[ -f "$venv_file" ]]; then
        printf "Venv file exists...\n"
    else
        printf "Venv file does not exist. Creating a new virtual environment...\n"

        if [[ -z "$PYTHON_EXEC" ]]; then
            printf "Python executable not set. Cannot create virtual environment.\n" >&2
            return 1
        fi

        "$PYTHON_EXEC" -m venv ./venv || {
            printf "Failed to create virtual environment. Please check your Python installation.\n" >&2
            return 1
        }
    fi

    printf "Activating virtual environment...\n"
    # shellcheck disable=SC1090
    source "$venv_file" || {
        printf "Failed to activate virtual environment. Please check the venv file path.\n" >&2
        return 1
    }
}

# Install dependencies
install_dependencies() {
    printf "Installing dependencies...\n"
    if ! pip install -r requirements.txt; then
        printf "Failed to install dependencies. Please check your requirements.txt file.\n"
        exit 1
    fi
}


main() {
    if ! setup_python; then
        printf "Python setup failed.\n" >&2
        return 1
    fi

    if ! setup_venv "$VENV_PATH"; then
        printf "Virtual environment setup failed.\n" >&2
        return 1
    fi

    if ! install_dependencies; then
        printf "Dependency installation failed.\n" >&2
        return 1
    fi
}

main


