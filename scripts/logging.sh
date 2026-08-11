#!/usr/bin/env bash

##################################################################################
#####   Log file
##################################################################################
start_log() {
    true > "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    echo "=== Setup started at $(date) ===" >> "$LOG_FILE"
}

end_log() {
    echo "=== Setup completed at $(date) ===" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
}