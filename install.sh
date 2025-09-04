#!/bin/bash

# Dotfiles installation script
set -e  # Exit on any error

echo "Installing dotfiles..."

# -------------------------------
# Helper functions
# -------------------------------

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Paru AUR helper if missing
install_paru() {
    echo "Installing Paru AUR helper..."
    
    if command_exists paru; then
        echo "Paru is already installed."
        return 0
    fi
    
    sudo pacman -S --noconfirm base-devel git
    
    TMP_DIR=$(mktemp -d)
    cd "$TMP_DIR"
    
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    
    cd -
    rm -rf "$TMP_DIR"
    
    echo "Paru installation complete."
}

# Install packages on Arch Linux
install_packages() {
    if command_exists pacman; then
        echo "Installing critical dependencies..."
        sudo pacman -Syu --noconfirm
        
        sudo pacman -S --noconfirm \
            hyprland kitty waybar wofi mako zsh starship \
            brightnessctl pavucontrol
        
        # Extras for Hyprland ecosystem
        sudo pacman -S --noconfirm \
            xdg-desktop-portal-hyprland grim slurp wl-clipboard
        
        # Install hyprpaper via AUR helper if available
        if command_exists yay; then
            yay -S --noconfirm hyprpaper
        elif command_exists paru; then
            paru -S --noconfirm hyprpaper
        else
            echo "No AUR helper found. Installing Paru..."
            install_paru
            paru -S --noconfirm hyprpaper
        fi
    else
        echo "pacman not found. Please install dependencies manually."
    fi
}

# Create symlink with optional backup
link_config() {
    local source="$1"
    local target="$2"

    if [ -e "$target" ]; then
        echo "$target already exists."
        read -r -p "Do you want to back it up before replacing? (y/N) " backup_response
        backup_response=${backup_response:-N}
        if [[ "$backup_response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            mv "$target" "${target}.bak"
            echo "Backup created at ${target}.bak"
        fi
        rm -f "$target"
    fi

    mkdir -p "$(dirname "$target")"
    ln -sf "$source" "$target"
    echo "Linked $source to $target"
}

# -------------------------------
# Dependency installation
# -------------------------------

read -r -p "Do you want to install critical dependencies? (y/N) " response
response=${response:-N}
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    if ! command_exists yay && ! command_exists paru; then
        read -r -p "No AUR helper detected. Install Paru? (y/N) " paru_response
        paru_response=${paru_response:-N}
        if [[ "$paru_response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            install_paru
        fi
    fi
    install_packages
else
    echo "Skipping dependency installation."
fi

# -------------------------------
# Config installation
# -------------------------------

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Hyprland configs
mkdir -p ~/.config/hypr
for file in "$DOTFILES_DIR/hyprland"/*; do
    filename=$(basename "$file")
    if [ "$filename" = "hyprpaper.conf" ]; then
        link_config "$DOTFILES_DIR/hyprpaper/config" "$HOME/.config/hypr/hyprpaper.conf"
    else
        link_config "$file" "$HOME/.config/hypr/$filename"
    fi
done

# Other configs
for dir in kitty mako starship waybar wofi zsh; do
    mkdir -p "$HOME/.config/$dir"
    for file in "$DOTFILES_DIR/$dir"/*; do
        filename=$(basename "$file")
        link_config "$file" "$HOME/.config/$dir/$filename"
    done
done

# -------------------------------
# Zsh integration
# -------------------------------

if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "source ~/.config/zsh/zshrc" "$HOME/.zshrc"; then
        echo -e "\n# Source custom zsh configuration\nsource ~/.config/zsh/zshrc" >> "$HOME/.zshrc"
        echo "Updated .zshrc to source custom configuration"
    fi
else
    echo "source ~/.config/zsh/zshrc" > "$HOME/.zshrc"
    echo "Created .zshrc to source custom configuration"
fi

echo "Installation complete!"
echo "Please restart your shell or run 'source ~/.zshrc' to apply changes."
