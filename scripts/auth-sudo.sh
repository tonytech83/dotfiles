#!/usr/bin/env bash

##################################################################################
#####   Function to authenticate sudo early
##################################################################################
auth_sudo() {
    # Only prompt for sudo if we need it and it's available
    if [ -n "$SUDO_CMD" ] && [ "$SUDO_CMD" = "sudo" ]; then
        print_step "Authenticating sudo access"

        # Validate we can use sudo non-interactively (e.g. passwordless/NOPASSWD)
        if ! ${SUDO_CMD} -n true; then
            printf '%b\n' "$(msg_err "Failed to authenticate sudo access (passwordless sudo required)")"
            exit 1
        fi

        printf '%b\n\n' "$(msg_ok "Sudo authentication successful!")"

        # Keep sudo alive in background (optional - refreshes every 60 seconds)
        # This prevents timeout during long operations
        while true; do
            ${SUDO_CMD} -n true
            sleep 60
            kill -0 "$$" || exit
        done 2>/dev/null &
    fi
}