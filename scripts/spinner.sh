#!/bin/sh

# shellcheck disable=SC2034

##################################################################################
#####   Spinner
##################################################################################
# Braille patterns for the spinner (space-separated frames)
eight_dot_cell_pattern="⣾ ⢿ ⡿ ⣷ ⣯ ⢟ ⡻ ⣽"
six_dot_cell_pattern="⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏"

# Set the pattern
braille_spinner="$six_dot_cell_pattern"

# Duration of each spinner frame (in seconds)
frame_duration=0.2

spinner_pid=""

# Start the spinner in the background
start_spinner() {
    action_message=$1

    (
        while :; do
            for frame in $braille_spinner; do
                printf "\r[%s] %s" "$frame" "$action_message"
                sleep "$frame_duration"
            done
        done
    ) &
    spinner_pid=$!
}

# Stop the spinner and print the result messages
stop_spinner() {
    if [ -n "$spinner_pid" ]; then
        kill "$spinner_pid" 2>/dev/null
        wait "$spinner_pid" 2>/dev/null
        spinner_pid=""
    fi

    # Move to start of line and clear it
    printf "\r\033[K"

    for msg in "$@"; do
        if [ -n "$msg" ]; then
            printf "%b\n" "$msg"
        fi
    done
}

# Kill the spinner on exit, error, or Ctrl+C
cleanup_spinner() {
    if [ -n "$spinner_pid" ]; then
        kill "$spinner_pid" 2>/dev/null
        printf "\r\033[K"
    fi
}
trap cleanup_spinner EXIT
trap 'exit 130' INT
trap 'exit 143' TERM