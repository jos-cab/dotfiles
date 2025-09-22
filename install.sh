#!/usr/bin/env bash

# Dotfiles installation script
# Creates symlinks from ~/.config to dotfiles directory
# Usage: ./install.sh
#
# Note: Run 'git submodule update --init --recursive' first to initialize submodules

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on a supported system
check_system() {
    if [[ "$OSTYPE" != "linux-gnu"* ]]; then
        log_warn "This script is designed for Linux systems. You might encounter issues on other systems."
    fi
}

# Global variable to track if user wants backups
DO_BACKUPS=false

# Function to backup existing files
backup_if_exists() {
    local file="$1"
    if [ -e "$file" ] || [ -L "$file" ]; then
        local backup="${file}.bak"
        local counter=1
        # If backup already exists, create numbered backups
        while [ -e "$backup" ] || [ -L "$backup" ]; do
            backup="${file}.bak.${counter}"
            ((counter++))
        done
        echo "Backing up $file -> $backup"
        mv "$file" "$backup"
    fi
}

# Function to create symlink with backup option
# $1 = destination (.config path), $2 = source (dotfiles path)
create_symlink() {
    local dest="$1"
    local source="$2"
    
    # Validate inputs
    if [[ -z "$dest" || -z "$source" ]]; then
        echo "Error: create_symlink requires both destination and source paths"
        return 1
    fi
    
    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$dest")"
    
    # Backup existing file/directory/link if it exists and user wants backups
    if [ "$DO_BACKUPS" = true ]; then
        backup_if_exists "$dest"
    elif [ -e "$dest" ] || [ -L "$dest" ]; then
        # If not backing up, just remove existing
        echo "Removing existing $dest"
        rm -rf "$dest"
    fi
    
    # Create symlink from ~/.config to dotfiles
    echo "Linking $dest -> $source"
    ln -sf "$source" "$dest"
}

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

# Validate environment
check_system

# Check if we have the expected directories
if [ ! -d "$DOTFILES_DIR/kitty" ] && [ ! -d "$DOTFILES_DIR/hyprland" ]; then
    log_error "This doesn't appear to be a dotfiles directory. Expected to find kitty or hyprland directories."
    exit 1
fi

# Check if submodules are initialized
if [ -f "$DOTFILES_DIR/.gitmodules" ] && [ ! -f "$DOTFILES_DIR/ranger/plugins/ranger_devicons/devicons.py" ]; then
    log_warn "Git submodules not initialized. Run 'git submodule update --init --recursive' first."
    log_warn "Continuing installation, but some plugins may not work properly."
    echo "Would you like to initialize submodules now? (y/N)"
    # Hide cursor during single character input
    tput civis 2>/dev/null
    read -n 1 -r response
    # Show cursor again
    tput cnorm 2>/dev/null
    echo  # Move to a new line after single character input
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        response="y"
    else
        response="n"
    fi
    if [[ "$response" =~ ^([yY])$ ]]; then
        git submodule update --init --recursive
    fi
fi

# Ask user if they want to backup existing files
echo
echo "Would you like to backup existing configuration files? (Y/n)"
# Hide cursor during single character input
tput civis 2>/dev/null
read -n 1 -r response
# Show cursor again
tput cnorm 2>/dev/null
echo  # Move to a new line after single character input
if [[ "$response" =~ ^([nN][oO]|[nN])$ ]]; then
    response="n"
elif [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]] || [[ "$response" == "" ]]; then
    response="y"
else
    response="n"
fi
if [[ "$response" =~ ^([yY])$ ]]; then
    DO_BACKUPS=true
fi

log_info "Installing dotfiles..."
log_info "Dotfiles directory: $DOTFILES_DIR"
log_info "Config directory: $CONFIG_DIR"
log_info "Backup existing files: $DO_BACKUPS"

# Create necessary directories if they don't exist
mkdir -p "$CONFIG_DIR"



# Ask user if they want to install dependencies
echo
echo "Would you like to install required dependencies? (y/N)"
# Hide cursor during single character input
tput civis 2>/dev/null
read -n 1 -r response
# Show cursor again
tput cnorm 2>/dev/null
echo  # Move to a new line after single character input
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    response="y"
else
    response="n"
fi
if [[ "$response" =~ ^([yY])$ ]]; then
    # Check if pacman is available
    if command -v pacman &> /dev/null; then
        log_info "Installing core components..."
        sudo pacman -S hyprland kitty waybar wofi mako zsh starship brightnessctl pavucontrol xdg-desktop-portal-hyprland grim slurp wl-clipboard --noconfirm || log_warn "Failed to install some packages. Please install manually."
        
        # Check for AUR helper
        if command -v paru &> /dev/null || command -v yay &> /dev/null; then
            log_info "Installing AUR packages..."
            if command -v paru &> /dev/null; then
                paru -S hyprpaper --noconfirm || log_warn "Failed to install hyprpaper. Please install manually."
            else
                yay -S hyprpaper --noconfirm || log_warn "Failed to install hyprpaper. Please install manually."
            fi
        else
            log_warn "No AUR helper found. Please install hyprpaper manually if needed."
        fi
    else
        log_error "Package manager not found. Please install dependencies manually."
    fi
fi

