#!/usr/bin/env bash

##################################################################################
#####   Fetch the canonical list of Nerd Font names (= release asset names)
##################################################################################
get_font_list() {
    local json
    json=$(curl -fsSL "$FONTS_JSON_URL") || {
        printf "Failed to fetch font list from %s\n" "$FONTS_JSON_URL" | tee -a "$LOG_FILE" >&2
        exit 0
    }

    if command -v python3 >/dev/null 2>&1; then
        printf '%s' "$json" | python3 -c '
import json, sys
data = json.load(sys.stdin)
names = sorted(f["folderName"] for f in data["fonts"])
print("\n".join(names))
'
    elif command -v jq >/dev/null 2>&1; then
        printf '%s' "$json" | jq -r '.fonts[].folderName' | sort
    else
        printf "Need python3 or jq installed to parse the font list\n" | tee -a "$LOG_FILE" >&2
        exit 0
    fi
}

##################################################################################
#####   Function to install Nerd font
##################################################################################
install_nerd_font() {
 
    print_step "Install Nerd font"

    # Ask for Nerd font at all
    local need_nerd_font
    while true; do
        read -rp "Do you want Nerd font [Y/n] " need_nerd_font
        case "$need_nerd_font" in
            [Yy]*) break ;;
            [Nn]*)
                printf "Skipping font installation.\n" | tee -a "$LOG_FILE"
                echo
                return 0
                ;;
            *) echo "Please answer y or n." ;;
        esac
    done
 
    # Menu is interactive, so it happens before the spinner starts.
    mapfile -t fonts < <(get_font_list)

    # Check if fonts list is populated
    if [ "${#fonts[@]}" -eq 0 ]; then
        printf "No fonts available - continuing without font installation.\n" | tee -a "$LOG_FILE"
        return 0
    fi
    
    # Print menu
    echo
    local cols=3
    local col_width=26
    local total=${#fonts[@]}
    local total_items=$((total + 1))
    for ((i = 0; i < total_items; i++)); do
        if (( i == 0 )); then
            local skip_label="Skip installation"
            local skip_pad=$(( col_width - ${#skip_label} ))
            (( skip_pad < 0 )) && skip_pad=0
            printf "%3d) %s%s%s%*s" 0 "${BOLD}${GREEN}" "$skip_label" "${RC}" "$skip_pad" ""
        else
            printf "%3d) %-*s" "$i" "$col_width" "${fonts[$((i - 1))]}"
        fi
        if (( (i + 1) % cols == 0 )); then
            echo
        fi
    done
    if (( total_items % cols != 0 )); then
        echo
    fi
    echo
 
    local choice
    while true; do
        read -rp "Select font: " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 0 ] && [ "$choice" -le "$total" ]; then
            break
        fi
        printf "Invalid choice, try again."
    done
 
    if [ "$choice" -eq 0 ]; then
        printf "Skipping font installation.\n" | tee -a "$LOG_FILE"
        echo
        return 0
    fi
 
    local NERD_FONT_FAMILY="${fonts[$((choice - 1))]}"
 
    start_spinner "Installing..."
 
    {
        printf "\n#####   Function to install Nerd font   #####\n"
 
        local message
        local font_dir="$FONT_INSTALL_ROOT/${NERD_FONT_FAMILY}NerdFont"
 
        # already installed? (checked by presence of font files, not by
        # fc-list name, since the internal family name doesn't always
        # match the download name)
        if [ -d "$font_dir" ] && find "$font_dir" -maxdepth 1 \( -iname '*.ttf' -o -iname '*.otf' \) 2>/dev/null | grep -q .; then
            message="$(msg_skip "$NERD_FONT_FAMILY")"
        else
            local tmp_dir archive url
            tmp_dir=$(mktemp -d)
            archive="$tmp_dir/${NERD_FONT_FAMILY}.zip"
            url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${NERD_FONT_FAMILY}.zip"
 
            if ! curl -fsSL "$url" -o "$archive"; then
                message="$(msg_err "Failed to download ${BOLD}$NERD_FONT_FAMILY${RC}! Check ${BOLD}${LOG_FILE}${RC} for details.")"
            else
                mkdir -p "$tmp_dir/unpacked" "$font_dir"
                if ! unzip -qq -o "$archive" -d "$tmp_dir/unpacked"; then
                    message="$(msg_err "Failed to extract ${BOLD}$NERD_FONT_FAMILY${RC}! Check ${BOLD}${LOG_FILE}${RC} for details.")"
                else
                    find "$tmp_dir/unpacked" -type f \( -iname '*.ttf' -o -iname '*.otf' \) -exec cp {} "$font_dir/" \;
 
                    if ! find "$font_dir" -maxdepth 1 \( -iname '*.ttf' -o -iname '*.otf' \) | grep -q .; then
                        message="$(msg_err "No font files found for ${BOLD}$NERD_FONT_FAMILY${RC}!")"
                    else
                        fc-cache -f "$font_dir" >/dev/null 2>&1
                        message="$(msg_ok "Font ${BOLD}$NERD_FONT_FAMILY${RC} installed.")"
                    fi
                fi
            fi
 
            rm -rf "$tmp_dir"
        fi
    } >> "$LOG_FILE" 2>&1
 
    stop_spinner "$message" | tee -a "$LOG_FILE"
}