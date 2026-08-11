#!/usr/bin/env bash

##################################################################################
##### Function to setup zsh configuration
##################################################################################
setup_zsh_conf() {

    print_step "Setup zsh configuration"
    start_spinner "Configuring..."

    {
        local message
        local continue_message
        local err_message
        local success_message

        # Clone dotfiles repo
        cd "$DOTFILES_DIR" || {
            err_message="$(msg_err "Dotfiles directory '$DOTFILES_DIR' not found")"
            exit 1
        }

        # Check if stow is available
        if ! command_exists stow; then
            err_message="$(msg_err "${BOLD}Stow${RC} is not installed. Please install it first.")"
            exit 1
        fi

        # Check if ~/.nanorc exists
        if [ -f "$HOME/.nanorc" ]; then
            mv "$HOME/.nanorc" "$HOME/.nanorc.bak"
            message="${GREEN}nano configuration file backup in ~/.nanorc.bak${RC}"
        fi

        # Do stow dry run first to check for conflicts
        message="$(msg_warn "Checking for potential stow conflicts...")"

        if ! stow -n .; then
            err_message="$(msg_err "${BOLD}Stow${RC} detected conflicts. You may need to manually resolve conflicts.")"
            exit 1
        fi

        # If dry run successful, perform actual stow
        message="$(msg_warn "Creating symlinks...")"

        if ! stow -t "$HOME" .; then
            err_message="$(msg_err "Failed to create symlinks.")"
            exit 1
        fi

        # Verify critical files were linked
        if [ ! -f "$HOME/.config/zsh/.zshrc" ]; then
            err_message="$(msg_err "Failed to create ${BOLD}.zshrc${RC} symlink.")"
            exit 1
        fi

        # Change default shell to zsh for current user
        ${SUDO_CMD} chsh -s "$(which zsh)" "$USER"

        # Create required directories
        mkdir -p "$HOME/.local/state/zsh"   # history
        mkdir -p "$HOME/.cache/zsh"         # completion cache

        success_message="$(msg_ok "Configuration of ${BOLD}${ITALIC}${MAGENTA}zsh${RC} setup completed successfully!")"

        # Source the new configuration
        continue_message="$(msg_ok "Please execute ${BOLD}${ITALIC}${MAGENTA}exec zsh${RC} and the installation will continue ...")"

    } >> "$LOG_FILE" 2>&1

    stop_spinner "$err_message" "$success_message" "$continue_message"
}