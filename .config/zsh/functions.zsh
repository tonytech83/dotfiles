# Define color codes for output
RC="$(printf '\033[0m')"
RED="$(printf '\033[31m')"
YELLOW="$(printf '\033[33m')"
GREEN="$(printf '\033[32m')"
BLUE="$(printf '\033[34m')"
MAGENTA="$(printf '\033[35m')"
CYAN="$(printf '\033[36m')"
BOLD="$(printf '\033[1m')"

# Initialize variables
PACKAGER=""
PACKAGEMANAGER=(apt-get dnf yum pacman zypper apk)

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

checkEnv(){
    for pgm in $PACKAGEMANAGER; do
        if command_exists "$pgm"; then
            PACKAGER="$pgm"
        #    printf 'Using %s%s%s for package manager.\n' "${BOLD}${GREEN}" "$PACKAGER" "${RC}"
            break
        fi
    done

    if [ -z "$PACKAGER" ]; then
        printf "%s%s%s No supported package manager found.\n" "${BOLD}${RED}" "✗" "${RC}"
        exit 1
    fi  
}

upgrade() {
    case "$PACKAGER" in
        pacman)
            sudo "$PACKAGER" -Syu
            ;;
        apt-get)
            sudo "$PACKAGER" update && "$PACKAGER" upgrade -y
            ;;
        dnf|yum)
            sudo "$PACKAGER" update -y
            ;;
        zypper)
            sudo "$PACKAGER" --non-interactive refresh && "$PACKAGER" --non-interactive update 
            ;;
        apk)
            sudo "$PACKAGER" update && sudo "$PACKAGER" upgrade
            ;;
        *)
            unsupported=1
            ;;
    esac

    if [ "$unsupported" -eq 1 ]; then
        printf "%s%s%s Unsupported package manager: %s\n" "${BOLD}${RED}" "✗" "${RC}" "$PACKAGER"
        exit 1
    fi

    printf "%s%s%s System updated successfully.\n" "${BOLD}${GREEN}" "✓" "${RC}"
}

checkEnv
