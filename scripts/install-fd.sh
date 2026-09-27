#!/bin/sh

##################################################################################
#####   Function to install fd
##################################################################################

# A simple, fast and user-friendly alternative to 'find'

install_fd() {

    print_step "Install fd"
    start_spinner "Installing..."

    message=""

    {   
        printf "\n#####   Function to install fd   #####\n"

        if command_exists fd; then
            message="$(msg_skip "fd")"
            printf "Installation skipped - fd is already present!\n"
        else
            fd_version
            fd_version=$(curl -s https://api.github.com/repos/sharkdp/fd/releases/latest | jq -r '.tag_name')
            cd /tmp || exit
            wget -c "https://github.com/sharkdp/fd/releases/download/${fd_version}/fd-${fd_version}-x86_64-unknown-linux-musl.tar.gz" -O - | tar xz
            ${SUDO_CMD} mv fd-*/fd /usr/local/bin/fd
            ${SUDO_CMD} chmod +x /usr/local/bin/fd
            if verify_installed fd; then
                message="$(msg_install_ok "fd")"
            else
                message="$(msg_install_err "fd")"
            fi
        fi
    } >> "${LOG_FILE:-/dev/null}" 2>&1

    stop_spinner "$message"
}