#!/bin/sh

##################################################################################
#####   Function to install zoxide
##################################################################################
install_zoxide() {

    print_step "Install zoxide"
    start_spinner "Installing..."

    message=""

    {
        printf "\n#####   Function to install zoxide   #####\n"

        if command_exists zoxide; then
            message="$(msg_skip "zoxide")"
            printf "Installation skipped - zoxide is already present!\n"
        else
            curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
            if verify_installed zoxide; then
                message="$(msg_install_ok "zoxide")"
            else
                message="$(msg_install_err "zoxide")"
            fi
        fi
    } >> "${LOG_FILE:-/dev/null}" 2>&1

    stop_spinner "$message"
}
