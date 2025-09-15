#!/usr/bin/env bash

# Dotfiles installation script
# Creates symlinks from ~/.config to dotfiles directory

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

# Check if dotfiles directory exists
check_dotfiles_dir() {
    if [ ! -d "$DOTFILES_DIR" ]; then
        log_error "Dotfiles directory $DOTFILES_DIR does not exist!"
        exit 1
    fi
}

DOTFILES_DIR="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"

# Validate environment
check_system
check_dotfiles_dir

log_info "Installing dotfiles..."
log_info "Dotfiles directory: $DOTFILES_DIR"
log_info "Config directory: $CONFIG_DIR"

# Create necessary directories if they don't exist
mkdir -p "$CONFIG_DIR"

# Function to create symlink
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
    
    # Remove existing file/directory/link if it exists
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        echo "Removing existing $dest"
        rm -rf "$dest"
    fi
    
    # Create symlink from ~/.config to dotfiles
    echo "Linking $dest -> $source"
    ln -sf "$source" "$dest"
}

# Function to recursively link directory contents
# $1 = destination base path, $2 = source base path
link_directory_recursively() {
    local dest_base="$1"
    local source_base="$2"
    
    # Validate inputs
    if [ -z "$dest_base" ] || [ -z "$source_base" ]; then
        echo "Error: link_directory_recursively requires both destination and source base paths"
        return 1
    fi
    
    # Find all files and directories (excluding .git) and link them
    while IFS= read -r -d '' item; do
        # Get relative path from source base
        rel_path="${item#$source_base/}"
        if [[ -n "$rel_path" ]]; then
            # Only create symlink if the item is a regular file or directory (not already a symlink)
            if [ -f "$item" ] || [ -d "$item" ]; then
                create_symlink "$dest_base/$rel_path" "$item"
            fi
        fi
    done < <(find "$source_base" -mindepth 1 -not -path "*/.git/*" -print0)
}

# Link ananicy directory (with full recursive structure)
if [ -d "$DOTFILES_DIR/ananicy" ]; then
    # For ananicy, we'll create symlinks for files and directories directly
    # This preserves the directory structure without creating circular references
    for item in "$DOTFILES_DIR/ananicy"/*; do
        if [ -e "$item" ]; then
            filename=$(basename "$item")
            create_symlink "$CONFIG_DIR/ananicy/$filename" "$item"
        fi
    done
fi

# Link hyprland configs to hypr directory
if [ -d "$DOTFILES_DIR/hyprland" ]; then
    # Create hypr directory
    mkdir -p "$CONFIG_DIR/hypr"
    
    # Link all files in hyprland directory
    for file in "$DOTFILES_DIR/hyprland"/*; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            create_symlink "$CONFIG_DIR/hypr/$filename" "$file"
        fi
    done
    
    # Link scripts directory if it exists
    if [ -d "$DOTFILES_DIR/hyprland/scripts" ]; then
        mkdir -p "$CONFIG_DIR/hypr/scripts"
        for script in "$DOTFILES_DIR/hyprland/scripts"/*; do
            if [ -f "$script" ]; then
                scriptname=$(basename "$script")
                create_symlink "$CONFIG_DIR/hypr/scripts/$scriptname" "$script"
            fi
        done
    fi
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

# Link ranger configs
if [ -d "$DOTFILES_DIR/ranger" ]; then
    mkdir -p "$CONFIG_DIR/ranger"
    for file in "$DOTFILES_DIR/ranger"/*; do
        # Skip colorschemes, plugins, and rc.conf.d directories as we'll handle them separately
        filename=$(basename "$file")
        if [ "$filename" = "colorschemes" ] || [ "$filename" = "plugins" ] || [ "$filename" = "rc.conf.d" ]; then
            continue
        fi
        if [ -f "$file" ] || [ -d "$file" ]; then
            create_symlink "$CONFIG_DIR/ranger/$filename" "$file"
        fi
    done
    
    # Handle rc.conf.d directory - create directory and link individual files
    if [ -d "$DOTFILES_DIR/ranger/rc.conf.d" ]; then
        mkdir -p "$CONFIG_DIR/ranger/rc.conf.d"
        for file in "$DOTFILES_DIR/ranger/rc.conf.d"/*; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                create_symlink "$CONFIG_DIR/ranger/rc.conf.d/$filename" "$file"
            fi
        done
    fi
    
    # Link colorschemes directory
    if [ -d "$DOTFILES_DIR/ranger/colorschemes" ]; then
        link_directory_recursively "$CONFIG_DIR/ranger/colorschemes" "$DOTFILES_DIR/ranger/colorschemes"
    fi
    
    # Plugins
    if [ -d "$DOTFILES_DIR/ranger/plugins" ]; then
        mkdir -p "$CONFIG_DIR/ranger/plugins"
        for dir in "$DOTFILES_DIR/ranger/plugins"/*/; do
            if [ -d "$dir" ]; then
                dirname=$(basename "$dir")
                # Remove trailing slash
                dir="${dir%/}"
                create_symlink "$CONFIG_DIR/ranger/plugins/$dirname" "$dir"
            fi
        done
    fi
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
    for file in "$DOTFILES_DIR/waybar"/*; do
        # Skip scripts directory as we'll handle it separately
        filename=$(basename "$file")
        if [ "$filename" = "scripts" ]; then
            continue
        fi
        if [ -f "$file" ] || [ -d "$file" ]; then
            create_symlink "$CONFIG_DIR/waybar/$filename" "$file"
        fi
    done
    
    # Link scripts directory if it exists
    if [ -d "$DOTFILES_DIR/waybar/scripts" ]; then
        mkdir -p "$CONFIG_DIR/waybar/scripts"
        for script in "$DOTFILES_DIR/waybar/scripts"/*; do
            if [ -f "$script" ]; then
                scriptname=$(basename "$script")
                create_symlink "$CONFIG_DIR/waybar/scripts/$scriptname" "$script"
            fi
        done
    fi
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
fi

log_info "Dotfiles installation complete!"

# Verify some key links were created
if [ -L "$CONFIG_DIR/kitty/kitty.conf" ] || [ -L "$CONFIG_DIR/hypr/hyprland.conf" ]; then
    log_info "Installation verified successfully!"
else
    log_warn "Installation completed, but verification could not confirm key links. Please check manually."
fi