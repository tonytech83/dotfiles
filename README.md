[![CI](https://img.shields.io/github/actions/workflow/status/tonytech83/dotfiles/ci.yml?branch=main&label=Lint%20Test%20%26%20Release&style=for-the-badge)](https://github.com/tonytech83/dotfiles/actions/workflows/ci.yml)
[![Version](https://img.shields.io/github/v/release/tonytech83/dotfiles?color=%230567ff&label=Latest%20Release&style=for-the-badge)](https://github.com/tonytech83/dotfiles/releases)


# dotfiles

A comprehensive collection of dotfiles and configurations for my Linux development environment, featuring a beautiful ZSH setup with Oh-My-Posh, Neovim configuration, and various terminal applications.

## Features

### Shell Configuration
- **ZSH** with [Zinit](https://github.com/zdharma-continuum/zinit) plugin manager
- **Oh-My-Posh** with custom minimal theme
- **Smart plugins**: syntax highlighting, autosuggestions, completions, and fzf-tab
- **Enhanced history** management with deduplication
- **Custom keybindings** for efficient navigation

### Development Tools
- **Neovim** configuration with AstroNvim framework
- **Terminal emulators**: Alacritty and Kitty configurations
- **System information**: Fastfetch configuration
- **File navigation**: Enhanced with `eza`, `fzf`, and `zoxide`
- **Application launcher**: Rofi with multiple themes

### Theming
- **Nord/Nordic** color schemes across applications
- **Consistent theming** for terminal, editor, and launcher
- **Multiple Rofi themes**: Dracula, Everblush, Forest, Gruv, Nord, OneDark

### Utilities
- **Nano** configuration with syntax highlighting and line numbers
- **Kubectl, Helm, Terraform, Ansible** aliases for DevOps workflows
- **Stow** for symlink management

## What's Included

```
dotfiles/
├── .config/
│   ├── alacritty/          # Terminal emulator config
│   ├── fastfetch/          # System info tool
│   ├── kitty/              # Terminal emulator config
│   ├── nvim/               # Neovim configuration
│   ├── oh-my-posh/         # Shell prompt theme
│   ├── eza/                # modern alternative for the ls
│   ├── rofi/               # Application launcher
│   └── zsh/
│       └── aliases.zsh     # Custom shell aliases
├── .zshrc                  # Main ZSH configuration
├── .nanorc                 # Nano editor configuration
└── setup.sh                # Automated installation script
```

## Quick Installation

The installation script automatically detects your Linux distribution and installs all necessary dependencies.

### 1. Clone the repository
```bash
git clone https://github.com/tonytech83/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Run the installation script
```bash
chmod +x setup.sh
./setup.sh
```

### 3. Restart your shell
```bash
exec zsh
```

## Manual Installation

### Prerequisites
The script automatically handles these, but for manual installation you'll need:

- **curl** - for downloading tools
- **sudo** or **doas** - for privilege escalation
- **git** - for cloning repositories
- **stow** - for managing symlinks

### Supported Package Managers
- **APT** (Debian/Ubuntu)
- **DNF** (Fedora)
- **Pacman** (Arch Linux) - includes AUR helper installation
- **Zypper** (openSUSE)
- **YUM** (CentOS/RHEL)

### Installed Tools
The script automatically installs:
- **ZSH** - Modern shell
- **Stow** - Symlink farm manager
- **eza** - Modern replacement for `ls`
- **fzf** - Fuzzy finder
- **zoxide** - Smart directory jumper
- **Oh-My-Posh** - Cross-platform prompt theme engine

## Customization

### Adding Personal Configurations
1. Fork this repository
2. Modify configurations in `.config/` directories
3. Update `.zsh/aliases.zsh` with your preferred aliases
4. Customize the Oh-My-Posh theme in `.config/oh-my-posh/minimal.toml`

### Extending the Setup
- Add new configurations to appropriate `.config/` subdirectories
- Update `.stow-local-ignore` to exclude files from symlinking
- Modify `install-zsh.sh` to include additional tools

## Troubleshooting

### Common Issues
1. **Stow conflicts**: The script performs a dry-run first and reports conflicts
2. **Missing fonts**: Install a Nerd Font for proper icon display
3. **Permission issues**: Ensure your user has sudo access
4. **Package manager not detected**: Manually install dependencies

### Getting Help
- Check the `installation.log` for detailed error messages
- Ensure you're running on a supported Linux distribution
- Verify internet connectivity for downloading tools

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Acknowledgments

- [Zinit](https://github.com/zdharma-continuum/zinit) for the excellent ZSH plugin manager
- [Oh-My-Posh](https://ohmyposh.dev/) for the beautiful prompt engine
- [AstroNvim](https://astronvim.com/) for the Neovim configuration framework
- The open-source community for all the amazing tools integrated here
