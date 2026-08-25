#!/usr/bin/env bash

##################################################################################
#####   Function to update system packages
##################################################################################
update_system() {

    print_step "Update system packages"
    start_spinner "Updating..."

    local message
    local unsupported=0

    {
        printf "\n#####   Function to install eza   #####\n"
        
        case "$PACKAGER" in
            pacman)
                ${SUDO_CMD} "$PACKAGER" -Sy
                ;;
            apt-get)
                ${SUDO_CMD} "$PACKAGER" update
                ;;
            dnf)
                ${SUDO_CMD} "$PACKAGER" update -y
                ;;
            zypper)
                ${SUDO_CMD} "$PACKAGER" ref
                ;;
            apk)
                ${SUDO_CMD} "$PACKAGER" update
                ;;
            *)
                unsupported=1
                ;;
        esac
    } >> "$LOG_FILE" 2>&1

    if [ "$unsupported" -eq 1 ]; then
        message="$(msg_err "Unsupported package manager: ${PACKAGER}")"
        stop_spinner "$message"
        exit 1
    fi

    message="$(msg_ok "System packages updated!")"

    stop_spinner "$message"
}