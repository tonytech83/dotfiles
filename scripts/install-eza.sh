#!/bin/sh

##################################################################################
#####   Function to install eza
##################################################################################
install_eza() {

    print_step "Install eza"
    start_spinner "Installing..."

    message=""

    {   
        printf "\n#####   Function to install eza   #####\n"

        if command_exists eza; then
            message="$(msg_skip "eza")"
            printf "Installation skipped - eza is already present!\n"
        else
            cd /tmp || exit
            wget -c https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-musl.tar.gz -O - | tar xz
            ${SUDO_CMD} chmod +x eza
            ${SUDO_CMD} chown root:root eza
            ${SUDO_CMD} mv eza /usr/local/bin/eza
            if verify_installed eza; then
                message="$(msg_install_ok "eza")"
            else
                message="$(msg_install_err "eza")"
            fi
        fi
    } >> "${LOG_FILE:-/dev/null}" 2>&1

    stop_spinner "$message"
}