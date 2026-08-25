#!/usr/bin/env bash

##################################################################################
##### Function to install oh-my-posh
##################################################################################
install_ohmyposh() {

    print_step "Install oh-my-posh"
    start_spinner "Installing..."

    {
        printf "\n#####   Function to install eza   #####\n"
        
        local mkdir_message
        local mkdir_confirm
        local message

        if command_exists oh-my-posh; then
            message="$(msg_skip "oh-my-posh")"
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
                message="$(msg_ok "Successfully installed ${BOLD}oh-my-posh${RC}!")"
            else
                message="$(msg_err "Installation of ${BOLD}oh-my-posh${RC} could not be verified! Check ${BOLD}${LOG_FILE}${RC} for details.")"
            fi
        fi
    } >> "$LOG_FILE" 2>&1

    stop_spinner "$mkdir_message" "$mkdir_confirm" "$message"
}