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
-   **Wallpaper Manager**: [Hyprpaper](https://github.com/hyprwm/hyprpaper)
-   **Status Bar**: [Waybar](https://github.com/Alexays/Waybar)

## Installation

1. Clone this repository with submodules:

    ```bash
    git clone --recurse-submodules https://github.com/jos-cab/dotfiles.git ~/.dotfiles
    cd ~/.dotfiles
    ```

    If you've already cloned the repository without submodules, run:

    ```bash
    git submodule update --init --recursive
    ```

2. Make the installation script executable and run it:

    ```bash
    chmod +x install.sh
    ./install.sh
    ```

    The script will:

-   Ask if you want to install required dependencies
-   Check for an AUR helper (Paru or Yay) and use it to install AUR packages
-   Ask if you want to backup existing configuration files
-   Create symbolic links from this repo to your `~/.config`
-   Offer to set zsh as your default shell

All prompts use single-key responses for a smoother experience.

> ⚠️ By default, the script will ask if you want to backup existing configuration files.
> If you choose to backup, files will be saved as `<filename>.bak` (or `<filename>.bak.1`, `<filename>.bak.2`, etc. if backups already exist) in the same directory.
> If you choose not to backup, existing files will be removed.
> 
> The script uses single-key prompts for a smoother experience - just press the corresponding key, no need to press Enter.

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

The installation script can automatically install these dependencies for you, or you can install them manually:

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

> Note: The install script will automatically detect if you have `paru` or `yay` installed for AUR packages. If neither is found, you'll need to manually install `hyprpaper`.

## Useful Resources

-   [Hyprland Wiki](https://wiki.hyprland.org/)
-   [ArchWiki: Wayland](https://wiki.archlinux.org/title/Wayland)
-   [Awesome Hyprland](https://github.com/hyprland-community/awesome-hyprland)

## License

These dotfiles are available as open source under the terms of the [MIT License](LICENSE).
