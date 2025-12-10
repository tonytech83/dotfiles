#!/bin/sh

# Global fixed width (inside the box)
BOX_WIDTH=76

# Define color codes for output
RC="$(printf '\033[0m')"
RED="$(printf '\033[31m')"
YELLOW="$(printf '\033[33m')"
GREEN="$(printf '\033[32m')"

BOLD="$(printf '\033[1m')"
DIM="$(printf '\033[2m')"
ITALIC="$(printf '\033[3m')"
UNDCERLINE="$(printf '\033[4m')"
BLINK="$(printf '\033[5m')"
REVERSE="$(printf '\033[7m')"
HIDDEN="$(printf '\033[8m')"
STRIKE="$(printf '\033[9m')"

# Initialize variables for package manager, sudo command, superuser group, and git path
PACKAGER=""
PACKAGEMANAGER=""
SUDO_CMD=""
REQUIREMENTS=""
DEPENDENCIES=""
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

print_action() {
    content="$1"
    width=${BOX_WIDTH:-76}
    stripped_content=$(printf "%s" "$content" | sed 's/\x1B\[[0-9;]*[a-zA-Z]//g') # strip ANSI
    content_length=$(printf "%s" "$stripped_content" | wc -c)
    inner_width=$((width - 2)) # 1 space before + 1 after
    padding=$((inner_width - content_length))
    if [ "$padding" -lt 0 ]; then
        content=$(printf "%s" "$content" | cut -c1-$inner_width)
        padding=0
    fi

    echo ""
    printf " ╔"
    printf '═%.0s' $(seq 1 "$width")
    printf "╗\n"
    printf " ║ %s%*s ║\n" "$content" "$padding" ""
    printf " ╚"
    printf '═%.0s' $(seq 1 "$width")
    printf "╝\n"
    echo ""
}

##################################################################################
#####   Function to check if a command exists
##################################################################################
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

##################################################################################
#####   Function to check the environment for necessary tools and permissions
##################################################################################
checkEnv() {

    print_action "${ITALIC}${BOLD}${YELLOW}Check the environment for necessary tools and permissions${RC}"

    # Check for required commands
    REQUIREMENTS="curl sudo"
    for req in $REQUIREMENTS; do
        if ! command_exists "$req"; then
            echo "${BOLD}${RED} ==>${RC} Missing required command: $req"
            exit 1
        fi
    done

    # Determine the package manager to use
    PACKAGEMANAGER="apt dnf yum pacman zypper apk"
    for pgm in $PACKAGEMANAGER; do
        if command_exists "$pgm"; then
            PACKAGER="$pgm"
            echo " ${BOLD}==>${RC} Using ${BOLD}${GREEN}$pgm${RC} for package manager."
            break
        fi
    done

    if [ -z "$PACKAGER" ]; then
        echo "${BOLD}${RED} ==>${RC} No supported package manager found."
        exit 1
    fi

    # Determine privilege escalation method
    if [ "$(id -u)" -eq 0 ]; then
        # Running as root
        SUDO_CMD=""
        echo "${BOLD}${YELLOW} ==>${RC} Running as root, sudo is not needed."
    elif command_exists sudo; then
        SUDO_CMD="sudo"
        echo "${BOLD} ==>${RC} Using ${BOLD}${GREEN}sudo${RC} for privilege escalation."
    elif command_exists doas && [ -f "/etc/doas.conf" ]; then
        SUDO_CMD="doas"
        echo "${BOLD} ==>${RC} Using ${BOLD}${GREEN}doas${RC} for privilege escalation."
    else
        echo "${BOLD}${RED} ==>${RC} No suitable privilege escalation tool found (sudo/doas)."
        exit 1
    fi
}

##################################################################################
#####   Function to install dependencies
##################################################################################
installDepend() {
    # List of dependencies to install (space-separated, not quoted)
    DEPENDENCIES="stow curl tree wget unzip fontconfig ca-certificates"

    print_action "${ITALIC}${BOLD}${YELLOW}Installing dependencies...${RC}"

    case "$PACKAGER" in
    pacman)
        # Install AUR helper if not present
        if ! command_exists yay && ! command_exists paru; then
            echo "${BOLD}${YELLOW} ==>${RC} Installing yay as AUR helper..."
            ${SUDO_CMD} "${PACKAGER}" --noconfirm -S base-devel
            cd /opt && ${SUDO_CMD} git clone https://aur.archlinux.org/yay-git.git && ${SUDO_CMD} chown -R "${USER}:${USER}" ./yay-git
            cd yay-git && makepkg --noconfirm -si
        else
            echo "${BOLD}${YELLOW} ==>${RC} AUR helper already installed!"
        fi

        # Determine which AUR helper to use
        if command_exists yay; then
            AUR_HELPER="yay"
        elif command_exists paru; then
            AUR_HELPER="paru"
        else
            echo "${BOLD}${RED} ==>${RC} No AUR helper found. Please install ${BOLD}yay${RC} or ${BOLD}paru${RC}."
            exit 1
        fi
        "${AUR_HELPER}" --noconfirm -S ${DEPENDENCIES}
        ;;
    dnf | yum | zypper | apt | apt-get)
        ${SUDO_CMD} "${PACKAGER}" install -y ${DEPENDENCIES}
        ;;
    apk)
        ${SUDO_CMD} "${PACKAGER}" add ${DEPENDENCIES}
        ;;
    *)
        ${SUDO_CMD} "${PACKAGER}" install -yq ${DEPENDENCIES}
        ;;
    esac
}

