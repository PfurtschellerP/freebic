#!/bin/bash
# shellcheck disable=SC2016,SC2088
# Generate .bashrc file for users logging in with himmelblau, setting up the
# environment and running the himmelblau login script

set -euo pipefail

readonly BASHRC_FILE="${HOME}/.bashrc"
readonly BASH_PROFILE_FILE="${HOME}/.bash_profile"

# Log message
echo "Generating .bashrc for himmelblau users"

# Create .bashrc if it doesn't exist
if [[ ! -f "${BASHRC_FILE}" ]]; then
    cat << 'EOF' > "${BASHRC_FILE}"
# .bashrc

# Source global definitions
if [[ -f /etc/bashrc ]]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "${PATH}" =~ ${HOME}/.local/bin:${HOME}/bin: ]]; then
    PATH="${HOME}/.local/bin:${HOME}/bin:${PATH}"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [[ -d "${HOME}/.bashrc.d" ]]; then
    for rc in "${HOME}/.bashrc.d"/*; do
        if [[ -f "${rc}" ]]; then
            . "${rc}"
        fi
    done
fi
unset rc
EOF
fi

# Create .bash_profile if it doesn't exist
if [[ ! -f "${BASH_PROFILE_FILE}" ]]; then
    cat << 'EOF' > "${BASH_PROFILE_FILE}"
# .bash_profile

# Get the aliases and functions
if [[ -f "${HOME}/.bashrc" ]]; then
    . "${HOME}/.bashrc"
fi

# User specific environment and startup programs
EOF
fi