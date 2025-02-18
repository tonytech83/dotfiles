# dotfiles

Contains dotfiles

## Requirements

- git
- stow

## installation

1. Install requirements
```sh
# Debian
sudo apt update && sudo apt install -y git curl

# Arch Linux
sudo pacman -S git curl

# Fedora
sudo dnf install git curl

# OpenSUSE
sudo zypper install git curl
```

1. Checkout the repo in your $HOME folder using git.
```sh
git clone https://github.com/tonytech83/dotfiles.git
cd dotfiles
```
2. Use GNU stow to create symlinks
```sh
chmod +x install-zsh.sh
```
3. Execute it
```sh
./install-zsh.sh
```