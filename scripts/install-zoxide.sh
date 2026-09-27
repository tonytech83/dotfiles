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
                message="$(msg_ok "Successfully installed ${BOLD}${ITALIC}${MAGENTA}zoxide${RC}.")"
            else
                message="$(msg_err "Installation of ${BOLD}${ITALIC}${MAGENTA}zoxide${RC} could not be verified! Check ${BOLD}${LOG_FILE}${RC} for details.")"
            fi
        fi
    } >> "${LOG_FILE:-/dev/null}" 2>&1

    stop_spinner "$message"
}
