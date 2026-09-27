#!/bin/sh

# shellcheck disable=SC2086

pkg_installed() {
    case "$PACKAGER" in
        apt-get)        dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "install ok installed" ;;
        dnf|yum|zypper) rpm -q "$1" >/dev/null 2>&1 ;;
        pacman)         pacman -Q "$1" >/dev/null 2>&1 ;;
        apk)            apk info -e "$1" >/dev/null 2>&1 ;;
        *)              return 1 ;;
    esac
}

install_pkg() {
    case "$PACKAGER" in
        apt-get) $SUDO_CMD env DEBIAN_FRONTEND=noninteractive apt-get install -y "$@" ;;
        dnf|yum) $SUDO_CMD "$PACKAGER" install -y "$@" ;;
        pacman)  $SUDO_CMD pacman -S --noconfirm --needed "$@" ;;
        zypper)  $SUDO_CMD zypper --non-interactive install "$@" ;;
        apk)     $SUDO_CMD apk add "$@" ;;
        *)       printf 'Unsupported package manager: %s\n' "$PACKAGER"; return 1 ;;
    esac
}

##################################################################################
#####   Function to install dependencies
##################################################################################
install_deps() {
    # List of dependencies to install (space-separated, not quoted)
    DEPENDENCIES="stow curl tree wget unzip fontconfig ca-certificates jq"

    print_step "Install dependencies"
    
    for dep in $DEPENDENCIES; do
        start_spinner "Installing..."

        message=""
        install_status=0

        {
            if pkg_installed "$dep"; then
                message="$(msg_skip "$dep")"
                printf "\n--- %s skipped (already installed) ---\n" "$dep"
            elif install_pkg "$dep"; then
                message="$(msg_install_ok "$dep")"
                printf "\n--- %s installed ---\n" "$dep"
            else
                install_status=$?
                message="$(msg_err "Something went wrong while installing ${BOLD}${ITALIC}${MAGENTA}$dep${RC} pkg! Check ${BOLD}${LOG_FILE}${RC} for details.")"
                printf "\n--- %s FAILED (exit %s) ---\n" "$dep" "$install_status"
            fi
        } >> "${LOG_FILE:-/dev/null}" 2>&1

        if [ "$install_status" -ne 0 ]; then
            stop_spinner "$message"
            exit 1
        fi

        stop_spinner "$message"
        
    done
}