# Dotfiles

My personal dotfiles for MacOS setup with a simple installation script that makes setup a breeze.

## What's Included

This dotfiles repository contains configuration for:

- **Neovim** - Text editor with modern plugins and LSP support
- **Cursor** - Editor settings and keybindings (synced to Application Support on macOS)
- **Tmux** - Terminal multiplexer with sensible keybindings
- **Btop** - Resource monitor with beautiful interface
- **Cava** - Audio spectrum visualizer (themes and shaders)
- **Neofetch** - System information display
- **Yazi** - Fast terminal file manager
- **Superfile** - TUI file manager (synced to Application Support on macOS)
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
   git clone https://github.com/nopnapatn/dotfiles.git ~/Developer/dotfiles
   ```

2. Run the installation (using Make):

   ```bash
   cd ~/Developer/dotfiles
   make install
   ```

## What the Installation Script Does

The installation script performs the following actions:

1. Installs Homebrew (if not already installed)
2. Installs packages and casks from `Brewfile` via `brew bundle`
3. Creates symbolic links from `~/.config/` (btop, cava, neofetch, nvim, skhd, superfile, tmux, yabai, yazi), Cursor User config, `~/.scripts`, and root dotfiles (e.g. `.zshrc`, `.gitconfig`)
4. On macOS, links Superfile and Cursor config to their Application Support paths
5. Sets up and starts services (yabai and skhd)

## Maintaining the Brewfile

All Homebrew packages and casks are listed in `Brewfile` for easy maintenance.

- **Install everything:** `make` or `./install.sh`
- **Add/remove packages:** Edit `Brewfile` (use `brew` for formulae, `cask` for GUI apps)
- **Sync Brewfile with current system:**  
  `brew bundle dump --file=Brewfile --force`  
  This overwrites `Brewfile` with what’s currently installed.

## Updating

To update your dotfiles:

```bash
cd ~/Developer/dotfiles
make update
```

The installation script is idempotent, so running it again will only update what's necessary.

## Conclusion

Feel free to customize the dotfiles to suit your needs. If you have any questions or suggestions, please open an issue or pull request on GitHub.
