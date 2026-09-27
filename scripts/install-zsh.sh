#!/bin/sh

##################################################################################
#####   Function to install zsh
##################################################################################
install_zsh() {

    print_step "Install zsh"
    start_spinner "Installing..."

    {
        printf "\n#####   Function to install zsh   #####\n"
        
        message

        if command_exists zsh; then
            message="$(msg_skip "zsh")"
            printf "Installation skipped - zsh is already present!\n"
        else
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
                message="$(msg_install_ok "zsh")"
            else
                message="$(msg_install_err "zsh")"
            fi
        fi

    } >> "${LOG_FILE:-/dev/null}" 2>&1

    stop_spinner "$message"
}