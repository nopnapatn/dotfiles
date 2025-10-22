#!/bin/bash

# Color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}! $1${NC}"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

clone_dotfiles() {
    print_header "Setting up dotfiles repository"
    
    REPO_URL="https://github.com/nopnapatn/dotfiles.git"
    DOTFILES_DIR="$HOME/Developer/dotfiles"
    
    if [ -d "$DOTFILES_DIR" ]; then
        print_warning "Dotfiles directory already exists at $DOTFILES_DIR"
        read -p "Do you want to update the existing repository? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Updating dotfiles repository..."
            cd "$DOTFILES_DIR" || exit
            git pull
            print_success "Dotfiles repository updated successfully!"
        fi
    else
        echo "Cloning dotfiles repository from $REPO_URL to $DOTFILES_DIR..."
        mkdir -p "$(dirname "$DOTFILES_DIR")"
        git clone "$REPO_URL" "$DOTFILES_DIR"
        print_success "Dotfiles repository cloned successfully!"
    fi
}

install_homebrew() {
    print_header "Checking for Homebrew"
    if command_exists brew; then
        print_success "Homebrew is already installed."
        brew update
        print_success "Homebrew updated."
    else
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zshrc"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zshrc"
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        
        print_success "Homebrew installed successfully!"
    fi
}

install_packages() {
    print_header "Installing packages with Homebrew"
    
    PACKAGES=(
        "git"
        "neovim"
        "neofetch"
        "neovide"
        "tmux"
        "btop"
        "koekeishiya/formulae/yabai"
        "koekeishiya/formulae/skhd"
        "ripgrep"
        "fd"
        "fzf"
        "bat"
        "exa"
        "jq"
        "zsh-autosuggestions"
        "zsh-syntax-highlighting"
        "docker"
        "fvm"
        "gh"
        "go"
        "gitflow"
        "goose"
        "mockery"
        "node"
        "nvm"
        "pnpm"
        "pyenv"
        "solidity"
        "stylua"
        "uv"
        "yarn"
        "z"
    )
    
    echo "Installing CLI tools..."
    for package in "${PACKAGES[@]}"; do
        echo "Installing $package..."
        brew install "$package" || print_warning "Failed to install $package, continuing..."
    done
    
    print_success "Packages installed successfully!"
}

install_casks() {
    print_header "Installing casks with Homebrew"

    CASKS=(
        "visual-studio-code"
        "android-studio"
        "iterm2"
        "alfred"
        "zen"
        "cursor"
        "tradingview"
        "warp"
        "obsidian"
        "figma"
        "minecraft"
        "discord"
        "regtangle"
        "min"
        "docker"
        "flutter"
        "fork"
        "telegram"
        "keyboardcleantool"
        "numi"
        "cleanmymac"
        "slack"
        "google-chrome"
        "notion"
        "notion-calendar"
        "postman"
        "brave-browser"
        "arc"
    )

    echo "Installing Casks tools..."
    for cask in "${CASKS[@]}"; do
        echo "Installing $cask..."
        brew install --cask "$cask" || print_warning "Failed to install $cask, continuing..."
    done
    
    print_success "Casks installed successfully!"
}

create_directories() {
    print_header "Creating necessary directories"
    
    CONFIG_DIR="$HOME/.config"
    SCRIPTS_DIR="$HOME/.scripts"
    
    # Create .config directory if it doesn't exist
    if [ ! -d "$CONFIG_DIR" ]; then
        mkdir -p "$CONFIG_DIR"
        print_success "Created $CONFIG_DIR directory"
    else
        print_success "$CONFIG_DIR directory already exists"
    fi
    
    # Create .scripts directory if it doesn't exist
    if [ ! -d "$SCRIPTS_DIR" ]; then
        mkdir -p "$SCRIPTS_DIR"
        print_success "Created $SCRIPTS_DIR directory"
    else
        print_success "$SCRIPTS_DIR directory already exists"
    fi
    
    # Create config subdirectories
    for dir in nvim tmux btop skhd yabai; do
        if [ ! -d "$CONFIG_DIR/$dir" ]; then
            mkdir -p "$CONFIG_DIR/$dir"
            print_success "Created $CONFIG_DIR/$dir directory"
        else
            print_success "$CONFIG_DIR/$dir directory already exists"
        fi
    done
}

