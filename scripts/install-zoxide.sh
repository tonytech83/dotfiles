#!/usr/bin/env bash

##################################################################################
#####   Function to install zoxide
##################################################################################
install_zoxide() {

    print_step "Install zoxide"
    start_spinner "Installing..."

    {
        printf "\n#####   Function to install eza   #####\n"
        
        local message

        if command_exists zoxide; then
            message="$(msg_skip "zoxide")"
        else
            curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
            if verify_installed zoxide; then
                message="$(msg_ok "Successfully installed ${BOLD}zoxide${RC}.")"
            else
                message="$(msg_err "Installation of ${BOLD}zoxide${RC} could not be verified! Check ${BOLD}${LOG_FILE}${RC} for details.")"
            fi
        fi
    } >> "$LOG_FILE" 2>&1

    stop_spinner "$message"
}
