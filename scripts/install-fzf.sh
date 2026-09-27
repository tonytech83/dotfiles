#!/bin/sh

##################################################################################
#####   Function to install fzf
##################################################################################
install_fzf() {

    print_step "Install fzf"
    start_spinner "Installing..."

    message=""

    {
        printf "\n#####   Function to install fzf  #####\n"
        
        if command_exists fzf; then
            message="$(msg_skip "fzf")"
            printf "Installation skipped - fzf is already present!\n"
        else
            git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
            ~/.fzf/install --bin
            mkdir -p "$HOME/.local/bin"
            ln -sf "$HOME/.fzf/bin/fzf" "$HOME/.local/bin/fzf"
            if verify_installed fzf; then
                message="$(msg_install_ok "fzf")"
            else
                message="$(msg_install_err "fzf")"
            fi
        fi
    } >> "${LOG_FILE:-/dev/null}" 2>&1

    stop_spinner "$message"
}