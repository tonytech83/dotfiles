#!/usr/bin/env bash

##################################################################################
#####   Function to install fd
##################################################################################
install_fd() {

    print_step "Install fd"
    start_spinner "Installing..."

    {
        local message
        if command_exists fd; then
            message="$(msg_skip "fd")"
        else
            local fd_version
            fd_version=$(curl -s https://api.github.com/repos/sharkdp/fd/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
            cd /tmp || exit
            wget -c "https://github.com/sharkdp/fd/releases/download/${fd_version}/fd-${fd_version}-x86_64-unknown-linux-musl.tar.gz" -O - | tar xz
            ${SUDO_CMD} mv fd-*/fd /usr/local/bin/fd
            ${SUDO_CMD} chmod +x /usr/local/bin/fd
            if verify_installed fd; then
                message="$(msg_ok "Successfully installed ${BOLD}fd${RC}.")"
            else
                message="$(msg_err "Installation of ${BOLD}fd${RC} could not be verified! Check ${BOLD}${LOG_FILE}${RC} for details.")"
            fi
        fi
    } >> "$LOG_FILE" 2>&1

    stop_spinner "$message"
}