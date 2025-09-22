# Dotfiles

My personal dotfiles for MacOS setup with a simple installation script that makes setup a breeze.

## What's Included

This dotfiles repository contains configuration for:

- **Neovim** - Text editor with modern plugins and LSP support
- **Tmux** - Terminal multiplexer with sensible keybindings
- **Btop** - Resource monitor with beautiful interface
- **Yabai** - Tiling window manager for MacOS
- **Skhd** - Simple hotkey daemon for MacOS
- **Zsh** - Shell configuration with useful aliases and settings

## Prerequisites

- MacOS (tested on Monterey and later)
- Git

## Installation

You can set up these dotfiles with a single command:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/nopnapatn/dotfiles/main/install.sh)"
```

Or manually:

1. Clone this repository:

   ```bash
   git clone https://github.com/nopnapatn/dotfiles.git ~/.dotfiles
   ```

2. Run the installation script:
   ```bash
   cd ~/.dotfiles
   chmod +x install.sh
   ./install.sh
   ```

## What the Installation Script Does

The installation script performs the following actions:

1. Installs Homebrew (if not already installed)
2. Installs necessary packages via Homebrew
3. Creates required directories in `~/.config/`
4. Creates symbolic links from the dotfiles to their appropriate locations
5. Sets up and starts services (yabai and skhd)

## Key Bindings

### Yabai + Skhd

| Keybinding              | Action                          |
| ----------------------- | ------------------------------- |
| `alt - return`          | Open terminal                   |
| `alt - h/j/k/l`         | Focus window left/down/up/right |
| `shift + alt - h/j/k/l` | Move window left/down/up/right  |
| `shift + alt - 1-9`     | Move window to workspace 1-9    |
| `ctrl + alt - h/j/k/l`  | Resize window                   |
| `shift + alt - space`   | Toggle window float             |
| `alt - f`               | Toggle window fullscreen        |
| `shift + alt - r`       | Restart yabai                   |

### Tmux

| Keybinding         | Action                    |
| ------------------ | ------------------------- |
| `C-Space`          | Prefix key                |
| `Prefix + \|`      | Split window horizontally |
| `Prefix + -`       | Split window vertically   |
| `Prefix + h/j/k/l` | Navigate panes            |
| `Prefix + r`       | Reload tmux config        |
| `Alt + Arrow keys` | Navigate panes            |

## Updating

To update your dotfiles:

```bash
cd ~/.dotfiles
git pull
./install.sh
```

The installation script is idempotent, so running it again will only update what's necessary.

## Conclusion

Feel free to customize the dotfiles to suit your needs. If you have any questions or suggestions, please open an issue or pull request on GitHub.
