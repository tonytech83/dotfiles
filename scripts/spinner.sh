#!/usr/bin/env bash

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