#!/usr/bin/env bash

# shellcheck disable=SC2059

##################################################################################
#####   Function to setup zsh configuration
##################################################################################
setup_zsh_conf() {

    print_step "Setup zsh configuration"
    start_spinner "Configuring..."

    {   
        printf "\n#####   Function to setup zsh configuration   #####\n"

        local message

        # Check if the dotfiles directory exists
        cd "$DOTFILES_DIR" || {
            message="$(msg_err "Dotfiles directory '$DOTFILES_DIR' not found")"
            exit 1
        }

        # Check if stow is available
        if ! command_exists stow; then
            message="$(msg_err "${BOLD}Stow${RC} is not installed. Please install it first.")"
            exit 1
        fi

        # Check if ~/.nanorc exists
        if [ -f "$HOME/.nanorc" ]; then
            mv "$HOME/.nanorc" "$HOME/.nanorc.bak"
            printf "%snano configuration file backup in ~/.nanorc.bak%s\n" "${GREEN}" "${RC}"
        fi

        # Check if ~/.vimrc exists
        if [ -f "$HOME/.vimrc" ]; then
            mv "$HOME/.vimrc" "$HOME/.vimrc.bak"
            printf "%svim configuration file backup in ~/.vimrc.bak%s\n" "${GREEN}" "${RC}"
        fi

        # Do stow dry run first to check for conflicts
        printf "$(msg_warn "Checking for potential stow conflicts...")"

        if ! stow -n .; then
            message="$(msg_err "${BOLD}Stow${RC} detected conflicts. You may need to manually resolve conflicts.")"
            exit 1
        fi

        # If dry run successful, perform actual stow
        printf "$(msg_warn "Creating symlinks...")"

        if ! stow -t "$HOME" .; then
            message="$(msg_err "Failed to create symlinks.")"
            exit 1
        fi

        # Verify critical files were linked
        if [ ! -f "$HOME/.config/zsh/.zshrc" ]; then
            message="$(msg_err "Failed to create ${BOLD}.zshrc${RC} symlink.")"
            exit 1
        fi

        # Change default shell to zsh for current user
        ${SUDO_CMD} chsh -s "$(which zsh)" "$USER"

        # Create required directories
        mkdir -p "$HOME/.local/state/zsh"   # history
        mkdir -p "$HOME/.cache/zsh"         # completion cache

        message="$(msg_ok "Configuration of ${BOLD}${ITALIC}${MAGENTA}zsh${RC} setup completed successfully!")"

    } >> "$LOG_FILE" 2>&1

    stop_spinner "$message"

    # Source the new configuration
    printf "%sPlease execute %sexec zsh%s %sand the installation will continue ...%s" "${BOLD}${ITALIC}" "${BOLD}${MAGENTA}" "${RC}" "${BOLD}${ITALIC}" "${RC}"
}