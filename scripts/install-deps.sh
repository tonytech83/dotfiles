#!/usr/bin/env bash

##################################################################################
#####   Function to install dependencies
##################################################################################
install_deps() {
    # List of dependencies to install (space-separated, not quoted)
    DEPENDENCIES="stow curl tree wget unzip fontconfig ca-certificates ripgrep"

    print_step "Install dependencies"
    start_spinner "Installing..."

    {
        local message
        local install_status

        case "$PACKAGER" in
        pacman)
            ${SUDO_CMD} pacman-key --init
            ${SUDO_CMD} "${PACKAGER}" -Sy --needed --noconfirm archlinux-keyring
            ${SUDO_CMD} "${PACKAGER}" -Syu --needed --noconfirm ${DEPENDENCIES}
            ;;
        dnf | yum | zypper | apt | apt-get)
            ${SUDO_CMD} "${PACKAGER}" install -y ${DEPENDENCIES}
            ;;
        apk)
            ${SUDO_CMD} "${PACKAGER}" add ${DEPENDENCIES}
            ;;
        *)
            ${SUDO_CMD} "${PACKAGER}" install -yq ${DEPENDENCIES}
            ;;
        esac
        install_status=$?

        if [ "$install_status" -eq 0 ]; then
            message="$(msg_ok "Dependencies installed!")"
        else
            message="$(msg_err "Something went wrong while installing dependencies! Check ${BOLD}${LOG_FILE}${RC} for details.")"
        fi
    } >> "$LOG_FILE" 2>&1

    stop_spinner "$message"

    if [ "$install_status" -ne 0 ]; then
        exit 1
    fi
}