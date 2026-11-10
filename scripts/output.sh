#!/bin/sh

##################################################################################
#####   Output helpers
##################################################################################
# Section header: ==> Title
print_step() {
    printf '\n%s==>%s %s%s%s\n' \
        "${BOLD}${BLUE}" "${RC}" "${BOLD}${ITALIC}${YELLOW}" "$1" "${RC}"
}

# Status line builders (==> message), no trailing newline
msg_ok() { printf '[%s%s] %s' "${BOLD}${GREEN}${SUCCESS}" "${RC}" "$1"; }

msg_install_ok() { 
    printf '[%s%s] %s%s%s - Successfully installed package.' \
    "${BOLD}${GREEN}${SUCCESS}" "${RC}" "${BOLD}${ITALIC}${MAGENTA}" "$1" "${RC}"
}

msg_install_err() {
    printf '[%s%s] Installation of %s%s%s could not be verified! Check %s for details.' \
    "${BOLD}${RED}${FAILED}" "${RC}" "${BOLD}${ITALIC}${MAGENTA}" "$1" "${RC}" "${BOLD}${LOG_FILE}${RC}"
}

msg_err() { printf '[%s%s] %s' "${BOLD}${RED}${FAILED}" "${RC}" "$1"; }

msg_warn() { printf '[%s%s] %s' "${BOLD}${YELLOW}${INFO}" "${RC}" "$1"; }

# "<tool> - Installation skipped is already present!"
msg_skip() {
    printf '[%s%s] %s%s%s - Installation skipped, package is already latest version!' \
        "${BOLD}${YELLOW}${INFO}" "${RC}" "${BOLD}${ITALIC}${MAGENTA}" "$1" "${RC}"
}