#!/usr/bin/env bash

##################################################################################
#####   Function to install fzf
##################################################################################
install_fzf() {

    print_step "Install fzf"
    start_spinner "Installing..."

    {
        printf "\n#####   Function to install eza   #####\n"
        
        local clone_message
        local message

        if command_exists fzf; then
            message="$(msg_skip "fzf")"
        else
            git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
            ~/.fzf/install --bin
            mkdir -p "$HOME/.local/bin"
            ln -sf "$HOME/.fzf/bin/fzf" "$HOME/.local/bin/fzf"
            if verify_installed fzf; then
                message="$(msg_ok "Successfully installed ${BOLD}fzf${RC}.")"
            else
                message="$(msg_err "Installation of ${BOLD}fzf${RC} could not be verified! Check ${BOLD}${LOG_FILE}${RC} for details.")"
            fi
        fi
    } >> "$LOG_FILE" 2>&1

    stop_spinner "$clone_message" "$message"
}