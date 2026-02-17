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

install_brew_bundle() {
    print_header "Installing packages with Homebrew (Brewfile)"
    
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/Developer/dotfiles}"
    BREWFILE="$DOTFILES_DIR/Brewfile"
    
    if [ ! -f "$BREWFILE" ]; then
        print_error "Brewfile not found at $BREWFILE"
        return 1
    fi
    
    echo "Running brew bundle from $BREWFILE..."
    brew bundle --file="$BREWFILE" || print_warning "Some packages may have failed to install."
    print_success "Brew bundle completed!"
}

create_directories() {
    print_header "Creating necessary directories"
    
    CONFIG_DIR="$HOME/.config"
    SCRIPTS_DIR="$HOME/.scripts"
    
    if [ ! -d "$CONFIG_DIR" ]; then
        mkdir -p "$CONFIG_DIR"
        print_success "Created $CONFIG_DIR directory"
    else
        print_success "$CONFIG_DIR directory already exists"
    fi
    
    if [ ! -d "$SCRIPTS_DIR" ]; then
        mkdir -p "$SCRIPTS_DIR"
        print_success "Created $SCRIPTS_DIR directory"
    else
        print_success "$SCRIPTS_DIR directory already exists"
    fi
    
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
    
    CURSOR_USER_DIR="$HOME/Library/Application Support/Cursor/User"
    CURSOR_DOTFILES="$DOTFILES_DIR/.config/cursor"
    if [ -d "$CURSOR_DOTFILES" ]; then
        echo "Linking Cursor User config..."
        mkdir -p "$CURSOR_USER_DIR"
        for file in settings.json keybindings.json; do
            source_file="$CURSOR_DOTFILES/$file"
            target_file="$CURSOR_USER_DIR/$file"
            if [ -f "$source_file" ]; then
                if [ -e "$target_file" ] && [ ! -L "$target_file" ]; then
                    echo "Backing up existing $target_file to ${target_file}.backup..."
                    mv "$target_file" "${target_file}.backup"
                elif [ -L "$target_file" ]; then
                    rm "$target_file"
                fi
                echo "Linking $source_file to $target_file..."
                ln -sf "$source_file" "$target_file"
                print_success "Linked Cursor $file"
            else
                print_warning "Source file $source_file not found, skipping..."
            fi
        done
    else
        print_warning "Cursor config directory $CURSOR_DOTFILES not found, skipping..."
    fi
    
    echo "Linking scripts directory..."
    
    if [ -d "$DOTFILES_DIR/.scripts" ]; then
        if [ -d "$SCRIPTS_DIR" ] && [ ! -L "$SCRIPTS_DIR" ]; then
            echo "Backing up existing $SCRIPTS_DIR to ${SCRIPTS_DIR}.backup..."
            mv "$SCRIPTS_DIR" "${SCRIPTS_DIR}.backup"
        elif [ -L "$SCRIPTS_DIR" ]; then
            rm "$SCRIPTS_DIR"
        fi
        
        echo "Linking $DOTFILES_DIR/.scripts to $SCRIPTS_DIR..."
        ln -sf "$DOTFILES_DIR/.scripts" "$SCRIPTS_DIR"
        print_success "Linked .scripts directory"
        
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
    install_brew_bundle
    
    create_directories
    create_symlinks
    
    print_header "Setup Complete!"
    echo -e "${GREEN}Your dotfiles have been successfully set up!${NC}"
    echo "You may need to restart your terminal or your computer for all changes to take effect."
}

main
