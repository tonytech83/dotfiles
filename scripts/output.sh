#!/usr/bin/env bash

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