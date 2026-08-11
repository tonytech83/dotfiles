#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2086,SC1091

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

SUCCESS="󰸞"
FAILED=""
WARNING=""

# Initialize variables for package manager, sudo command, superuser group, and git path
PACKAGER=""
PACKAGEMANAGER=""
SUDO_CMD=""
REQUIREMENTS=""
DEPENDENCIES=""
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
LOG_FILE="installation.log"

trap 'kill -9 "$spinner_pid" 2>/dev/null; printf "\n"' EXIT

# Load external functions if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for f in "$SCRIPT_DIR"/scripts/*.sh; do
    source "$f"
done

##################################################################################
#####   Output helpers
##################################################################################
# Section header: ==> Title
print_step() {
    printf '%s==>%s %s%s%s\n' \
        "${BOLD}${BLUE}" "${RC}" "${BOLD}${ITALIC}${YELLOW}" "$1" "${RC}"
}

# Status line builders (==> message), no trailing newline
msg_ok()   { printf '[%s%s] %s' "${BOLD}${GREEN}${SUCCESS}"  "${RC}" "$1"; }
msg_err()  { printf '[%s%s] %s' "${BOLD}${RED}${FAILED}"    "${RC}" "$1"; }
msg_warn() { printf '[%s%s] %s' "${BOLD}${YELLOW}${WARNING}" "${RC}" "$1"; }

# "Installation skipped - <tool> is already present!"
msg_skip() {
    printf '[%s%s] Installation skipped - %s%s%s is already present!' \
        "${BOLD}${GREEN}${SUCCESS}" "${RC}" "${BOLD}${ITALIC}${MAGENTA}" "$1" "${RC}"
}

##################################################################################
#####   Function to check if a command exists
##################################################################################
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

##################################################################################
#####   Function to verify a tool is available after installing
##################################################################################
verify_installed() {
    PATH="$HOME/.local/bin:/usr/local/bin:$PATH" command -v "$1" >/dev/null 2>&1
}

##################################################################################
##### Head
##################################################################################
head() {
    echo ""
    echo ""

    # Define and format output using printf to control line width (80 characters)
    if [ -f /etc/os-release ]; then
        # shellcheck source=/dev/null
        . /etc/os-release
        os_name="${ID^}"          # e.g. "Ubuntu" or "Debian"
        desc="${PRETTY_NAME}"     # e.g. "Debian GNU/Linux 12 (bookworm)"
        version="${VERSION_ID}"   # e.g. "12"
        codename="${VERSION_CODENAME}" # e.g. "bookworm"
    else
        os_name="Unknown"
        desc="Unknown"
        version="Unknown"
        codename="Unknown"
    fi

    [ -t 1 ] && clear

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
start_log
check_env
auth_sudo
update_system
install_deps
install_zsh
conf_zsh_env
install_ohmyposh
install_fzf
install_eza
install_fd
install_zoxide
setup_zsh_conf
end_log
