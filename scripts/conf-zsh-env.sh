#!/usr/bin/env bash

##################################################################################
#####   Function to configure zsh environment
##################################################################################
conf_zsh_env() {

    print_step "Configure zsh environment"
    start_spinner "Configuring..."

    {
        local message
        local zshenv_path
        local os_id
        local os_like

        # zsh's global config dir varies:
        # Debian/Arch/Alpine use /etc/zsh,
        # RHEL/Fedora-family use /etc/zshenv
        zshenv_path="/etc/zsh/zshenv"
        if [ -r /etc/os-release ]; then
            os_id=$(. /etc/os-release && echo "$ID")
            os_like=$(. /etc/os-release && echo "$ID_LIKE")
        fi
        case " ${os_id} ${os_like} " in
            *" rhel "* | *" fedora "* | *" centos "*)
                zshenv_path="/etc/zshenv"
                ;;
        esac

        ${SUDO_CMD} mkdir -p "$(dirname "$zshenv_path")"
        ${SUDO_CMD} tee -a "$zshenv_path" <<-'EOF'
		if [[ -z "$XDG_CONFIG_HOME" ]]
		then
		    export XDG_CONFIG_HOME="$HOME/.config"
		fi
		if [[ -d "$XDG_CONFIG_HOME/zsh" ]]
		then
		    export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
		fi
		EOF
        message="$(msg_ok "Zsh environment configured successfully!")"
    } >> "$LOG_FILE" 2>&1

    stop_spinner "$message"
}