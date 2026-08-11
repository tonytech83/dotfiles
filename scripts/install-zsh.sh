#!/usr/bin/env bash

##################################################################################
#####   Function to install zsh
##################################################################################
install_zsh() {

    print_step "Install zsh"
    start_spinner "Installing..."

    {
        local message
        
        if ! command_exists zsh; then
            case "$PACKAGER" in
            pacman)
                ${SUDO_CMD} "$PACKAGER" -S --needed --noconfirm zsh
                ;;
            apk)
                ${SUDO_CMD} "$PACKAGER" add zsh
                ;;
            *)
                ${SUDO_CMD} "$PACKAGER" install -y zsh
                ;;
            esac
            if verify_installed zsh; then
                message="$(msg_ok "Successfully installed ${BOLD}zsh${RC}.")"
            else
                message="$(msg_err "Installation of ${BOLD}zsh${RC} could not be verified! Check ${BOLD}${LOG_FILE}${RC} for details.")"
            fi
        else
            message="$(msg_skip "zsh")"
        fi

    } >> "$LOG_FILE" 2>&1

    stop_spinner "$message"
}