#!/usr/bin/env bash

# Dotfiles installation script
# Creates symlinks from ~/.config to dotfiles directory
# Usage: ./install.sh

set -eE  # Exit on any error, including functions

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

check_dependencies() {
    local missing=()
    local command
    for command in hyprland kitty waybar wofi mako zsh starship nvim fastfetch; do
        command -v "$command" >/dev/null 2>&1 || missing+=("$command")
    done

    if [ "${#missing[@]}" -gt 0 ]; then
        log_warn "Required commands missing: ${missing[*]}"
        log_warn "Choose dependency installation or install them manually before using this config."
    fi
}

# Filesystem changes use physical paths under canonical $HOME. Parent symlinks
# are rejected; final destinations may be symlinks and are backed up intact.
DO_BACKUPS=true
ASSUME_YES=false
TRANSACTION_ACTIVE=false
ROLLING_BACK=false
RECOVERY_REQUIRED=()
CREATED_LINKS=()
CREATED_LINK_TARGETS=()
CREATED_DIRS=()
LINK_COUNT=0
BACKUP_SOURCES=()
BACKUP_PATHS=()

path_exists() { [ -e "$1" ] || [ -L "$1" ]; }
report_recovery() { RECOVERY_REQUIRED+=("$1"); }

validate_home_path() {
    local path="$1" parent
    case "$path" in "$CANONICAL_HOME"|"$CANONICAL_HOME"/*) ;; *) log_error "Path escapes HOME: $path"; return 1 ;; esac
    [ "$path" = "$CANONICAL_HOME" ] && return
    parent=$(dirname "$path")
    while [ "$parent" != "$CANONICAL_HOME" ]; do
        if path_exists "$parent"; then
            [ -d "$parent" ] && [ ! -L "$parent" ] || { log_error "Unsafe parent directory: $parent"; return 1; }
        fi
        parent=$(dirname "$parent")
    done
}

ensure_directory() {
    local dir="$1" parent
    validate_home_path "$dir"
    if path_exists "$dir"; then
        [ -d "$dir" ] && [ ! -L "$dir" ] || { log_error "Expected real directory, found $dir"; return 1; }
        return
    fi
    parent=$(dirname "$dir")
    [ "$parent" = "$dir" ] || ensure_directory "$parent"
    if [ "${INSTALL_MKDIR_FAIL:-}" = "$dir" ] || ! command mkdir "$dir"; then
        log_error "Could not create directory $dir"; return 1
    fi
    CREATED_DIRS+=("$dir")
}

rollback() {
    local i link expected_target actual_target source backup dir
    [ "$ROLLING_BACK" = true ] && return
    ROLLING_BACK=true
    log_error "Installation interrupted; restoring filesystem state..."
    for ((i=${#CREATED_LINKS[@]} - 1; i >= 0; i--)); do
        link=${CREATED_LINKS[i]}; expected_target=${CREATED_LINK_TARGETS[i]}
        if path_exists "$link"; then
            actual_target=$(readlink "$link" 2>/dev/null || true)
            if [ "$actual_target" != "$expected_target" ]; then
                report_recovery "$link (changed destination: $actual_target)"
            elif [ "${INSTALL_REMOVE_FAIL:-}" = "$link" ] || ! rm -f "$link"; then
                report_recovery "$link (created link could not be removed)"
            fi
        fi
    done
    if [ -n "${INSTALL_REAPPEAR_DEST:-}" ]; then
        printf '%s' "${INSTALL_REAPPEAR_CONTENT:-new destination}" > "$INSTALL_REAPPEAR_DEST"
    fi
    if [ -n "${INSTALL_REPLACE_LINK:-}" ]; then
        rm -f "$INSTALL_REPLACE_LINK"
        ln -s "${INSTALL_REPLACE_TARGET:-/changed}" "$INSTALL_REPLACE_LINK"
    fi
    for ((i=${#BACKUP_SOURCES[@]} - 1; i >= 0; i--)); do
        source=${BACKUP_SOURCES[i]}; backup=${BACKUP_PATHS[i]}
        path_exists "$backup" || continue
        if path_exists "$source"; then
            report_recovery "$source (new destination) and $backup (backup)"
        elif [[ ",${INSTALL_RESTORE_FAIL:-}," == *",$source,"* ]] || ! mv -n "$backup" "$source" || path_exists "$backup" || ! path_exists "$source"; then
            report_recovery "$source (backup: $backup)"
        fi
    done
    for ((i=${#CREATED_DIRS[@]} - 1; i >= 0; i--)); do
        dir=${CREATED_DIRS[i]}
        rmdir "$dir" 2>/dev/null || report_recovery "$dir (created directory could not be removed)"
    done
    if [ "${#RECOVERY_REQUIRED[@]}" -gt 0 ]; then
        log_error "Manual recovery required for: ${RECOVERY_REQUIRED[*]}"
    fi
}

finish_failure() { local status=$1; [ "$TRANSACTION_ACTIVE" = true ] && rollback; trap - ERR INT TERM; exit "$status"; }
on_error() { finish_failure "$?"; }
on_signal() { log_error "Installation interrupted"; finish_failure "$1"; }
trap on_error ERR
trap 'on_signal 130' INT
trap 'on_signal 143' TERM

backup_if_exists() {
    local file="$1" backup="${1}.bak" counter=1
    path_exists "$file" || return
    validate_home_path "$file"
    while path_exists "$backup"; do backup="${file}.bak.${counter}"; counter=$((counter + 1)); done
    echo "Backing up $file -> $backup"
    if [ "${INSTALL_BACKUP_FAIL:-}" = "$file" ] || ! mv "$file" "$backup"; then
        log_error "Could not back up $file"; return 1
    fi
    BACKUP_SOURCES+=("$file")
    BACKUP_PATHS+=("$backup")
}

# $1 = destination, $2 = source
create_symlink() {
    local dest="$1" source="$2"
    [[ -n "$dest" && -n "$source" ]] || { log_error "create_symlink requires destination and source"; return 1; }
    validate_home_path "$dest"
    ensure_directory "$(dirname "$dest")"
    validate_home_path "$dest"
    if path_exists "$dest"; then
        [ "$DO_BACKUPS" = true ] || { log_error "Refusing to replace existing $dest"; return 1; }
        backup_if_exists "$dest"
    fi
    echo "Linking $dest -> $source"
    if [ "${INSTALL_LINK_FAIL:-}" = "$dest" ] || ! ln -s "$source" "$dest"; then
        log_error "Could not link $dest"; return 1
    fi
    CREATED_LINKS+=("$dest")
    CREATED_LINK_TARGETS+=("$source")
    LINK_COUNT=$((LINK_COUNT + 1))
    if [ -n "${INSTALL_SIGNAL_AFTER:-}" ] && [ "$INSTALL_SIGNAL_AFTER" -eq "$LINK_COUNT" ]; then kill "-${INSTALL_SIGNAL_KIND:-TERM}" "$$"; fi
    if [ -n "${INSTALL_PAUSE_AFTER:-}" ] && [ "$INSTALL_PAUSE_AFTER" -eq "$LINK_COUNT" ]; then sleep 5; fi
    if [ -n "${INSTALL_FAIL_AFTER:-}" ] && [ "$INSTALL_FAIL_AFTER" -eq "$LINK_COUNT" ]; then
        log_error "Injected filesystem failure after $LINK_COUNT links"; return 1
    fi
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

    if ! sudo -n true 2>/dev/null; then
        log_warn "Passwordless sudo unavailable. Skipping system ananicy configuration."
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
CANONICAL_HOME=$(cd "$HOME" && pwd -P) || { log_error "Cannot resolve HOME"; exit 1; }
HOME="$CANONICAL_HOME"
CONFIG_DIR="$HOME/.config"

if [ "${1:-}" = "--yes" ]; then
    ASSUME_YES=true
elif [ -n "${1:-}" ]; then
    log_error "Unknown option: $1"
    exit 2
fi

prompt_backup() {
    [ "$ASSUME_YES" = true ] && return
    if [ ! -t 0 ]; then
        log_error "Non-interactive install requires explicit authorization: --yes"
        exit 2
    fi
    echo
    echo "Back up existing configuration before linking? (Y/n)"
    tput civis 2>/dev/null
    IFS= read -r -n 1 response || { tput cnorm 2>/dev/null; log_error "No backup authorization received"; exit 2; }
    tput cnorm 2>/dev/null
    echo
    case "$response" in
        ''|[yY]) ;;
        *) log_error "Installation aborted: backups are required to preserve existing configuration."; exit 2 ;;
    esac
}

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

prompt_backup

log_info "Installing dotfiles..."
log_info "Dotfiles directory: $DOTFILES_DIR"
log_info "Config directory: $CONFIG_DIR"
log_info "Backup existing files: $DO_BACKUPS"

# Begin only after validation/prompt paths; failures from here roll back $HOME changes.
TRANSACTION_ACTIVE=true
# Create necessary directories if they don't exist
ensure_directory "$CONFIG_DIR"

shopt -s nullglob

# Ask user if they want to install dependencies
response="n"
if [ "$ASSUME_YES" != true ]; then
    echo
    echo "Would you like to install required dependencies? (y/N)"
    tput civis 2>/dev/null
    IFS= read -r -n 1 response || response="n"
    tput cnorm 2>/dev/null
    echo
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        response="y"
    else
        response="n"
    fi
fi
if [[ "$response" =~ ^([yY])$ ]]; then
    # Check if pacman is available
    if command -v pacman &> /dev/null; then
        log_info "Installing core components..."
        sudo pacman -S \
            hyprland hyprpicker kitty waybar wofi mako awww fastfetch \
            ttf-jetbrains-mono-nerd zsh starship eza bat fzf yazi \
            neovim thunar imv zathura zathura-pdf-mupdf \
            spotify-launcher discord udiskie playerctl \
            brightnessctl pavucontrol libnotify unarchiver \
            pipewire pipewire-alsa pipewire-pulse wireplumber \
            xdg-desktop-portal-hyprland grim slurp wl-clipboard cliphist \
            ananicy-cpp pacman-contrib curl jq \
            tesseract tesseract-data-eng tesseract-data-spa zbar \
            --noconfirm || log_warn "Failed to install some packages. Please install manually."
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

check_dependencies

# Link ananicy configs
if [ -d "$DOTFILES_DIR/ananicy" ]; then
    ensure_directory "$CONFIG_DIR/ananicy"
    
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
    ensure_directory "$CONFIG_DIR/hypr"
    
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
        ensure_directory "$CONFIG_DIR/$gtk_version"
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
    ensure_directory "$CONFIG_DIR/imv"
    create_symlink "$CONFIG_DIR/imv/config" "$DOTFILES_DIR/imv/config"
fi

# Link fastfetch config
if [ -d "$DOTFILES_DIR/fastfetch" ]; then
    ensure_directory "$CONFIG_DIR/fastfetch"
    for file in "$DOTFILES_DIR/fastfetch"/*; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            create_symlink "$CONFIG_DIR/fastfetch/$filename" "$file"
        fi
    done
fi

# Link kitty configs
if [ -d "$DOTFILES_DIR/kitty" ]; then
    ensure_directory "$CONFIG_DIR/kitty"
    for file in "$DOTFILES_DIR/kitty"/*; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            create_symlink "$CONFIG_DIR/kitty/$filename" "$file"
        fi
    done
fi

# Link mako config
if [ -f "$DOTFILES_DIR/mako/config" ]; then
    ensure_directory "$CONFIG_DIR/mako"
    create_symlink "$CONFIG_DIR/mako/config" "$DOTFILES_DIR/mako/config"
fi

# Link nvim configs
if [ -d "$DOTFILES_DIR/nvim" ]; then
    ensure_directory "$CONFIG_DIR/nvim"
    
    # Link all files and directories in nvim directory
    for item in "$DOTFILES_DIR/nvim"/*; do
        [ -e "$item" ] || continue
        filename=$(basename "$item")

        # docs/ is documentation, not config
        if [ "$filename" = "docs" ]; then
            continue
        fi

        create_symlink "$CONFIG_DIR/nvim/$filename" "$item"
    done
fi

# Link starship config
if [ -f "$DOTFILES_DIR/starship/starship.toml" ]; then
    ensure_directory "$CONFIG_DIR/starship"
    create_symlink "$CONFIG_DIR/starship/starship.toml" "$DOTFILES_DIR/starship/starship.toml"
fi

# Also link to root of config directory for compatibility
if [ -f "$DOTFILES_DIR/starship/starship.toml" ]; then
    create_symlink "$CONFIG_DIR/starship.toml" "$DOTFILES_DIR/starship/starship.toml"
fi

# Link waybar configs
if [ -d "$DOTFILES_DIR/waybar" ]; then
    ensure_directory "$CONFIG_DIR/waybar"
    
    # Link all files and directories in waybar directory
    for item in "$DOTFILES_DIR/waybar"/*; do
        if [ -e "$item" ]; then
            filename=$(basename "$item")
            
            # Special handling for scripts directory
            if [ "$filename" = "scripts" ] && [ -d "$item" ]; then
                ensure_directory "$CONFIG_DIR/waybar/scripts"
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
    ensure_directory "$CONFIG_DIR/wofi"
    for file in "$DOTFILES_DIR/wofi"/*; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            create_symlink "$CONFIG_DIR/wofi/$filename" "$file"
        fi
    done
fi

# Link zathura config
if [ -f "$DOTFILES_DIR/zathura/zathurarc" ]; then
    ensure_directory "$CONFIG_DIR/zathura"
    create_symlink "$CONFIG_DIR/zathura/zathurarc" "$DOTFILES_DIR/zathura/zathurarc"
fi

# Install theme selector
if [ -x "$DOTFILES_DIR/theme" ]; then
    ensure_directory "$HOME/.local/bin"
    create_symlink "$HOME/.local/bin/dotfiles-theme" "$DOTFILES_DIR/theme"
fi

# Link zsh configs
if [ -d "$DOTFILES_DIR/zsh" ]; then
    ensure_directory "$CONFIG_DIR/zsh"

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

TRANSACTION_ACTIVE=false
log_info "Dotfiles installation complete!"

# Verify some key links were created
missing_links=""
for link in "$CONFIG_DIR/kitty/kitty.conf" "$CONFIG_DIR/hypr/hyprland.lua" \
            "$CONFIG_DIR/nvim/init.lua" "$CONFIG_DIR/waybar/config.jsonc" \
            "$HOME/.zshrc"; do
    [ -L "$link" ] || missing_links="$missing_links $link"
done

if [ -z "$missing_links" ]; then
    log_info "Installation verified successfully!"
else
    log_warn "Installation completed, but these links are missing:$missing_links"
fi
