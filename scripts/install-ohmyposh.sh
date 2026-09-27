#!/bin/sh

##################################################################################
#####   Function to install oh-my-posh
##################################################################################
install_ohmyposh() {

    print_step "Install oh-my-posh"
    start_spinner "Installing..."

    mkdir_message=""
    mkdir_confirm=""
    message=""

    {
        printf "\n#####   Function to install oh-my-posh   #####\n"

        if command_exists oh-my-posh; then
            message="$(msg_skip "oh-my-posh")"
            printf "Installation skipped - oh-my-posh is already present!\n"
        else
            # Check if the ./local/bin exists
            LOCALBINFOLDER="$HOME/.local/bin"
            if [ ! -d "$LOCALBINFOLDER" ]; then
                mkdir_message="$(msg_warn "Creating directory: $LOCALBINFOLDER")"
                mkdir -p "$LOCALBINFOLDER"
                mkdir_confirm="$(msg_ok "Directory created: $LOCALBINFOLDER")"
            fi

            # Install Oh My Posh
            if curl -sS https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin && verify_installed oh-my-posh; then
                message="$(msg_install_ok "oh-my-posh")"
            else
                message="$(msg_install_err "oh-my-posh")"
            fi
        fi
    } >> "${LOG_FILE:-/dev/null}" 2>&1

    stop_spinner "$mkdir_message" "$mkdir_confirm" "$message"
}