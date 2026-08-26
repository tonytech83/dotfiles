#!/usr/bin/env bash

# shellcheck disable=SC2034,SC1090

# Global fixed width (inside the box)
BOX_WIDTH=76

##################################################################################
#####   Load external functions
##################################################################################
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for f in "$SCRIPT_DIR"/scripts/*; do
    [[ -f "$f" ]] && source "$f"
done

##################################################################################
#####   Execute the functions in order
##################################################################################
head
start_log
install_nerd_font
check_env
auth_sudo
update_system
install_deps
install_zsh
conf_zsh_env
install_ohmyposh
install_fzf
install_eza
install_fd
install_zoxide
setup_zsh_conf
end_log