create_symlinks() {
    print_header "Creating symbolic links"
    
    DOTFILES_DIR="$HOME/Developer/dotfiles"
    CONFIG_DIR="$HOME/.config"
    SCRIPTS_DIR="$HOME/.scripts"
    
    if [ ! -d "$DOTFILES_DIR" ]; then
        print_error "Dotfiles directory not found at $DOTFILES_DIR"
        return 1
    fi
    
    echo "Linking .config directories..."
    
    CONFIG_DIRS=(
        "btop"
        "nvim"
        "skhd"
        "tmux"
        "yabai"
    )
    
    for dir in "${CONFIG_DIRS[@]}"; do
        source_dir="$DOTFILES_DIR/.config/$dir"
        target_dir="$CONFIG_DIR/$dir"
        
        if [ -d "$source_dir" ] || [ -f "$source_dir" ]; then
            if [ -e "$target_dir" ]; then
                echo "Removing existing $target_dir..."
                rm -rf "$target_dir"
            fi
            
            echo "Linking $source_dir to $target_dir..."
            ln -sf "$source_dir" "$target_dir"
            print_success "Linked $dir configuration"
        else
            print_warning "Source directory/file $source_dir not found, skipping..."
        fi
    done
    
    echo "Linking scripts directory..."
    
    # Link the .scripts directory from dotfiles
    if [ -d "$DOTFILES_DIR/.scripts" ]; then
        # Remove existing .scripts directory if it's not a symlink
        if [ -d "$SCRIPTS_DIR" ] && [ ! -L "$SCRIPTS_DIR" ]; then
            echo "Backing up existing $SCRIPTS_DIR to ${SCRIPTS_DIR}.backup..."
            mv "$SCRIPTS_DIR" "${SCRIPTS_DIR}.backup"
        elif [ -L "$SCRIPTS_DIR" ]; then
            rm "$SCRIPTS_DIR"
        fi
        
        echo "Linking $DOTFILES_DIR/.scripts to $SCRIPTS_DIR..."
        ln -sf "$DOTFILES_DIR/.scripts" "$SCRIPTS_DIR"
        print_success "Linked .scripts directory"
        
        # Make all scripts executable
        find "$SCRIPTS_DIR" -type f -name "*.sh" -exec chmod +x {} \;
        print_success "Made all scripts executable"
    else
        print_warning "Source directory $DOTFILES_DIR/.scripts not found, skipping..."
    fi
    
    echo "Linking other dotfiles..."
    
    ROOT_FILES=(
        ".zshrc"
        ".gitconfig"
    )
    
    for file in "${ROOT_FILES[@]}"; do
        source_file="$DOTFILES_DIR/$file"
        target_file="$HOME/$file"
        
        if [ -f "$source_file" ]; then
            if [ -f "$target_file" ] && [ ! -L "$target_file" ]; then
                echo "Backing up existing $target_file to ${target_file}.backup..."
                mv "$target_file" "${target_file}.backup"
            elif [ -L "$target_file" ]; then
                rm "$target_file"
            fi
            
            echo "Linking $source_file to $target_file..."
            ln -sf "$source_file" "$target_file"
            print_success "Linked $file"
        else
            print_warning "Source file $source_file not found, skipping..."
        fi
    done
}


main() {
    print_header "Starting Dotfiles Setup"
    
    clone_dotfiles

    install_homebrew
    install_packages
    install_casks
    
    create_directories
    create_symlinks
    
    print_header "Setup Complete!"
    echo -e "${GREEN}Your dotfiles have been successfully set up!${NC}"
    echo "You may need to restart your terminal or your computer for all changes to take effect."
}

main
