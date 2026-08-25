#!/usr/bin/env bash

##################################################################################
#####   Function to authenticate sudo early
##################################################################################

install_nerd_font() {

	print_step "Install Nerd font"
    start_spinner "Installing..."

    {
        local message

        if fc-list 2>/dev/null | grep -qi "$NERD_FONT_FAMILY"; then
            message="$(msg_skip "$NERD_FONT_FAMILY")"
        else
            font_temp_dir=$(mktemp -d)
            font_archive="$font_temp_dir/JetBrainsMono.tar.xz"
            font_unpack_dir="$font_temp_dir/unpacked"
            font_dir="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
            mkdir -p "$font_unpack_dir" "$font_dir"

            if ! curl -fsSL "$NERD_FONT_URL" -o "$font_archive"; then
                rm -rf "$font_temp_dir"
                message="$(msg_err "Failed to download ${BOLD}$NERD_FONT_FAMILY${RC}! Check ${BOLD}${LOG_FILE}${RC} for details.")"
            fi
            if ! tar -xJf "$font_archive" -C "$font_unpack_dir"; then
                rm -rf "$font_temp_dir"
                message="$(msg_err "Failed to extract ${BOLD}$NERD_FONT_FAMILY${RC}! Check ${BOLD}${LOG_FILE}${RC} for details.")"
            fi

            find "$font_unpack_dir" -type f -name 'JetBrainsMonoNerdFont-*.ttf' -exec cp {} "$font_dir"/ \;
            font_found=
            for font_file in "$font_dir"/*.ttf; do
                if [ -f "$font_file" ]; then
                    font_found=1
                    break
                fi
            done
            rm -rf "$font_temp_dir"

            if [ -z "$font_found" ]; then
                message="$(msg_err "No standard JetBrainsMono Nerd Font files were found in the archive.")"
            fi

            fc-cache -f >/dev/null 2>&1
            message="$(msg_ok "$NERD_FONT_FAMILY installed.")"
        fi
    } >> "$LOG_FILE" 2>&1

    stop_spinner "$message"
}