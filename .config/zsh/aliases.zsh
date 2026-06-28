# =========================================================
# Applications
# =========================================================
alias k='kubectl'
alias h='helm'
alias tf='terraform'
alias a='ansible'
alias ap='ansible-playbook'


# =========================================================
# Better listing
# =========================================================
alias ls='eza -a --group-directories-first --icons=always --color=always'
alias la='eza -al -h --mounts -g --group-directories-first --icons=always --color=always --git-repos-no-status'
alias lt='eza -aT --group-directories-first --icons=always --color=always --level 2' # tree listing


# alias ls='eza --icons'

# # Detailed listing
# alias ll='eza -lh --icons --git'

# # Detailed listing including hidden files
# alias la='eza -lah --icons --git'

# # Tree view
# alias tree='eza --tree --icons'

# Reuse ls completions for eza (avoids defining a separate completion function)
compdef eza=ls

# =========================================================
# System Tools
# =========================================================
alias grep='rg --color=auto'
alias psa='ps auxf'
alias diff='diff --color=auto'
alias df='df -h'
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'

# =========================================================
# Navigation
# =========================================================
alias ..='cd ..'
alias ...='cd ../..'
alias -- -='cd -'  # -- prevents - being parsed as a flag; cd - jumps to previous directory

lf() { # zsh follow lf navigation
    tmp=$(mktemp)
    command lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir=$(cat "$tmp")
        rm -f "$tmp"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}
