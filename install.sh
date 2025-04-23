#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Print section header
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

# Print success message
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Print error message
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Print warning message
print_warning() {
    echo -e "${YELLOW}! $1${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install Homebrew if not installed
install_homebrew() {
    print_header "Checking for Homebrew"
    if command_exists brew; then
        print_success "Homebrew is already installed."
    else
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH based on architecture
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zshrc
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> $HOME/.zshrc
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        
        print_success "Homebrew installed successfully!"
    fi
}

# Function to clone dotfiles repository
clone_dotfiles() {
    print_header "Setting up dotfiles repository"
    
    # Define the repository URL
    REPO_URL="https://github.com/nopnapatn/dotfiles.git"
    DOTFILES_DIR="$HOME/Developer/dotfiles"
    
    # Check if the dotfiles directory already exists
    if [ -d "$DOTFILES_DIR" ]; then
        print_warning "Dotfiles directory already exists at $DOTFILES_DIR"
        read -p "Do you want to update the existing repository? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Updating dotfiles repository..."
            cd "$DOTFILES_DIR"
            git pull
            print_success "Dotfiles repository updated successfully!"
        fi
    else
        echo "Cloning dotfiles repository from $REPO_URL to $DOTFILES_DIR..."
        git clone "$REPO_URL" "$DOTFILES_DIR"
        print_success "Dotfiles repository cloned successfully!"
    fi
}

# Function to install packages using Homebrew
install_packages() {
    print_header "Installing packages with Homebrew"
    
    # Common tools
    PACKAGES=(
        "git"
        "neovim"
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
    )
    
    # Install packages
    echo "Installing CLI tools..."
    for package in "${PACKAGES[@]}"; do
        echo "Installing $package..."
        brew install "$package" || print_warning "Failed to install $package, continuing..."
    done
    
    print_success "Packages installed successfully!"
}

# Function to create necessary directories
create_directories() {
    print_header "Creating necessary directories"
    
    CONFIG_DIR="$HOME/.config"
    
    # Create .config directory if it doesn't exist
    if [ ! -d "$CONFIG_DIR" ]; then
        mkdir -p "$CONFIG_DIR"
        print_success "Created $CONFIG_DIR directory"
    else
        print_success "$CONFIG_DIR directory already exists"
    fi
    
    # Create subdirectories if they don't exist
    for dir in nvim tmux btop skhd yabai; do
        if [ ! -d "$CONFIG_DIR/$dir" ]; then
            mkdir -p "$CONFIG_DIR/$dir"
            print_success "Created $CONFIG_DIR/$dir directory"
        else
            print_success "$CONFIG_DIR/$dir directory already exists"
        fi
    done
}

# Function to create symbolic links
create_symlinks() {
    print_header "Creating symbolic links"
    
    DOTFILES_DIR="$HOME/Developer/dotfiles"
    CONFIG_DIR="$HOME/.config"
    
    # Check if dotfiles directory exists
    if [ ! -d "$DOTFILES_DIR" ]; then
        print_error "Dotfiles directory not found at $DOTFILES_DIR"
        return 1
    fi
    
    # Link .config directories
    echo "Linking .config directories..."
    
    # Array of directories to link
    CONFIG_DIRS=("nvim" "tmux" "btop" "skhd" "yabai")
    
    for dir in "${CONFIG_DIRS[@]}"; do
        source_dir="$DOTFILES_DIR/.config/$dir"
        target_dir="$CONFIG_DIR/$dir"
        
        # Check if source directory exists
        if [ -d "$source_dir" ] || [ -f "$source_dir" ]; then
            # Remove existing directory/link if it exists
            if [ -e "$target_dir" ]; then
                echo "Removing existing $target_dir..."
                rm -rf "$target_dir"
            fi
            
            # Create symbolic link
            echo "Linking $source_dir to $target_dir..."
            ln -sf "$source_dir" "$target_dir"
            print_success "Linked $dir configuration"
        else
            print_warning "Source directory/file $source_dir not found, skipping..."
        fi
    done
    
    # Link other dotfiles from the repository root (like .zshrc, .tmux.conf, etc.)
    echo "Linking other dotfiles..."
    
    # Array of files to link from repository root
    ROOT_FILES=(".zshrc" ".gitconfig")
    
    for file in "${ROOT_FILES[@]}"; do
        source_file="$DOTFILES_DIR/$file"
        target_file="$HOME/$file"
        
        # Check if source file exists
        if [ -f "$source_file" ]; then
            # Backup existing file if it's not a symlink
            if [ -f "$target_file" ] && [ ! -L "$target_file" ]; then
                echo "Backing up existing $target_file to ${target_file}.backup..."
                mv "$target_file" "${target_file}.backup"
            elif [ -L "$target_file" ]; then
                # Remove existing symlink
                rm "$target_file"
            fi
            
            # Create symbolic link
            echo "Linking $source_file to $target_file..."
            ln -sf "$source_file" "$target_file"
            print_success "Linked $file"
        else
            print_warning "Source file $source_file not found, skipping..."
        fi
    done
}

# Function to setup services
setup_services() {
    print_header "Setting up services"
    
    # Start yabai
    echo "Setting up yabai service..."
    yabai --start-service || print_warning "Failed to start yabai service"
    
    # Start skhd
    echo "Setting up skhd service..."
    skhd --start-service || print_warning "Failed to start skhd service"
    
    print_success "Services setup complete!"
}

# Main function
main() {
    print_header "Starting Dotfiles Setup"
    
    # Install Homebrew
    install_homebrew
    
    # Clone dotfiles repository
    clone_dotfiles
    
    # Install packages
    install_packages
    
    # Create necessary directories
    create_directories
    
    # Create symbolic links
    create_symlinks
    
    # Setup services
    setup_services
    
    print_header "Setup Complete!"
    echo -e "${GREEN}Your dotfiles have been successfully set up!${NC}"
    echo "You may need to restart your terminal or your computer for all changes to take effect."
}

# Run the main function
main