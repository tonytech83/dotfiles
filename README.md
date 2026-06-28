[![CI](https://img.shields.io/github/actions/workflow/status/tonytech83/dotfiles/ci.yml?branch=main&label=Lint%20Test%20%26%20Release&style=for-the-badge)](https://github.com/tonytech83/dotfiles/actions/workflows/ci.yml)
[![Version](https://img.shields.io/github/v/release/tonytech83/dotfiles?color=%230567ff&label=Latest%20Release&style=for-the-badge)](https://github.com/tonytech83/dotfiles/releases)

# dotfiles

A minimal, XDG-compliant ZSH setup for Linux. The shell config lives under `~/.config/zsh` (`ZDOTDIR`), the prompt is [Oh-My-Posh](https://ohmyposh.dev/), and everything is symlinked with [GNU Stow](https://www.gnu.org/software/stow/).

## Install

```bash
mkdir ~/dotfiles
cd ~/dotfiles && git clone https://github.com/tonytech83/dotfiles.git .
./setup.sh
```

`setup.sh` detects your package manager (apt, dnf, yum, pacman, zypper, apk), installs the tools below, stows the configs, points `ZDOTDIR` at `~/.config/zsh` via `/etc/zsh/zshenv`, and sets ZSH as the default shell. Details are logged to `installation.log`.

Installed tools: `zsh`, `stow`, `eza`, `fzf`, `fd`, `zoxide`, `oh-my-posh`.

## What's included

```
.
├── .config
│   ├── alacritty     # terminal emulator
│   ├── eza           # ls replacement theme
│   ├── fastfetch     # system info
│   ├── kitty         # terminal emulato
│   ├── nvim          # Neovim (AstroNvim)
│   ├── oh-my-posh    # prompt themes
│   ├── rofi          # app launcher + themes
│   └── zsh           # .zshrc, .zshenv, aliases, bindings, fzf, plugins, prompt
├── .nanorc           # nano config
└── setup.sh          # installer
```

## Plugins

Managed by a tiny loader in `zsh/plugins.zsh` (git clone + source, no framework). Run `zplugin-update` to update them.

| Plugin | Purpose |
| --- | --- |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Fish-like suggestions from history |
| [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search) | Substring history search on ↑/↓ |
| [fzf-tab](https://github.com/Aloxaf/fzf-tab) | fzf-powered tab completion |
| [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting) | Command-line syntax highlighting |

## Keybindings

| Key | Action |
| --- | --- |
| `Ctrl`+`→` / `Ctrl`+`←` | Move forward / backward one word |
| `Ctrl`+`F` | fzf file picker (no hidden files) |
| `Ctrl`+`\` | Toggle autosuggestions |
| `↑` / `↓` | History substring search |

## Prompt

The prompt uses Oh-My-Posh with `oh-my-posh/code.toml`. A [Nerd Font](https://www.nerdfonts.com/) is required for icons to render correctly.

## License

MIT — see [LICENSE](LICENSE).
