#!/bin/sh

# Global fixed width (inside the box)
BOX_WIDTH=76

# Define color codes for output
RC="$(printf '\033[0m')"
RED="$(printf '\033[31m')"
YELLOW="$(printf '\033[33m')"
GREEN="$(printf '\033[32m')"

# Initialize variables for package manager, sudo command, superuser group, and git path
PACKAGER=""
PACKAGEMANAGER=""
SUDO_CMD=""
REQUIREMENTS=""
DEPENDENCIES=""

print_action() {
    content="$1"
    width=${BOX_WIDTH:-76}
    stripped_content=$(printf "%s" "$content" | sed 's/\x1B\[[0-9;]*[a-zA-Z]//g') # strip ANSI
    content_length=$(printf "%s" "$stripped_content" | wc -c)
    inner_width=$((width - 2))  # 1 space before + 1 after
    padding=$((inner_width - content_length))
    if [ "$padding" -lt 0 ]; then
        content=$(printf "%s" "$content" | cut -c1-$inner_width)
        padding=0
    fi

    echo ""
    printf "═╬"
    printf '═%.0s' $(seq 1 "$width")
    printf "╬═\n"
    printf " ║ %s%*s ║\n" "$content" "$padding" ""
    printf "═╬"
    printf '═%.0s' $(seq 1 "$width")
    printf "╬═\n"
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

    print_action "${YELLOW}Check the environment for necessary tools and permissions${RC}"

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
            echo "Using ${GREEN}$pgm${RC} for package manager."
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
        echo "Using ${GREEN}sudo${RC} for privilege escalation."
    elif command_exists doas && [ -f "/etc/doas.conf" ]; then
        SUDO_CMD="doas"
        echo "Using ${GREEN}doas${RC} for privilege escalation."
    else
        echo "${RED}No suitable privilege escalation tool found (sudo/doas).${RC}"
        exit 1
    fi
}

##################################################################################
#####   Function to install dependencies
##################################################################################
installDepend() {
    # List of dependencies to install (space-separated, not quoted)
    DEPENDENCIES="stow lsd curl tree wget unzip fontconfig ca-certificates"

    print_action "${YELLOW}Installing dependencies...${RC}" 

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
        "${AUR_HELPER}" --noconfirm -S ${DEPENDENCIES}

    elif [ "$PACKAGER" = "dnf" ]; then
        ${SUDO_CMD} "${PACKAGER}" install -y ${DEPENDENCIES}
    elif [ "$PACKAGER" = "zypper" ]; then
        ${SUDO_CMD} "${PACKAGER}" install -y ${DEPENDENCIES}
    else
        ${SUDO_CMD} "${PACKAGER}" install -yq ${DEPENDENCIES}
    fi
}

##################################################################################
#####   Function to install zsh
##################################################################################
installZsh() {

    print_action "${YELLOW}Installing ZSH${RC}" 

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
        echo "${GREEN}  ==> Successfully installed ZSH.${RC}"
    else
        printf "%b\n" "${GREEN}  ==> ZSH is already installed.${RC}"
    fi
}

##################################################################################
#####   Function to install fzf
##################################################################################
installFzf() {

    print_action "${YELLOW}Installing FZF${RC}" 

    if command_exists fzf || [ -d "$HOME/.fzf" ]; then
        echo "${GREEN}Fzf already installed${RC}"
    else
        echo "${YELLOW}Installing Fzf...${RC}"
        ${SUDO_CMD} "${PACKAGER}" install -y fzf 2>/dev/null || {
            echo "${YELLOW}Fzf not available in package manager. Cloning from GitHub...${RC}"
            git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
            ~/.fzf/install
        }
        echo "${GREEN}  ==> Successfully installed FZF.${RC}"
    fi
}

##################################################################################
#####   Function to install Zoxide
##################################################################################
installZoxide() {

    print_action "${YELLOW}Installing ZOXIDE${RC}" 

    if command_exists zoxide; then
        echo "${GREEN}  --> Zoxide already installed${RC}"
        return
    fi

    # Install Zoxide
    if curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh; then
        echo "${GREEN}  ==> Successfully installed zoxide${RC}"
    else
        echo "${RED}Something went wrong during zoxide install!${RC}"
        exit 1
    fi
}

##################################################################################
##### Function to install Oh My Posh
##################################################################################
installOhMyPosh() {

    print_action "${YELLOW}Installing Oh My Posh${RC}" 


    if command_exists oh-my-posh; then
        echo "${GREEN}Oh My Posh already installed${RC}"
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
    if curl -sS https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin; then
        echo "${GREEN}  ==> Successfully installed Oh My Posh${RC}"
    else
        echo "${RED}Something went wrong during Oh My Posh install!${RC}"
        exit 1
    fi
}

setupZshConfig() {

    print_action "${YELLOW}Setup ZSH configuration...${RC}"

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
        echo "${YELLOW}Please execute 'exec zsh'! The installation will continue ...${RC}"
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
cat << 'EOF'

═╬═════════════════════════════════════════════════════════════════════════════╬═
 ║                                                                             ║
 ║                                        /$$                                  ║
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
EOF
printf " ║       --  OS Name        : %-48s ║\n" "$os_name"
printf " ║       --  Description    : %-48s ║\n" "$desc"
printf " ║       --  OS Version     : %-48s ║\n" "$version"
printf " ║       --  Code Name      : %-48s ║\n" "$codename"
cat << 'EOF'
 ║                                                                             ║
═╬═════════════════════════════════════════════════════════════════════════════╬═

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
setupZshConfig