# Link ananicy configs
if [ -d "$DOTFILES_DIR/ananicy" ]; then
    mkdir -p "$CONFIG_DIR/ananicy"
    
    # Link all files and directories in ananicy directory
    for item in "$DOTFILES_DIR/ananicy"/*; do
        if [ -e "$item" ]; then
            filename=$(basename "$item")
            create_symlink "$CONFIG_DIR/ananicy/$filename" "$item"
        fi
    done
fi

# Link hyprland configs to hypr directory
if [ -d "$DOTFILES_DIR/hyprland" ]; then
    mkdir -p "$CONFIG_DIR/hypr"
    
    # Link all files and directories in hyprland directory
    for item in "$DOTFILES_DIR/hyprland"/*; do
        if [ -e "$item" ]; then
            filename=$(basename "$item")
            create_symlink "$CONFIG_DIR/hypr/$filename" "$item"
        fi
    done
fi

# Link hyprpaper config
if [ -f "$DOTFILES_DIR/hyprpaper/config" ]; then
    mkdir -p "$CONFIG_DIR/hyprpaper"
    create_symlink "$CONFIG_DIR/hyprpaper/config" "$DOTFILES_DIR/hyprpaper/config"
fi

# Link imv config
if [ -f "$DOTFILES_DIR/imv/config" ]; then
    mkdir -p "$CONFIG_DIR/imv"
    create_symlink "$CONFIG_DIR/imv/config" "$DOTFILES_DIR/imv/config"
fi

# Link kitty configs
if [ -d "$DOTFILES_DIR/kitty" ]; then
    mkdir -p "$CONFIG_DIR/kitty"
    for file in "$DOTFILES_DIR/kitty"/*; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            create_symlink "$CONFIG_DIR/kitty/$filename" "$file"
        fi
    done
fi

# Link mako config
if [ -f "$DOTFILES_DIR/mako/config" ]; then
    mkdir -p "$CONFIG_DIR/mako"
    create_symlink "$CONFIG_DIR/mako/config" "$DOTFILES_DIR/mako/config"
fi

# Link nvim configs
if [ -d "$DOTFILES_DIR/nvim" ]; then
    mkdir -p "$CONFIG_DIR/nvim"
    
    # Link all files and directories in nvim directory
    for item in "$DOTFILES_DIR/nvim"/*; do
        if [ -e "$item" ]; then
            filename=$(basename "$item")
            create_symlink "$CONFIG_DIR/nvim/$filename" "$item"
        fi
    done
fi

# Link ranger configs
if [ -d "$DOTFILES_DIR/ranger" ]; then
    mkdir -p "$CONFIG_DIR/ranger"
    
    # Link all files and directories in ranger directory
    for item in "$DOTFILES_DIR/ranger"/*; do
        if [ -e "$item" ]; then
            filename=$(basename "$item")
            
            # Special handling for plugins directory
            if [ "$filename" = "plugins" ]; then
                mkdir -p "$CONFIG_DIR/ranger/plugins"
                
                # Link each plugin individually
                for plugin in "$DOTFILES_DIR/ranger/plugins"/*; do
                    if [ -e "$plugin" ]; then
                        plugin_name=$(basename "$plugin")
                        create_symlink "$CONFIG_DIR/ranger/plugins/$plugin_name" "$plugin"
                    fi
                done
            else
                # Link other files and directories normally
                create_symlink "$CONFIG_DIR/ranger/$filename" "$item"
            fi
        fi
    done
fi

# Link starship config
if [ -f "$DOTFILES_DIR/starship/starship.toml" ]; then
    mkdir -p "$CONFIG_DIR/starship"
    create_symlink "$CONFIG_DIR/starship/starship.toml" "$DOTFILES_DIR/starship/starship.toml"
fi

# Also link to root of config directory for compatibility
if [ -f "$DOTFILES_DIR/starship/starship.toml" ]; then
    create_symlink "$CONFIG_DIR/starship.toml" "$DOTFILES_DIR/starship/starship.toml"
fi

# Link waybar configs
if [ -d "$DOTFILES_DIR/waybar" ]; then
    mkdir -p "$CONFIG_DIR/waybar"
    
    # Link all files and directories in waybar directory
    for item in "$DOTFILES_DIR/waybar"/*; do
        if [ -e "$item" ]; then
            filename=$(basename "$item")
            create_symlink "$CONFIG_DIR/waybar/$filename" "$item"
        fi
    done
fi

# Link wofi configs
if [ -d "$DOTFILES_DIR/wofi" ]; then
    mkdir -p "$CONFIG_DIR/wofi"
    for file in "$DOTFILES_DIR/wofi"/*; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            create_symlink "$CONFIG_DIR/wofi/$filename" "$file"
        fi
    done
fi

# Link zathura config
if [ -f "$DOTFILES_DIR/zathura/zathurarc" ]; then
    mkdir -p "$CONFIG_DIR/zathura"
    create_symlink "$CONFIG_DIR/zathura/zathurarc" "$DOTFILES_DIR/zathura/zathurarc"
fi

# Link zsh configs
if [ -d "$DOTFILES_DIR/zsh" ]; then
    mkdir -p "$CONFIG_DIR/zsh"
    for file in "$DOTFILES_DIR/zsh"/*; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            create_symlink "$CONFIG_DIR/zsh/$filename" "$file"
        fi
    done
    
    # Set zsh as default shell if not already set
    if [[ "$SHELL" != *"zsh"* ]]; then
        echo
        echo "Would you like to set zsh as your default shell? (y/N)"
        # Hide cursor during single character input
        tput civis 2>/dev/null
        read -n 1 -r response
        # Show cursor again
        tput cnorm 2>/dev/null
        echo  # Move to a new line after single character input
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            response="y"
        else
            response="n"
        fi
        if [[ "$response" =~ ^([yY])$ ]]; then
            chsh -s "$(which zsh)" || log_warn "Failed to change shell. You may need to do this manually."
        fi
    fi
fi

log_info "Dotfiles installation complete!"

# Verify some key links were created
if [ -L "$CONFIG_DIR/kitty/kitty.conf" ] || [ -L "$CONFIG_DIR/hypr/hyprland.conf" ]; then
    log_info "Installation verified successfully!"
else
    log_warn "Installation completed, but verification could not confirm key links. Please check manually."
fi