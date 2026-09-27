#!/bin/sh

##################################################################################
#####   Fetch the canonical list of Nerd Font names (= release asset names)
##################################################################################
get_font_list() {
    json=$(curl -fsSL "$FONTS_JSON_URL") || {
        printf "Failed to fetch font list from %s\n" "$FONTS_JSON_URL" | tee -a "$LOG_FILE" >&2
        return 1
    }

    if command -v python3 >/dev/null 2>&1; then
        printf '%s' "$json" | python3 -c '
import json, sys
data = json.load(sys.stdin)
print("\n".join(sorted(f["folderName"] for f in data["fonts"])))
'
    elif command -v jq >/dev/null 2>&1; then
        printf '%s' "$json" | jq -r '.fonts[].folderName' | sort
    else
        printf "Need python3 or jq installed to parse the font list\n" | tee -a "$LOG_FILE" >&2
        return 1
    fi
}

# True if directory $1 directly contains a .ttf/.otf file (any case)
has_font_files() {
    for f in "$1"/*; do
        case "$f" in
            *.[tT][tT][fF]|*.[oO][tT][fF]) [ -f "$f" ] && return 0 ;;
        esac
    done
    return 1
}

##################################################################################
#####   Function to install Nerd font
##################################################################################
install_nerd_font() {
    print_step "Install Nerd font"

    # Ask for Nerd font at all
    while true; do
        printf "Do you want Nerd font [Y/n] "
        read -r need_nerd_font || { echo; return 0; }   # EOF -> skip
        case "$need_nerd_font" in
            ''|[Yy]*) break ;;
            [Nn]*)
                printf "Skipping font installation.\n" | tee -a "$LOG_FILE"
                return 0
                ;;
            *) echo "Please answer y or n." ;;
        esac
    done

    # Menu is interactive, so it happens before the spinner starts.
    fonts=$(get_font_list)
    total=$(printf '%s\n' "$fonts" | grep -c .)

    if [ "$total" -eq 0 ]; then
        printf "No fonts available - continuing without font installation.\n" | tee -a "$LOG_FILE"
        return 0
    fi

    # Print menu
    echo
    cols=3
    col_width=26
    i=0
    printf "%3d) %s%-${col_width}s%s" 0 "${BOLD}${GREEN}" "Skip installation" "${RC}"
    while IFS= read -r font; do
        i=$((i + 1))
        if [ $((i % cols)) -eq 0 ]; then echo; fi
        printf "%3d) %-${col_width}s" "$i" "$font"
    done <<EOF
$fonts
EOF
    printf "\n"

    while true; do
        printf "Select font: "
        read -r choice || { echo; return 0; }
        case "$choice" in
            ''|*[!0-9]*) ;;
            *) [ "$choice" -le "$total" ] && break ;;
        esac
        printf "Invalid choice, try again.\n"
    done

    if [ "$choice" -eq 0 ]; then
        printf "Skipping font installation.\n" | tee -a "$LOG_FILE"
        return 0
    fi

    font_family=$(printf '%s\n' "$fonts" | sed -n "${choice}p")

    start_spinner "Installing..."

    {
        printf "\n#####   Function to install Nerd font   #####\n"

        message=""
        font_dir="$FONT_INSTALL_ROOT/${font_family}NerdFont"

        # Already installed? (checked by font files, not fc-list name,
        # since the internal family name doesn't always match)
        if has_font_files "$font_dir"; then
            message="$(msg_skip "$font_family")"
        elif ! tmp_dir=$(mktemp -d); then
            message="$(msg_err "Could not create a temporary directory!")"
        else
            archive="$tmp_dir/${font_family}.zip"
            url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font_family}.zip"

            if ! curl -fsSL "$url" -o "$archive"; then
                message="$(msg_err "Failed to download ${BOLD}$font_family${RC}! Check ${BOLD}${LOG_FILE}${RC} for details.")"
            else
                mkdir -p "$tmp_dir/unpacked" "$font_dir"
                if ! unzip -qq -o "$archive" -d "$tmp_dir/unpacked"; then
                    message="$(msg_err "Failed to extract ${BOLD}$font_family${RC}! Check ${BOLD}${LOG_FILE}${RC} for details.")"
                else
                    find "$tmp_dir/unpacked" -type f \
                        \( -name '*.[tT][tT][fF]' -o -name '*.[oO][tT][fF]' \) \
                        -exec cp {} "$font_dir/" \;

                    if ! has_font_files "$font_dir"; then
                        message="$(msg_err "No font files found for ${BOLD}$font_family${RC}!")"
                    else
                        fc-cache -f "$font_dir" >/dev/null 2>&1
                        message="$(msg_ok "Font ${BOLD}${ITALIC}${MAGENTA}$font_family${RC} installed.")"
                    fi
                fi
            fi

            rm -rf "$tmp_dir"
        fi
    } >> "${LOG_FILE:-/dev/null}" 2>&1

    stop_spinner "$message" | tee -a "$LOG_FILE"
}