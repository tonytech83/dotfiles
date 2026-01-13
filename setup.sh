#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2086

# Global fixed width (inside the box)
BOX_WIDTH=76

# Define color codes for output
RC="$(printf '\033[0m')"
RED="$(printf '\033[31m')"
YELLOW="$(printf '\033[33m')"
GREEN="$(printf '\033[32m')"
BLUE="$(printf '\033[34m')"
MAGENTA="$(printf '\033[35m')"
CYAN="$(printf '\033[36m')"

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
LOG_FILE="installation.log"

##################################################################################
#####   Log file
##################################################################################
startLog() {
    > "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    echo "=== Setup started at $(date) ===" >> "$LOG_FILE"
}

endLog() {
    echo "=== Setup completed at $(date) ===" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
}

##################################################################################
#####   Spinner
##################################################################################
# Define an array of Braille patterns for a spinner
eight_dot_cell_pattern=("⣾" "⢿" "⡿" "⣷" "⣯" "⢟" "⡻" "⣽")
six_dot_cell_pattern=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")

# Set the pattern
braille_spinner=("${six_dot_cell_pattern[@]}")

# Set the duration for each spinner frame (in seconds)
frame_duration=0.2

# Function to start the spinner in the background
start_spinner() {
    action_message=$1

    (
        idx=0
        while :; do
            printf "\r%s" "${braille_spinner[idx]} $action_message"
            idx=$(( (idx + 1) % ${#braille_spinner[@]} ))
            sleep "$frame_duration"
        done
    ) &
    spinner_pid=$!
    disown
}

# Function to stop the spinner with U+2800
stop_spinner() {
    kill -9 "$spinner_pid" 2>/dev/null  # Stop the spinner loop
    wait "$spinner_pid" 2>/dev/null

    printf "\n"

    # Process all arguments
    for msg in "$@"; do
        [[ -n "$msg" ]] && printf "%b\n" "$msg"
    done

    printf "\n"
}

##################################################################################
#####   Function to check if a command exists
##################################################################################
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

##################################################################################
#####   Function to authenticate sudo early
##################################################################################
authenticateSudo() {
    # Only prompt for sudo if we need it and it's available
    if [ -n "$SUDO_CMD" ] && [ "$SUDO_CMD" = "sudo" ]; then
        printf "${BOLD}${BLUE}==>${RC} ${BOLD}${ITALIC}${YELLOW}Authenticating sudo access${RC}\n"
        
        # This will prompt for password if needed and cache credentials
        if ! ${SUDO_CMD} -v; then
            printf "${BOLD}${RED}==>${RC} Failed to authenticate sudo access\n"
            exit 1
        fi
        
        printf "${BOLD}${GREEN}==>${RC} Sudo authentication successful!\n\n"
        
        # Keep sudo alive in background (optional - refreshes every 60 seconds)
        # This prevents timeout during long operations
        while true; do
            ${SUDO_CMD} -n true
            sleep 60
            kill -0 "$$" || exit
        done 2>/dev/null &
    fi
}

##################################################################################
#####   Function to check the environment for necessary tools and permissions
##################################################################################
checkEnv() {

    printf "${BOLD}${BLUE}==>${RC} ${BOLD}${ITALIC}${YELLOW}Check the environment for necessary tools and permissions${RC}\n"
    start_spinner "Checking..."

    {
        local req_message
        local pm_message
        local priv_message

        # Check for required commands
        REQUIREMENTS="curl sudo"
        for req in $REQUIREMENTS; do
            if ! command_exists "$req"; then
                req_message="${BOLD}${RED}==>${RC} Missing required command: $req"
                exit 1
            fi
        done

        # Determine the package manager to use
        PACKAGEMANAGER="apt-get dnf yum pacman zypper apk"
        for pgm in $PACKAGEMANAGER; do
            if command_exists "$pgm"; then
                PACKAGER="$pgm"
                pm_message="${BOLD}${GREEN}==>${RC} Using ${BOLD}${ITALIC}${MAGENTA}$pgm${RC} for package manager."
                break
            fi
        done

        if [ -z "$PACKAGER" ]; then
            pm_message="${BOLD}${RED}==>${RC} No supported package manager found."
            exit 1
        fi

        # Determine privilege escalation method
        if [ "$(id -u)" -eq 0 ]; then
            # Running as root
            SUDO_CMD=""
            priv_message="${BOLD}${GREEN}==>${RC} Running as root, sudo is not needed."
        elif command_exists sudo; then
            SUDO_CMD="sudo"
            priv_message="${BOLD}${GREEN}==>${RC} Using ${BOLD}${ITALIC}${MAGENTA}sudo${RC} for privilege escalation."
        elif command_exists doas && [ -f "/etc/doas.conf" ]; then
            SUDO_CMD="doas"
            priv_message="${BOLD}${GREEN}==>${RC} Using doas for privilege escalation."
        else
            priv_message="${BOLD}${RED}==>${RC} No suitable privilege escalation tool found (sudo/doas)."
            exit 1
        fi
    } >> "$LOG_FILE" 2>&1

    stop_spinner "$req_message" "$pm_message" "$priv_message"
}

##################################################################################
#####   Function to update system packages
##################################################################################
updateSystem() {

    printf "${BOLD}${BLUE}==>${RC} ${BOLD}${ITALIC}${YELLOW}Update system packages${RC}\n"
    start_spinner "Updating..."

    # Redirect all output to log file
    {
        local message

        case "$PACKAGER" in
            pacman)
                ${SUDO_CMD} "$PACKAGER" -Sy
                ;;
            apt-get)
                ${SUDO_CMD} "$PACKAGER" update
                ;;
            dnf)
                ${SUDO_CMD} "$PACKAGER" update -y
                ;;
            zypper)
                ${SUDO_CMD} "$PACKAGER" ref
                ;;
            apk)
                ${SUDO_CMD} "$PACKAGER" update
                ;;
            *)
                message="${BOLD}${RED}=>${RC} Unsupported package manager"
                exit 1
                ;;
        esac
    } >> "$LOG_FILE" 2>&1

    message="${BOLD}${GREEN}==>${RC} System packages updated!${RC}"

    stop_spinner "$message"
}

