#!/bin/sh

# ==========================================================
# dotfiles - A shell-menu driven script for zsh and dotfiles setup
# ==========================================================
# Author      : tonytech
# Version     : 1.0
# Last Updated: 27/09/2026
# ==========================================================
# Description:
# This script bootstraps a Linux dotfiles environment for zsh.
#
# - Sets the project root and loads shared helper scripts.
# - Runs the setup flow for system updates and dependency installation.
# - Installs and configures Nerd Fonts, zsh, Oh My Posh, fzf, eza, fd, and zoxide.
# - Creates or updates the shell environment and zsh configuration files.
# - Logs the setup workflow for troubleshooting and verification.
#
# The script is designed to prepare a consistent developer terminal setup
# with custom dotfiles and modern command-line tools.
#
# Copyright (c) 2026 tonytech
#
# License: MIT
#
# ==========================================================

# shellcheck disable=SC2034,SC1090

# Global fixed width (inside the box)
BOX_WIDTH=76

##################################################################################
#####   Load external functions
##################################################################################
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd -P)"

for f in "$SCRIPT_DIR"/scripts/*; do
    if [ -f "$f" ]; then
        . "$f"
    fi
done

##################################################################################
#####   Execute the functions in order
##################################################################################
head
start_log
check_env
auth_sudo
update_system
install_deps
install_nerd_font "$@"
install_zsh
conf_zsh_env
install_ohmyposh
install_fzf
install_eza
install_fd
install_zoxide
setup_zsh_conf
end_log