##################################################################################
#####   Function to install eza
##################################################################################
installEza() {

    print_action "${ITALIC}${BOLD}${YELLOW}Installing eza${RC}"

    if ! command_exists eza; then
        printf "%b\n" "${BOLD}${YELLOW} ==>${RC} Installing ${BOLD}eza${RC}."
        cd /tmp
        wget -c https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz -O - | tar xz
        ${SUDO_CMD} chmod +x eza
        ${SUDO_CMD} chown root:root eza
        ${SUDO_CMD} mv eza /usr/local/bin/eza
        echo "${BOLD}${GREEN} ==> ${RC} Successfully installed ${BOLD}eza${RC}."
    else
        printf "%b\n" "${BOLD}${GREEN} ==>${RC} ${BOLD}eza${RC} is already installed."
    fi
}

##################################################################################
#####   Function to install zsh
##################################################################################
installZsh() {

    print_action "${ITALIC}${BOLD}${YELLOW}Installing zsh${RC}"

    if ! command_exists zsh; then
        printf "%b\n" "${BOLD}${YELLOW} ==>${RC} Installing ${BOLD}zsh${RC}..."
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
        echo "${BOLD}${GREEN} ==>${RC} Successfully installed ${BOLD}zsh${RC}."
    else
        printf "%b\n" "${BOLD}${GREEN} ==>${RC} ${BOLD}zsh${RC} is already installed."
    fi
}

##################################################################################
#####   Function to install fzf
##################################################################################
installFzf() {

    print_action "${ITALIC}${BOLD}${YELLOW}Installing fzf${RC}"

    if command_exists fzf || [ -d "$HOME/.fzf" ]; then
        echo "${BOLD}${GREEN} ==>${RC} ${BOLD}fzf${RC} already installed!"
    else
        echo "${YELLOW} ==>${RC} Installing ${BOLD}fzf${RC}..."
        ${SUDO_CMD} "${PACKAGER}" install -y fzf 2>/dev/null || {
            echo "${BOLD}${YELLOW} ==>${RC} ${BOLD}fzf${RC} not available in package manager. Cloning from GitHub..."
            git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
            ~/.fzf/install
        }
        echo "${BOLD}${GREEN} ==>${RC} Successfully installed ${BOLD}fzf${RC}."
    fi
}

##################################################################################
#####   Function to install Zoxide
##################################################################################
installZoxide() {

    print_action "${ITALIC}${BOLD}${YELLOW}Installing Zoxide${RC}"

    if command_exists zoxide; then
        echo "${BOLD}${GREEN} ==>${RC} ${BOLD}Zoxide${RC} already installed."
        return
    fi

    # Install Zoxide
    if curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh; then
        echo "${BOLD}${GREEN} ==>${RC} Successfully installed ${BOLD}Zoxide${RC}!"
    else
        echo "${BOLD}${RED} ==>${RC} Something went wrong during ${BOLD}Zoxide${RC} install!"
        exit 1
    fi
}

##################################################################################
##### Function to install Oh My Posh
##################################################################################
installOhMyPosh() {

    print_action "${ITALIC}${BOLD}${YELLOW}Installing Oh My Posh${RC}"

    if command_exists oh-my-posh; then
        echo "${BOLD}${GREEN} ==>${RC} ${BOLD}Oh My Posh${RC} already installed!"
        return
    fi

    # Check if the ./local/bin exists
    LOCALBINFOLDER="$HOME/.local/bin"
    if [ ! -d "$LOCALBINFOLDER" ]; then
        echo "${BOLD}${YELLOW} ==>${RC} Creating directory: $LOCALBINFOLDER"
        mkdir -p "$LOCALBINFOLDER"
        echo "${BOLD}${GREEN} ==>${RC} Directory created: $LOCALBINFOLDER"
    fi

    # Install Oh My Posh
    if curl -sS https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin; then
        echo "${BOLD}${GREEN} ==>${RC} Successfully installed ${BOLD}Oh My Posh${RC}!"
    else
        echo "${BOLD}${RED} ==>${RC} Something went wrong during ${BOLD}Oh My Posh${RC} install!"
        exit 1
    fi
}

