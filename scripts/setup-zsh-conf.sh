#!/bin/sh

# shellcheck disable=SC2059

##################################################################################
#####   Steps for zsh configuration (stops at the first failure)
##################################################################################
_setup_zsh_conf_steps() {

    # Check if the dotfiles directory exists
    cd "$DOTFILES_DIR" || {
        message="$(msg_err "Dotfiles directory '$DOTFILES_DIR' not found")"
        return 1
    }

    # Check if stow is available
    if ! command_exists stow; then
        message="$(msg_err "${BOLD}Stow${RC} is not installed. Please install it first.")"
        return 1
    fi

    # Back up existing configs that would conflict
    for rc in .nanorc .vimrc; do
        if [ -f "$HOME/$rc" ] && [ ! -L "$HOME/$rc" ]; then
            mv "$HOME/$rc" "$HOME/$rc.bak"
            printf '%s backed up to ~/%s.bak\n' "$rc" "$rc"
        fi
    done

    # Dry run first to check for conflicts (same target as the real run)
    printf 'Checking for potential stow conflicts...\n'
    if ! stow -n -t "$HOME" .; then
        message="$(msg_err "${BOLD}Stow${RC} detected conflicts. You may need to manually resolve conflicts.")"
        return 1
    fi

    # Perform actual stow
    printf 'Creating symlinks...\n'
    if ! stow -t "$HOME" .; then
        message="$(msg_err "Failed to create symlinks.")"
        return 1
    fi

    # Verify critical files were linked
    if [ ! -f "$HOME/.config/zsh/.zshrc" ]; then
        message="$(msg_err "Failed to create ${BOLD}.zshrc${RC} symlink.")"
        return 1
    fi

    # Change default shell to zsh for current user
    zsh_path="$(command -v zsh)" || {
        message="$(msg_err "${BOLD}zsh${RC} not found in PATH.")"
        return 1
    }
    if ! ${SUDO_CMD} chsh -s "$zsh_path" "$(id -un)"; then
        message="$(msg_err "Failed to change default shell to ${BOLD}zsh${RC}.")"
        return 1
    fi

    # Create required directories
    mkdir -p "$HOME/.local/state/zsh" "$HOME/.cache/zsh"

    message="$(msg_ok "Configuration of ${BOLD}${ITALIC}${MAGENTA}zsh${RC} setup completed successfully!")"
}

##################################################################################
#####   Function to setup zsh configuration
##################################################################################
setup_zsh_conf() {

    print_step "Setup zsh configuration"
    start_spinner "Configuring..."

    message=""
    continue=true

    {   
        printf "\n#####   Function to setup zsh configuration   #####\n"

        _setup_zsh_conf_steps || continue=false

    } >> "${LOG_FILE:-/dev/null}" 2>&1

    stop_spinner "$message"

    if [ "$continue" = false ]; then
        exit 1
    fi

    # Source the new configuration
    printf "\n"
    printf "%sPlease execute %sexec zsh%s %sand the installation will continue ...%s" "${BOLD}${ITALIC}" "${BOLD}${MAGENTA}" "${RC}" "${BOLD}${ITALIC}" "${RC}"
    printf "\n"
}