##################################################################################
#####   Function to install dependencies
##################################################################################
installDepend() {
    # List of dependencies to install (space-separated, not quoted)
    DEPENDENCIES="stow curl tree wget unzip fontconfig ca-certificates"

    printf "${BOLD}${BLUE}==>${RC} ${BOLD}${ITALIC}${YELLOW}Install dependencies${RC}\n"
    start_spinner "Installing..."

    {
        local aur_message
        local message

        case "$PACKAGER" in
        pacman)
            # Install AUR helper if not present
            if ! command_exists yay && ! command_exists paru; then
                ${SUDO_CMD} "${PACKAGER}" --noconfirm -S base-devel
                cd /opt && ${SUDO_CMD} git clone https://aur.archlinux.org/yay-git.git && ${SUDO_CMD} chown -R "${USER}:${USER}" ./yay-git
                cd yay-git && makepkg --noconfirm -si
                aur_message="${BOLD}${GREEN}==>${RC} AUR helper installed!"
            else
                aur_message="${BOLD}${GREEN}==>${RC} AUR helper is already installed!"
            fi

            # Determine which AUR helper to use
            if command_exists yay; then
                AUR_HELPER="yay"
            elif command_exists paru; then
                AUR_HELPER="paru"
            else
                aur_message="${BOLD}${RED}==>${RC} No AUR helper found. Please install ${BOLD}yay${RC} or ${BOLD}paru${RC}."
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
    } >> "$LOG_FILE" 2>&1

    message="${BOLD}${GREEN}==>${RC} Dependencies installed!${RC}"

    stop_spinner "$aur_message" "$message"
}

##################################################################################
#####   Function to install zsh
##################################################################################
installZsh() {

    printf "${BOLD}${BLUE}==>${RC} ${BOLD}${ITALIC}${YELLOW}Install zsh${RC}\n"
    start_spinner "Installing..."

    {
        local message
        if ! command_exists zsh; then
            case "$PACKAGER" in
            pacman)
                ${SUDO_CMD} "$PACKAGER" -S --needed --noconfirm zsh
                ;;
            apk)
                ${SUDO_CMD} "$PACKAGER" add zsh
                ;;
            *)
                ${SUDO_CMD} "$PACKAGER" install -y zsh
                ;;
            esac
            message="${BOLD}${GREEN}==>${RC} Successfully installed ${BOLD}zsh${RC}."
        else
            message="${BOLD}${GREEN}==>${RC} Installation skipped - ${BOLD}${ITALIC}${MAGENTA}zsh${RC} is already present!"
        fi
    } >> "$LOG_FILE" 2>&1

    stop_spinner "$message"
}

