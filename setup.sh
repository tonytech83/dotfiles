#!/bin/sh

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
