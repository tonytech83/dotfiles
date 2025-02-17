#######################################################
# EXPORTS
#######################################################
export PATH=$PATH:"$HOME/.local/bin"

## Set the directory we will store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

## Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
        mkdir -p "$(dirname $ZINIT_HOME)"
        git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

## Load zinit
source "${ZINIT_HOME}/zinit.zsh"

## Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

## Add in snippets (https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins)
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::command-not-found

## Load completions
autoload -U compinit && compinit

## Replay cached completions
zinit cdreplay -q

#######################################################
# COLORS
# 1;31 → Bold Red
# 1;32 → Bold Green
# 1;36 → Bold Cyan
# 1;33 → Bold Yellow
# 1;35 → Bold Magenta
# 1;37 → Bold White
#######################################################
# Enable colors
#eval $(dircolors -b)

# Set folder colors
#export LS_COLORS="${LS_COLORS}:di=1;38;5;33;4"

#######################################################
## Comletion styling
#######################################################
# using lower case for completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
# add colors when using completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# Disable default zsh completion menu, replace by Aloxaf/fxf-tab
zstyle ':completion:*' menu no
# Add directiry preview
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
#
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

#######################################################
## Add in Oh-My-Posh
#######################################################
zinit ice depth=1; zinit light jandedobbeleer/oh-my-posh

#######################################################
## Keybinding
#######################################################
# Ctrl+p search history backward
bindkey '^p' history-search-backward
# Ctrl+n search hostory forward
bindkey '^n' history-search-forward

#######################################################
# History
#######################################################
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

#######################################################
## Aliases
#######################################################
alias ls='lsd -a --group-directories-first'
alias la='lsd -Al --group-directories-first --color auto'
alias c='clear'

#######################################################
# Set the Oh My Posh
#######################################################
eval "$(oh-my-posh init zsh --config /home/tonytech/repos/dotfiles/.config/oh-my-posh/minimal.toml)"

#######################################################
## Shell integration
#######################################################
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
unalias zi 2>/dev/null
eval "$(zoxide init zsh)"
