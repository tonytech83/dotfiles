#!/bin/sh -e

# Define color codes for output
RC='\033[0m'
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'

# Initialize variables for package manager, sudo command, superuser group, and git path
PACKAGER=""
SUDO_CMD=""

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check the environment for necessary tools and permissions
checkEnv() {
    # Check for required commands
    REQUIREMENTS="curl sudo"
    for req in $REQUIREMENTS; do
        if ! command_exists "$req"; then
            echo "${RED}Missing required command: $req${RC}"
            exit 1
        fi
    done

    # Determine the package manager to use
    PACKAGEMANAGER="apt dnf yum pacman zypper"
    for pgm in $PACKAGEMANAGER; do
        if command_exists "$pgm"; then
            PACKAGER="$pgm"
            echo "Using package manager: $pgm"
            break
        fi
    done

    if [ -z "$PACKAGER" ]; then
        echo "${RED}No supported package manager found.${RC}"
        exit 1
    fi

    # Determine privilege escalation method
    if [ "$(id -u)" -eq 0 ]; then
        # Running as root
        SUDO_CMD=""
        echo "${YELLOW}Running as root, sudo is not needed.${RC}"
    elif command_exists sudo; then
        SUDO_CMD="sudo"
        echo "Using sudo for privilege escalation."
    elif command_exists doas && [ -f "/etc/doas.conf" ]; then
        SUDO_CMD="doas"
        echo "Using doas for privilege escalation."
    else
        echo "${RED}No suitable privilege escalation tool found (sudo/doas).${RC}"
        exit 1
    fi
}

# Function to install dependencies
installDepend() {
    # List of dependencies to install (space-separated, not quoted)
    DEPENDENCIES="stow lsd curl tree wget unzip fontconfig"

    echo "${YELLOW}Installing dependencies...${RC}"

    if [ "$PACKAGER" = "pacman" ]; then
        # Install AUR helper if not present
        if ! command_exists yay && ! command_exists paru; then
            echo "Installing yay as AUR helper..."
            ${SUDO_CMD} "${PACKAGER}" --noconfirm -S base-devel
            cd /opt && ${SUDO_CMD} git clone https://aur.archlinux.org/yay-git.git && ${SUDO_CMD} chown -R "${USER}:${USER}" ./yay-git
            cd yay-git && makepkg --noconfirm -si
        else
            echo "AUR helper already installed"
        fi

        # Determine which AUR helper to use
        if command_exists yay; then
            AUR_HELPER="yay"
        elif command_exists paru; then
            AUR_HELPER="paru"
        else
            echo "No AUR helper found. Please install yay or paru."
            exit 1
        fi
        "${AUR_HELPER}" --noconfirm -S "${DEPENDENCIES}"

    elif [ "$PACKAGER" = "dnf" ]; then
        ${SUDO_CMD} "${PACKAGER}" install -y "${DEPENDENCIES}"
    elif [ "$PACKAGER" = "zypper" ]; then
        ${SUDO_CMD} "${PACKAGER}" install -y "${DEPENDENCIES}"
    else
        ${SUDO_CMD} "${PACKAGER}" install -yq "${DEPENDENCIES}"
    fi
}

# Function to install zsh
installZsh() {
    if ! command_exists zsh; then
        printf "%b\n" "${YELLOW}Installing Zsh...${RC}"
        case "$PACKAGER" in
        pacman)
            $SUDO_CMD "$PACKAGER" -S --needed --noconfirm zsh
            ;;
        apk)
            $SUDO_CMD "$PACKAGER" add zsh
            ;;
        *)
            $SUDO_CMD "$PACKAGER" install -y zsh
            ;;
        esac
    else
        printf "%b\n" "${GREEN}ZSH is already installed.${RC}"
    fi
}

# Function to install fzf
installFzf() {
    if command_exists fzf || [ -d "$HOME/.fzf" ]; then
        echo "Fzf already installed"
    else
        echo "${YELLOW}Installing Fzf...${RC}"
        ${SUDO_CMD} "${PACKAGER}" install -y fzf 2>/dev/null || {
            echo "${YELLOW}Fzf not available in package manager. Cloning from GitHub...${RC}"
            git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
            ~/.fzf/install
        }
    fi
}

# Function to install Zoxide
installZoxide() {
    if command_exists zoxide; then
        echo "Zoxide already installed"
        return
    fi

    # Install Zoxide
    if ! curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh; then
        echo "${RED}Something went wrong during zoxide install!${RC}"
        exit 1
    fi
}

# Function to install Oh My Posh
installOhMyPosh() {
    if command_exists oh-my-posh; then
        echo "Oh My Posh already installed"
        return
    fi

    # Check if the ./local/bin exists
    LOCALBINFOLDER="$HOME/.local/bin"
    if [ ! -d "$LOCALBINFOLDER" ]; then
        echo "${YELLOW}Creating directory: $LOCALBINFOLDER${RC}"
        mkdir -p "$LOCALBINFOLDER"
        echo "${GREEN}Directory created: $LOCALBINFOLDER${RC}"
    fi

    # Install Oh My Posh
    if ! curl -sS https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin; then
        echo "${RED}Something went wrong during Oh My Posh install!${RC}"
        exit 1
    fi
}

setupZshConfig() {
    # Clone dotfiles repo
    cd ~/dotfiles

    # Check if stow is available
    if ! command_exists stow; then
        echo "${RED}Stow is not installed. Please install it first.${RC}"
        exit 1
    fi

    # Create a dry run first to check for conflicts
    echo "${YELLOW}Checking for potential conflicts...${RC}"
    if ! stow -n .; then
        echo "${RED}Stow detected conflicts. Please check the output above.${RC}"
        echo "${YELLOW}You may need to manually resolve conflicts.${RC}"
        exit 1
    fi

    # If dry run successful, perform actual stow
    echo "${YELLOW}Creating symlinks...${RC}"
    if ! stow .; then
        echo "${RED}Failed to create symlinks${RC}"
        exit 1
    fi

    # Verify critical files were linked
    if [ ! -L "$HOME/.zshrc" ]; then
        echo "${RED}Failed to create .zshrc symlink${RC}"
        exit 1
    fi

    # Change default shell to zsh for current user
    sudo chsh -s "$(which zsh)" "$USER"

    echo "${GREEN}ZSH configuration setup completed successfully!${RC}"

    # Optionally source the new configuration
    if [ -f "$HOME/.zshrc" ]; then
        echo "${YELLOW}Please logout and login again! The installation will continue ...${RC}"
    fi
}

# Execute the functions in order
checkEnv
installZsh
installDepend
installOhMyPosh
installFzf
installZoxide
setupZshConfig
