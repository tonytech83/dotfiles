#!/usr/bin/env bash

# shellcheck disable=SC2034

##################################################################################
#####   Function to check the environment for necessary tools and permissions
##################################################################################
check_env() {

    print_step "Check the environment for necessary tools and permissions"
    start_spinner "Checking..."

    {
        local req_message
        local pm_message
        local priv_message

        # Check for required commands
        REQUIREMENTS="curl sudo"
        for req in $REQUIREMENTS; do
            if ! command_exists "$req"; then
                req_message="$(msg_err "Missing required command: $req")"
                exit 1
            fi
        done

        # Determine the package manager to use
        PACKAGEMANAGER="apt-get dnf yum pacman zypper apk"
        for pgm in $PACKAGEMANAGER; do
            if command_exists "$pgm"; then
                PACKAGER="$pgm"
                pm_message="$(msg_ok "Using ${BOLD}${ITALIC}${MAGENTA}$pgm${RC} for package manager.")"
                break
            fi
        done

        if [ -z "$PACKAGER" ]; then
            pm_message="$(msg_err "No supported package manager found.")"
            exit 1
        fi

        # Determine privilege escalation method
        if [ "$(id -u)" -eq 0 ]; then
            # Running as root
            SUDO_CMD=""
            priv_message="$(msg_ok "Running as root, sudo is not needed.")"
        elif command_exists sudo; then
            SUDO_CMD="sudo"
            priv_message="$(msg_ok "Using ${BOLD}${ITALIC}${MAGENTA}sudo${RC} for privilege escalation.")"
        elif command_exists doas && [ -f "/etc/doas.conf" ]; then
            SUDO_CMD="doas"
            priv_message="$(msg_ok "Using doas for privilege escalation.")"
        else
            priv_message="$(msg_err "No suitable privilege escalation tool found (sudo/doas).")"
            exit 1
        fi
    } >> "$LOG_FILE" 2>&1

    stop_spinner "$req_message" "$pm_message" "$priv_message"
}
