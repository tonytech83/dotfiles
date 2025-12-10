##################################################################################
##### EXPORTS
##################################################################################
export PATH=$PATH:"$HOME/.local/bin"

##################################################################################
## Setup Zinit and plugins
##################################################################################
# Set the directory for Zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
        mkdir -p "$(dirname $ZINIT_HOME)"
        git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets (https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins)
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found
# uncomment and write down plugin for your distribution
# zinit snippet OMZP::archlinux

# Load completions
autoload -U compinit && compinit

# Add in Oh-My-Posh
zinit ice depth=1; zinit light jandedobbeleer/oh-my-posh

# Replay cached completions
zinit cdreplay -q

##################################################################################
## Completion styling
##################################################################################
# using lower case for completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
# add colors when using completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# Disable default zsh completion menu, replace by Aloxaf/fxf-tab
zstyle ':completion:*' menu no
# Add directiry preview
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
# zoxide
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

##################################################################################
## Keybinding
##################################################################################
# Ctrl+p search history backward
bindkey '^p' history-search-backward
# Ctrl+n search history forward
bindkey '^n' history-search-forward

##################################################################################
## History
##################################################################################
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

##################################################################################
## Aliases
##################################################################################
[[ -f ~/.config/zsh/aliases.zsh ]] && source ~/.config/zsh/aliases.zsh

#######################################################
## Load Oh-My-Posh if installed
#######################################################
OMP_HOME="${XDG_DATA_HOME:-${HOME}/.local/bin}"

if command -v oh-my-posh >/dev/null; then
    eval "$(oh-my-posh init zsh --config ~/dotfiles/.config/oh-my-posh/minimal.toml)"
else
    echo "Warning: Oh-My-Posh not found in $OMP_HOME" >&2
fi

##################################################################################
## Shell integration
##################################################################################
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
unalias zi 2>/dev/null
eval "$(zoxide init zsh)"

### Homebrew
if command -v oh-my-posh >/dev/null; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else
    echo "Warning: Homebrew is not installed ot not found in /home/linuxbrew/.linuxbrew/bin/brew" >&2
fi