setupZshConfig() {

    print_action "${ITALIC}${BOLD}${YELLOW}Setup ZSH configuration...${RC}"

    # Clone dotfiles repo
    cd "$DOTFILES_DIR" || {
        echo "Dotfiles directory '$DOTFILES_DIR' not found"
        exit 1
    }

    # Check if stow is available
    if ! command_exists stow; then
        echo "${BOLD}${RED}==>${RC} ${BOLD}Stow${RC} is not installed. Please install it first."
        exit 1
    fi

    # Check if ~/.zshrc exists
    if [ -f "$HOME/.zshrc" ]; then
        mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
        echo "${GREEN}zsh configuration file backup in ~/.zshrc.bak${RC}"
    fi

    # Check if ~/.config/eza/theme.yml exists
    if [ -f "$HOME/.config/eza/theme.yml" ]; then
        mv "$HOME/.config/eza/theme.yml" "$HOME/.config/eza/theme.yml.bak"
        echo "${GREEN}eza configuration file backup in ~/.config/eza/theme.yml.bak${RC}"
    fi

    # Check if ~/.nanorc exists
    if [ -f "$HOME/.nanorc" ]; then
        mv "$HOME/.nanorc" "$HOME/.nanorc.bak"
        echo "${GREEN}nano configuration file backup in ~/.nanorc.bak${RC}"
    fi

    # Create a dry run first to check for conflicts
    echo "${BOLD}${YELLOW} ==>${RC} Checking for potential conflicts..."

    if ! stow -n .; then
        echo "${BOLD}${RED} ==>${RC} ${BOLD}Stow${RC} detected conflicts. Please check the output above."
        echo "${BOLD}${YELLOW} ==>${RC} You may need to manually resolve conflicts."
        exit 1
    fi

    # If dry run successful, perform actual stow
    echo "${BOLD}${YELLOW} ==>${RC} Creating symlinks..."

    if ! stow -t "$HOME" .; then
        echo "${BOLD}${RED} ==>${RC} Failed to create symlinks."
        exit 1
    fi

    # Verify critical files were linked
    if [ ! -L "$HOME/.zshrc" ]; then
        echo "${BOLD}${RED} ==>${RC} Failed to create ${BOLD}.zshrc${RC} symlink."
        exit 1
    fi

    # Change default shell to zsh for current user
    sudo chsh -s "$(which zsh)" "$USER"

    echo "${BOLD}${GREEN} ==>${RC} ZSH configuration setup completed successfully!"

    # Optionally source the new configuration
    if [ -f "$HOME/.zshrc" ]; then
        echo "${BOLD}${YELLOW} ==>${RC} Please execute ${BOLD}${GREEN}exec zsh${RC} and the installation will continue ..."
    fi
}

echo ""
echo ""
# Define and format output using printf to control line width (80 characters)
os_name=$(lsb_release -i | cut -f2-)
desc=$(lsb_release -d | cut -f2-)
version=$(lsb_release -r | cut -f2-)
codename=$(lsb_release -c | cut -f2-)

clear
cat <<'EOF'

 ╔═════════════════════════════════════════════════════════════════════════════╗
 ║                                                                             ║
 ║                                         /$$                                 ║
 ║                                        | $$                                 ║
 ║                     /$$$$$$$$  /$$$$$$$| $$$$$$$                            ║
 ║                    |____ /$$/ /$$_____/| $$__  $$                           ║
 ║                       /$$$$/ |  $$$$$$ | $$  \ $$                           ║
 ║                      /$$__/   \____  $$| $$  | $$                           ║
 ║                     /$$$$$$$$ /$$$$$$$/| $$  | $$                           ║
 ║                    |________/|_______/ |__/  |__/                           ║
 ║                                                                             ║
 ║                                                                             ║
 ║    From some basic information on your system, you appear to be running:    ║
 ║                                                                             ║  
EOF
printf " ║       --  ${BOLD}OS Name${RC}        : %-48s ║\n" "$os_name"
printf " ║       --  ${BOLD}Description${RC}    : %-48s ║\n" "$desc"
printf " ║       --  ${BOLD}OS Version${RC}     : %-48s ║\n" "$version"
printf " ║       --  ${BOLD}Code Name      : %-48s ║\n" "$codename"
cat <<'EOF'
 ║                                                                             ║
 ╚═════════════════════════════════════════════════════════════════════════════╝

EOF

##################################################################################
#####   Execute the functions in order
##################################################################################
checkEnv
installZsh
installDepend
installOhMyPosh
installFzf
installZoxide
installEza
setupZshConfig