##################################################################################
##### Function to install oh-my-posh
##################################################################################
installOhMyPosh() {

    printf "${BOLD}${BLUE}==>${RC} ${BOLD}${ITALIC}${YELLOW}Install oh-my-posh${RC}\n"
    start_spinner "Installing..."

    {
        local mkdir_message
        local mkdir_confirm
        local message

        if command_exists oh-my-posh; then
            # message="${BOLD}${GREEN}==>${RC} ${BOLD}oh-my-posh${RC} is already installed!"
            message="${BOLD}${GREEN}==>${RC} Installation skipped - ${BOLD}${ITALIC}${MAGENTA}oh-my-posh${RC} is already present!"
        fi

        # Check if the ./local/bin exists
        LOCALBINFOLDER="$HOME/.local/bin"
        if [ ! -d "$LOCALBINFOLDER" ]; then
            mkdir_message="${BOLD}${YELLOW}==>${RC} Creating directory: $LOCALBINFOLDER"
            mkdir -p "$LOCALBINFOLDER"
            mkdir_confirm="${BOLD}${GREEN}==>${RC} Directory created: $LOCALBINFOLDER"
        fi

        # Install Oh My Posh
        if curl -sS https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin; then
            massage="${BOLD}${GREEN} ==>${RC} Successfully installed ${BOLD}oh-my-posh${RC}!"
        else
            message="${BOLD}${RED}==>${RC} Something went wrong during ${BOLD}oh-my-posh${RC} install!"
            exit 1
        fi
    } >> "$LOG_FILE" 2>&1

    stop_spinner "$mkdir_message" "$mkdir_confirm" "$message"
}

##################################################################################
#####   Function to install fzf
##################################################################################
installFzf() {

    printf "${BOLD}${BLUE}==>${RC} ${BOLD}${ITALIC}${YELLOW}Install fzf${RC}\n"
    start_spinner "Installing..."

    {
        local clone_messsage
        local message

        if command_exists fzf || [ -d "$HOME/.fzf" ]; then
            message="${BOLD}${GREEN}==>${RC} Installation skipped - ${BOLD}${ITALIC}${MAGENTA}fzf${RC} is already present!"
        else
            SUDO_CMD "${PACKAGER}" install -y fzf 2>/dev/null || {
                clone_messsage="${BOLD}${YELLOW}==>${RC} ${BOLD}fzf${RC} not available in package manager. Cloning from GitHub..."
                git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
                ~/.fzf/install --all # non-interactive, auto “yes” to everything
            }
            message="${BOLD}${GREEN}==>${RC} Successfully installed ${BOLD}fzf${RC}."
        fi
    } >> "$LOG_FILE" 2>&1

    stop_spinner "$clone_messsage" "$message"
}

##################################################################################
#####   Function to install eza
##################################################################################
installEza() {

    printf "${BOLD}${BLUE}==>${RC} ${BOLD}${ITALIC}${YELLOW}Install eza${RC}\n"
    start_spinner "Installing..."

    {
        local message
        if ! command_exists eza; then
            cd /tmp || exit
            wget -c https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz -O - | tar xz
            ${SUDO_CMD} chmod +x eza
            ${SUDO_CMD} chown root:root eza
            ${SUDO_CMD} mv eza /usr/local/bin/eza
            message="${BOLD}${GREEN}==> ${RC} Successfully installed ${BOLD}eza${RC}."
        else
            # message="${BOLD}${GREEN}==>${RC} ${BOLD}eza${RC} is already installed."
            message="${BOLD}${GREEN}==>${RC} Installation skipped - ${BOLD}${ITALIC}${MAGENTA}eza${RC} is already present!"
        fi
    } >> "$LOG_FILE" 2>&1

    stop_spinner "$message"
}

