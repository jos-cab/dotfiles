#!/usr/bin/env bash

# Dotfiles installation script
# Creates symlinks from ~/.config to dotfiles directory
# Usage: ./install.sh

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

# ananicy-cpp runs as a system service with ProtectHome=yes, so it cannot
# reliably read rules from ~/.config. Install the rules into its system path.
configure_ananicy() {
    local source_dir="$DOTFILES_DIR/ananicy"
    local system_dir="/etc/ananicy.d"

    if [ ! -d "$source_dir" ]; then
        return
    fi

    if ! command -v ananicy-cpp &> /dev/null; then
        log_warn "ananicy-cpp is not installed. Skipping system ananicy configuration."
        return
    fi

    log_info "Configuring ananicy-cpp system rules..."
    sudo install -d -m 0755 "$system_dir"

    for file in "$source_dir"/*.conf "$source_dir"/*.types "$source_dir"/*.cgroups; do
        [ -f "$file" ] || continue
        sudo install -m 0644 "$file" "$system_dir/$(basename "$file")"
    done

    if [ -d "$source_dir/00-default" ]; then
        sudo cp -a "$source_dir/00-default" "$system_dir/"
    fi

    if command -v systemctl &> /dev/null; then
        sudo systemctl enable --now ananicy-cpp.service \
            || log_warn "Failed to enable/start ananicy-cpp.service. Please check it manually."
        sudo systemctl restart ananicy-cpp.service \
            || log_warn "Failed to restart ananicy-cpp.service. Please restart it manually."
    else
        log_warn "systemctl not found. Please enable/start ananicy-cpp.service manually."
    fi
}

check_pipewire_status() {
    if command -v systemctl &> /dev/null; then
        log_info "Checking PipeWire user service status..."
        systemctl --user --no-pager status pipewire pipewire-pulse wireplumber \
            || log_warn "One or more PipeWire user services are not active. Please check them manually."
    else
        log_warn "systemctl not found. Please check PipeWire services manually."
    fi
}

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

# Validate environment
check_system

# Initialize git submodules if needed
if [ -f "$DOTFILES_DIR/.gitmodules" ]; then
    log_info "Initializing git submodules..."
    git -C "$DOTFILES_DIR" submodule update --init --recursive
fi

# Check if we have the expected directories
if [ ! -d "$DOTFILES_DIR/kitty" ] && [ ! -d "$DOTFILES_DIR/hyprland" ]; then
    log_error "This doesn't appear to be a dotfiles directory. Expected to find kitty or hyprland directories."
    exit 1
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
        sudo pacman -S hyprland hyprpicker kitty waybar wofi mako awww zsh starship bat yazi ananicy-cpp brightnessctl pavucontrol pipewire pipewire-alsa pipewire-pulse wireplumber xdg-desktop-portal-hyprland grim slurp wl-clipboard zathura zathura-pdf-mupdf tesseract tesseract-data-eng tesseract-data-spa noto-fonts-cjk unarchiver atool --noconfirm || log_warn "Failed to install some packages. Please install manually."
        check_pipewire_status
        
        # Check for AUR helper
        if command -v paru &> /dev/null || command -v yay &> /dev/null; then
            log_info "Installing AUR packages..."
            if command -v paru &> /dev/null; then
                paru -S obsidian brave-bin qogir-cursor-theme-git --noconfirm || log_warn "Failed to install some AUR packages. Please install manually."
            else
                yay -S obsidian brave-bin qogir-cursor-theme-git --noconfirm || log_warn "Failed to install some AUR packages. Please install manually."
            fi
        else
            log_warn "No AUR helper found. Please install obsidian, brave-bin, and qogir-cursor-theme-git manually if needed."
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

    configure_ananicy
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

# Link GTK configs
for gtk_version in gtk-3.0 gtk-4.0; do
    if [ -d "$DOTFILES_DIR/$gtk_version" ]; then
        mkdir -p "$CONFIG_DIR/$gtk_version"
        for file in "$DOTFILES_DIR/$gtk_version"/*; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                create_symlink "$CONFIG_DIR/$gtk_version/$filename" "$file"
            fi
        done
    fi
done

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
            
            # Special handling for lua directory
            if [ "$filename" = "lua" ] && [ -d "$item" ]; then
                mkdir -p "$CONFIG_DIR/nvim/lua"
                
                # Link each lua module individually
                for module in "$item"/*; do
                    if [ -e "$module" ]; then
                        module_name=$(basename "$module")
                        create_symlink "$CONFIG_DIR/nvim/lua/$module_name" "$module"
                    fi
                done
            else
                create_symlink "$CONFIG_DIR/nvim/$filename" "$item"
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
            
            # Special handling for scripts directory
            if [ "$filename" = "scripts" ] && [ -d "$item" ]; then
                mkdir -p "$CONFIG_DIR/waybar/scripts"
                for script in "$item"/*; do
                    if [ -e "$script" ]; then
                        script_name=$(basename "$script")
                        create_symlink "$CONFIG_DIR/waybar/scripts/$script_name" "$script"
                    fi
                done
            else
                create_symlink "$CONFIG_DIR/waybar/$filename" "$item"
            fi
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
        [ -f "$file" ] || continue

        filename=$(basename "$file")

        # zshrc is stored without a leading dot in the repo, but belongs in HOME.
        if [ "$filename" = "zshrc" ] || [ "$filename" = ".zshrc" ]; then
            create_symlink "$HOME/.zshrc" "$file"
        else
            # everything else goes in ~/.config/zsh
            create_symlink "$CONFIG_DIR/zsh/$filename" "$file"
        fi
    done

    # Set zsh as default shell if not already set
    if [[ "$SHELL" != *"zsh"* ]]; then
        echo
        echo "Would you like to set zsh as your default shell? (y/N)"

        tput civis 2>/dev/null
        read -n 1 -r response
        tput cnorm 2>/dev/null
        echo

        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            zsh_path="$(command -v zsh || true)"
            if [ -n "$zsh_path" ]; then
                chsh -s "$zsh_path" \
                    || log_warn "Failed to change shell. You may need to do this manually."
            else
                log_warn "zsh is not installed or not in PATH. Please install it before changing your default shell."
            fi
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
