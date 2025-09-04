# dotfiles

Arch Linux + Hyprland setup

## Screenshots

_(Add your own screenshots here to showcase your setup)_

## Overview

This repository contains my personal configuration files (dotfiles) for an **Arch Linux** system running the [Hyprland](https://hyprland.org/) tiling Wayland compositor.  
It includes configurations for my shell, terminal, bar, launcher, notifications, and other daily driver tools.

## System Information

-   **OS**: Arch Linux
-   **WM/Compositor**: [Hyprland](https://hyprland.org/)
-   **Shell**: [Zsh](https://www.zsh.org/) with [Starship](https://starship.rs/) prompt
-   **Terminal**: [Kitty](https://sw.kovidgoyal.net/kitty/)
-   **Notification Daemon**: [Mako](https://github.com/emersion/mako)
-   **Application Launcher**: [Wofi](https://hg.sr.ht/~scoopta/wofi)
-   **Wallpaper Manager**: [Hyprpaper](https://github.com/hyprland-community/hyprpaper)
-   **Status Bar**: [Waybar](https://github.com/Alexays/Waybar)

## Installation

1. Clone this repository:

    ```bash
    git clone https://github.com/jos-cab/dotfiles.git ~/.dotfiles
    cd ~/.dotfiles
    ```

2. Make the installation script executable and run it:

    ```bash
    chmod +x install.sh
    ./install.sh
    ```

    The script will:

-   Ask if you want to install critical dependencies (Hyprland, Kitty, Waybar, etc.)
-   Offer to install an AUR helper (Paru) if you don’t have one
-   Create symbolic links from this repo to your `~/.config`
-   Automatically back up any existing config files if you choose to
-   Set up your shell (`zsh`) to source your custom config

> ⚠️ Any existing configuration files will be backed up automatically if you choose to.
> Backups are saved as `<filename>.bak` in the same directory.

## Key Features

### Hyprland

-   Dynamic tiling with custom keybindings
-   Multiple monitor support
-   Custom animations and transitions
-   Application-specific rules
-   Workspace management

### Zsh + Starship

-   Fast, minimal shell prompt
-   Git integration
-   Custom aliases and functions
-   Syntax highlighting
-   Autosuggestions

### Waybar

-   CPU, memory, and temperature monitoring
-   Audio controls
-   System tray support
-   Date and time
-   Workspaces module
-   Catppuccin Mocha-inspired CSS styling

## Dependencies

To use these configurations, you’ll need the following packages:

```bash
# Core components
sudo pacman -S hyprland kitty waybar wofi mako

# Shell and prompt
sudo pacman -S zsh starship

# Wallpaper manager (AUR)
paru -S hyprpaper   # or yay -S hyprpaper

# Extra utilities
sudo pacman -S brightnessctl pavucontrol \
    xdg-desktop-portal-hyprland grim slurp wl-clipboard
```

## Useful Resources

-   [Hyprland Wiki](https://wiki.hyprland.org/)
-   [ArchWiki: Wayland](https://wiki.archlinux.org/title/Wayland)
-   [Awesome Hyprland](https://github.com/hyprland-community/awesome-hyprland)

## License

These dotfiles are available as open source under the terms of the [MIT License](LICENSE).