##################################################################################
##### Function to setup zsh configuration
##################################################################################
setupZshConfig() {

    printf "${BOLD}${BLUE}==>${RC} ${BOLD}${ITALIC}${YELLOW}Setup zsh configuration${RC}\n"
    start_spinner "Configuring...${RC}"

    {
        local message
        local continue_message
        local err_message
        local success_message

        # Clone dotfiles repo
        cd "$DOTFILES_DIR" || {
            err_message="${BOLD}${RED}==>${RC} Dotfiles directory '$DOTFILES_DIR' not found"
            exit 1
        }

        # Check if stow is available
        if ! command_exists stow; then
            err_message="${BOLD}${RED}==>${RC} ${BOLD}Stow${RC} is not installed. Please install it first."
            exit 1
        fi

        # Check if ~/.zshrc exists if backup it
        if [ -f "$HOME/.zshrc" ]; then
            mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
            message="${GREEN}zsh configuration file backup in ~/.zshrc.bak${RC}"
        fi

        # Check if ~/.nanorc exists
        if [ -f "$HOME/.nanorc" ]; then
            mv "$HOME/.nanorc" "$HOME/.nanorc.bak"
            message="${GREEN}nano configuration file backup in ~/.nanorc.bak${RC}"
        fi

        # Create a dry run first to check for conflicts
        message="${BOLD}${YELLOW}==>${RC} Checking for potential conflicts..."

        if ! stow -n .; then
            err_message="${BOLD}${RED}==>${RC} ${BOLD}Stow${RC} detected conflicts. You may need to manually resolve conflicts."
            exit 1
        fi

        # If dry run successful, perform actual stow
        message="${BOLD}${YELLOW}==>${RC} Creating symlinks..."

        if ! stow -t "$HOME" .; then
            err_message="${BOLD}${RED}==>${RC} Failed to create symlinks."
            exit 1
        fi

        # Verify critical files were linked
        if [ ! -L "$HOME/.zshrc" ]; then
            err_message="${BOLD}${RED}==>${RC} Failed to create ${BOLD}.zshrc${RC} symlink."
            exit 1
        fi

        # Change default shell to zsh for current user
        sudo chsh -s "$(which zsh)" "$USER"

        success_message="${BOLD}${GREEN}==>${RC} Configuration of ${BOLD}${ITALIC}${MAGENTA}zsh${RC} setup completed successfully!"

        # Optionally source the new configuration
        if [ -f "$HOME/.zshrc" ]; then
            continue_message="${BOLD}${GREEN}==>${RC} Please execute ${BOLD}${ITALIC}${MAGENTA}exec zsh${RC} and the installation will continue ..."
        fi

    } >> "$LOG_FILE" 2>&1

    stop_spinner "$err_message" "$success_message" "$continue_message"
}

head() {
    echo ""
    echo ""

    # Define and format output using printf to control line width (80 characters)
    os_name=$(lsb_release -i | cut -f2-)
    desc=$(lsb_release -d | cut -f2-)
    version=$(lsb_release -r | cut -f2-)
    codename=$(lsb_release -c | cut -f2-)

    clear
    
    cat << EOF
                     /\$\$            
                    | \$\$            
 /\$\$\$\$\$\$\$\$  /\$\$\$\$\$\$\$| \$\$\$\$\$\$       
|____ /\$\$/ /\$\$_____/| \$\$__  \$\$      ${BOLD}${ITALIC}${YELLOW}OS Name${RC}     : $os_name      
   /\$\$\$\$/ |  \$\$\$\$\$\$ | \$\$  \ \$\$      ${BOLD}${ITALIC}${YELLOW}Description${RC} : $desc
  /\$\$__/   \____  \$\$| \$\$  | \$\$      ${BOLD}${ITALIC}${YELLOW}OS Version${RC}  : $version
 /\$\$\$\$\$\$\$\$ /\$\$\$\$\$\$\$/| \$\$  | \$\$      ${BOLD}${ITALIC}${YELLOW}Code Name${RC}   : $codename
|________/|_______/ |__/  |__/      
EOF
    echo ""
    echo ""
}


##################################################################################
#####   Execute the functions in order
##################################################################################
head
startLog
checkEnv
authenticateSudo
updateSystem
installDepend
installZsh
installOhMyPosh
installFzf
installEza
setupZshConfig
endLog