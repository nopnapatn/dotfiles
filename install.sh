#!/bin/bash

# Resolve dotfiles directory: use directory containing this script when it's the repo (has Brewfile)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/Brewfile" ]; then
    DOTFILES_DIR="$SCRIPT_DIR"
else
    DOTFILES_DIR=""
fi
export DOTFILES_DIR

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

# Spinner PID for cleanup
_SPINNER_PID=""

spinner_start() {
    local msg="${1:-Loading...}"
    (
        local chars='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
        local i=0
        while true; do
            printf '\r  %s %s  ' "$msg" "${chars:i++%${#chars}:1}" >&2
            sleep 0.1
        done
    ) &
    _SPINNER_PID=$!
}

spinner_stop() {
    if [ -n "$_SPINNER_PID" ] && kill "$_SPINNER_PID" 2>/dev/null; then
        wait "$_SPINNER_PID" 2>/dev/null
    fi
    _SPINNER_PID=""
    printf '\r\033[K' >&2
}

clone_dotfiles() {
    print_header "Setting up dotfiles repository"
    REPO_URL="https://github.com/nopnapatn/dotfiles.git"
    TARGET_DIR="${DOTFILES_DIR:-$HOME/Developer/dotfiles}"

    # Already in repo (e.g. make install from cloned dotfiles): just update
    if [ -n "$DOTFILES_DIR" ] && [ -d "$DOTFILES_DIR/.git" ]; then
        print_success "Using dotfiles at $DOTFILES_DIR"
        (cd "$DOTFILES_DIR" && git pull --ff-only) 2>/dev/null && print_success "Repository updated." || true
        return 0
    fi

    if [ -d "$TARGET_DIR" ]; then
        if [ -t 0 ]; then
            print_warning "Dotfiles directory already exists at $TARGET_DIR"
            read -p "Update existing repository? (y/N) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                (cd "$TARGET_DIR" && git pull --ff-only) && print_success "Repository updated."
            fi
        else
            (cd "$TARGET_DIR" && git pull --ff-only) 2>/dev/null && print_success "Repository updated." || true
        fi
        DOTFILES_DIR="$TARGET_DIR"
        export DOTFILES_DIR
        return 0
    fi

    echo "Cloning dotfiles from $REPO_URL to $TARGET_DIR..."
    mkdir -p "$(dirname "$TARGET_DIR")"
    git clone "$REPO_URL" "$TARGET_DIR"
    DOTFILES_DIR="$TARGET_DIR"
    export DOTFILES_DIR
    print_success "Dotfiles repository cloned successfully!"
}

