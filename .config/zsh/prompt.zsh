# ~/.config/zsh/prompt.zsh

# Prevent Python virtualenv from polluting the prompt
export VIRTUAL_ENV_DISABLE_PROMPT=1

FUNCNEST=100

if command -v oh-my-posh >/dev/null; then
    eval "$(oh-my-posh init zsh --config ~/dotfiles/.config/oh-my-posh/code.toml)"
else
    echo "Warning: Oh-My-Posh not found in $OMP_HOME" >&2
fi
