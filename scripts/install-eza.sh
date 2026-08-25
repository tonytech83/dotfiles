#!/usr/bin/env bash

##################################################################################
#####   Function to install eza
##################################################################################
install_eza() {

    print_step "Install eza"
    start_spinner "Installing..."

    {   
        printf "\n#####   Function to install eza   #####\n"

        local message

        if command_exists eza; then
            message="$(msg_skip "eza")"
        else
            cd /tmp || exit
            wget -c https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-musl.tar.gz -O - | tar xz
            ${SUDO_CMD} chmod +x eza
            ${SUDO_CMD} chown root:root eza
            ${SUDO_CMD} mv eza /usr/local/bin/eza
            if verify_installed eza; then
                message="$(msg_ok "Successfully installed ${BOLD}eza${RC}.")"
            else
                message="$(msg_err "Installation of ${BOLD}eza${RC} could not be verified! Check ${BOLD}${LOG_FILE}${RC} for details.")"
            fi
        fi
    } >> "$LOG_FILE" 2>&1

    stop_spinner "$message"
}