##############################################
## Aliases
##############################################
alias k='kubectl'
alias h='helm'
alias tf='terraform'
alias a='ansible'
alias ap='ansible-playbook'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'

alias c='clear'

# Changing `ls` to `eza`
alias ls='eza -a --group-directories-first --icons=always --color=always'
alias la='eza -al -h --mounts -g --group-directories-first --icons=always --color=always --git-repos-no-status'
alias lt='eza -aT --group-directories-first --icons=always --color=always --level 2' # tree listing

# Vim
alias vim='nvim'

# System Tools
alias grep='grep --color=auto'
alias psa='ps auxf'
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'