install_homebrew() {
    print_header "Checking for Homebrew"
    # Add existing Homebrew to PATH first (e.g. when run via make without .zshrc)
    ensure_brew_in_path 2>/dev/null || true
    if command_exists brew; then
        print_success "Homebrew is already installed."
        brew update
        print_success "Homebrew updated."
        return 0
    fi
    echo "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ "$(uname -s)" == "Darwin" ]]; then
        if [[ -x /opt/homebrew/bin/brew ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zshrc"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -x /usr/local/bin/brew ]]; then
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zshrc"
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        # Linux
        [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        [[ -x "$HOME/.linuxbrew/bin/brew" ]] && eval "$($HOME/.linuxbrew/bin/brew shellenv)"
    fi
    if command_exists brew; then
        print_success "Homebrew installed successfully!"
    else
        print_error "Homebrew install may have completed but brew is not in PATH. Restart the terminal and run: make install"
        return 1
    fi
}

ensure_brew_in_path() {
    # Ensure Homebrew is on PATH (needed when script runs in a context where .zshrc isn't loaded)
    if command_exists brew; then
        return 0
    fi
    if [[ "$(uname -s)" == "Darwin" ]]; then
        if [[ -x /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -x /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        elif [[ -x "$HOME/.linuxbrew/bin/brew" ]]; then
            eval "$($HOME/.linuxbrew/bin/brew shellenv)"
        fi
    fi
    if ! command_exists brew; then
        print_error "Homebrew is not available. Please install it first or restart your terminal."
        return 1
    fi
}

install_brew_bundle() {
    print_header "Installing packages with Homebrew (Brewfile)"
    
    ensure_brew_in_path || return 1
    
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/Developer/dotfiles}"
    BREWFILE="$DOTFILES_DIR/Brewfile"
    BREWFILE="$(cd "$(dirname "$BREWFILE")" && pwd)/$(basename "$BREWFILE")"
    
    if [ ! -f "$BREWFILE" ]; then
        print_error "Brewfile not found at $BREWFILE"
        return 1
    fi
    
    echo "Running brew bundle from $BREWFILE..."
    spinner_start "Installing packages"
    if brew bundle install --file="$BREWFILE" --no-upgrade; then
        spinner_stop
        print_success "Brew bundle completed!"
    else
        spinner_stop
        print_warning "Some formulae or casks may have failed. Re-run: brew bundle install --file=$BREWFILE"
    fi
}

install_oh_my_zsh() {
    print_header "Installing Oh My Zsh"
    ZSH="${ZSH:-$HOME/.oh-my-zsh}"
    if [ -d "$ZSH" ]; then
        print_success "Oh My Zsh is already installed at $ZSH"
        return 0
    fi
    echo "Installing Oh My Zsh..."
    # KEEP_ZSHRC=yes: don't overwrite .zshrc (we symlink it from dotfiles later)
    # RUNZSH=no: don't start zsh at the end; CHSH=no: don't change default shell (optional)
    KEEP_ZSHRC=yes RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
    if [ -d "$ZSH" ]; then
        print_success "Oh My Zsh installed successfully!"
    else
        print_error "Oh My Zsh installation failed."
        return 1
    fi
}

install_powerlevel10k() {
    print_header "Installing Powerlevel10k theme"
    ZSH="${ZSH:-$HOME/.oh-my-zsh}"
    ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"
    P10K_DIR="$ZSH_CUSTOM/themes/powerlevel10k"
    if [ -d "$P10K_DIR" ]; then
        print_success "Powerlevel10k is already installed at $P10K_DIR"
        return 0
    fi
    if [ ! -d "$ZSH" ]; then
        print_error "Oh My Zsh not found at $ZSH. Install Oh My Zsh first."
        return 1
    fi
    echo "Cloning Powerlevel10k into $P10K_DIR..."
    mkdir -p "$ZSH_CUSTOM/themes"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
    if [ -d "$P10K_DIR" ]; then
        print_success "Powerlevel10k installed successfully!"
    else
        print_error "Powerlevel10k installation failed."
        return 1
    fi
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
    
    for dir in btop cava neofetch nvim skhd superfile tmux yabai; do
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
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/Developer/dotfiles}"
    CONFIG_DIR="$HOME/.config"
    SCRIPTS_DIR="$HOME/.scripts"
    
    if [ ! -d "$DOTFILES_DIR" ]; then
        print_error "Dotfiles directory not found at $DOTFILES_DIR"
        return 1
    fi
    
    echo "Linking .config directories..."
    
    CONFIG_DIRS=(
        "btop"
        "cava"
        "neofetch"
        "nvim"
        "sketchybar"
        "skhd"
        "superfile"
        "tmux"
        "yabai"
        "yazi"
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

    # macOS: superfile uses Application Support, not ~/.config
    if [[ "$(uname -s)" == "Darwin" ]] && [ -d "$DOTFILES_DIR/.config/superfile" ]; then
        SPF_APP_SUPPORT="$HOME/Library/Application Support/superfile"
        if [ -e "$SPF_APP_SUPPORT" ] && [ ! -L "$SPF_APP_SUPPORT" ]; then
            echo "Backing up existing $SPF_APP_SUPPORT to ${SPF_APP_SUPPORT}.backup..."
            mv "$SPF_APP_SUPPORT" "${SPF_APP_SUPPORT}.backup"
        elif [ -L "$SPF_APP_SUPPORT" ]; then
            rm "$SPF_APP_SUPPORT"
        fi
        echo "Linking superfile config to Application Support..."
        ln -sf "$DOTFILES_DIR/.config/superfile" "$SPF_APP_SUPPORT"
        print_success "Linked superfile configuration (macOS)"
    fi

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

    install_oh_my_zsh
    install_powerlevel10k

    create_directories
    create_symlinks
    
    print_header "Setup Complete!"
    echo -e "${GREEN}Your dotfiles have been successfully set up!${NC}"
    echo "You may need to restart your terminal or your computer for all changes to take effect."
}

main
