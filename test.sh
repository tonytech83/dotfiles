#!/usr/bin/env bash

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
UNDERLINE="$(printf '\033[4m')"
BLINK="$(printf '\033[5m')"
REVERSE="$(printf '\033[7m')"
HIDDEN="$(printf '\033[8m')"
STRIKE="$(printf '\033[9m')"

LOG_FILE="test_installation.log"

SUCCESS="󰸞"
FAILED=""
WARNING=""

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
            printf "\r[%s] %s" "${braille_spinner[idx]}" "$action_message"
            idx=$(( (idx + 1) % ${#braille_spinner[@]} ))
            sleep "$frame_duration"
        done
    ) &
    spinner_pid=$!
    disown
}

stop_spinner() {
    kill -9 "$spinner_pid" 2>/dev/null
    wait "$spinner_pid" 2>/dev/null

    # Move to start of line and clear it, instead of just moving to a new line
    printf "\r\033[K"

    # Process all arguments
    for msg in "$@"; do
        [[ -n "$msg" ]] && printf "%b\n" "$msg"
    done

    printf "\n"
}

##################################################################################
#####   Testing
##################################################################################
testing() {

    print_step "Doing test"
    start_spinner "Testing..."

    {
        local message

        sleep 5

        message="$(msg_ok "Successfully finished current ${BOLD}test${RC}.")"
    } >> "$LOG_FILE" 2>&1

    stop_spinner "$message"
}

testing
