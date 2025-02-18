# dotfiles

Contains dotfiles

## Requirements

- git
- stow

## Installation

### 1. Install requirements
- Debian
  ```sh
  sudo apt update && sudo apt install -y git curl
  ```

- Arch Linux
  ```sh
  sudo pacman -S --noconfirm git curl
  ```

- Fedora
  ```sh
  sudo dnf install git curl
  ```

- OpenSUSE
  ```sh
  sudo zypper install git curl
  ```

### 2. Checkout the repo in your $HOME folder using git.
```sh
git clone https://github.com/tonytech83/dotfiles.git
cd dotfiles
```
### 3. Make `install-zsh.sh` executable.
```sh
chmod +x install-zsh.sh
```
3. To install `.zshrc` configuration, execute the following command in your terminal:
```sh
./install-zsh.sh
```