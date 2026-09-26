# dotfiles

Arch Linux + Hyprland setup

## Overview

Personal configuration files (dotfiles) for an **Arch Linux** system running the
[Hyprland](https://hyprland.org/) tiling Wayland compositor. The Hyprland config
is written in **Lua** and split into modules under `hyprland/`.

| Component | Config in this repo | Software |
| --- | --- | --- |
| Compositor | `hyprland/` | Hyprland (Lua config) |
| Shell | `zsh/` | Zsh + Starship + Zinit |
| Terminal | `kitty/` | Kitty |
| Status bar | `waybar/` | Waybar (bar + dock) |
| Launcher / menus | `wofi/` | Wofi |
| Notifications | `mako/` | Mako |
| Wallpapers | `awww-daemon` (autostart) | awww |
| Editor | `nvim/` | Neovim + LazyVim |
| PDF reader | `zathura/` | Zathura |
| Image viewer | `imv/config` | imv |
| Process priority | `ananicy/` | ananicy-cpp (submodule) |

## System Information

-   **OS**: Arch Linux
-   **WM/Compositor**: [Hyprland](https://hyprland.org/) (modular Lua config)
-   **Shell**: [Zsh](https://www.zsh.org/) with [Starship](https://starship.rs/) prompt
-   **Terminal**: [Kitty](https://sw.kovidgoyal.net/kitty/)
-   **Status Bar**: [Waybar](https://github.com/Alexays/Waybar)
-   **Application Launcher**: [Wofi](https://hg.sr.ht/~scoopta/wofi)
-   **Notification Daemon**: [Mako](https://github.com/emersion/mako)
-   **Wallpaper Manager**: [awww](https://codeberg.org/LGFae/awww)
-   **Editor**: [Neovim](https://neovim.io/) with [LazyVim](https://www.lazyvim.org/)
-   **PDF Reader**: [Zathura](https://github.com/pwmt/zathura)
-   **Image Viewer**: [imv](https://github.com/ocs2/go-imv)
-   **Process Scheduler**: [ananicy-cpp](https://github.com/CachyOS/ananicy-rules)

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
-   Copy the `ananicy` rules to `/etc/ananicy.d` and enable `ananicy-cpp.service`
-   Install `dotfiles-theme` in `~/.local/bin`
-   Check the status of the PipeWire user services
-   Offer to set zsh as your default shell

    All prompts use single-key responses for a smoother experience.

3. Configure local secrets if using 9Router:

    ```bash
    cp ~/.config/hypr/local.lua.example ~/.config/hypr/local.lua
    chmod 600 ~/.config/hypr/local.lua
    $EDITOR ~/.config/hypr/local.lua
    ```

    Keep `local.lua` outside Git.


> ⚠️ By default, the script will ask if you want to backup existing configuration files.
> If you choose to backup, files will be saved as `<filename>.bak` (or `<filename>.bak.1`, `<filename>.bak.2`, etc. if backups already exist) in the same directory.
> If you choose not to backup, existing files will be removed.
>
> `~/.zshrc` is symlinked from `zsh/zshrc`; every other zsh file goes to `~/.config/zsh/`.
>
> The script uses single-key prompts for a smoother experience - just press the corresponding key, no need to press Enter.

## Key Features

### Hyprland

-   Modular **Lua** config (`monitors`, `programs`, `autostart`, `environment`, `ecosystem`, `appearance`, `animations`, `layouts`, `input`, `keybinds`, `windowrules`)
-   Dynamic tiling with vim-like and arrow-key navigation
-   Multiple monitor support
-   Custom animations and transitions
-   Application-specific rules
-   Workspace management plus a scratchpad workspace
-   Runtime gap / border / rounding adjustment bound to the keyboard
-   Screenshot, OCR and QR-code capture straight to the clipboard

### Zsh + Starship

-   Modular config under `~/.config/zsh/` (aliases, functions, completions, integrations)
-   Fast syntax highlighting and autosuggestions via Zinit
-   Catppuccin Mocha colors throughout (`eza`, `bat`, prompt)

### Centralized theme

-   Source palettes live in `themes/*.conf`; generated configs use templates under `themes/templates/`
-   Available themes: Catppuccin Mocha/Macchiato, Tokyo Night, Gruvbox Dark, Nord, Dracula, Rosé Pine and One Dark
-   Apply a palette across Hyprland, Kitty, Waybar, Wofi, Mako and Zathura:

    ```bash
    dotfiles-theme themes/tokyo-night.conf
    ```

-   Neovim, GTK and Qt themes remain separate: they require their own installed theme packages/plugins.

## Keybindings

| Shortcut | Action |
| --- | --- |
| `Super + Enter` | Open Kitty |
| `Super + E` | Open Thunar |
| `Super + B` | Open Brave |
| `Super + D` | Open Discord |
| `Super + S` | Open Spotify |
| `Super + M` | Open Wofi |
| `Super + C` | Close window |
| `Super + V` / `Super + Space` | Toggle floating |
| `Super + Shift + Q` | Exit Hyprland |
| `Super + H/J/K/L` | Focus left/down/up/right |
| `Super + Shift + H/J/K/L` | Move window |
| `Super + '` | Show/hide the special workspace (`magic`) |
| `Super + Shift + '` | Move the active window to the special workspace |
| `Super + 1..0` | Switch workspace 1..10 |
| `Super + Shift + 1..0` | Move window to workspace |
| `Super + U` | System update menu |
| `Super + P` | Color picker |
| `Super + Shift + V` | Clipboard history |
| `Print` | Screenshot selection |
| `Super + Shift + O` | OCR selection |
| `Super + Shift + R` | Read QR selection |
| `Super + W` | Toggle Waybar |
| `Super + Alt + Enter` | Toggle fullscreen |

## CLI tools

-   `zoxide`: smarter directory navigation; provides `z <directory>` based on frecency. Optional; only useful if you want `cd` history.
-   `ripgrep` (`rg`): fast recursive text search. Useful for source-code search; no custom config is required here.
-   `delta`: readable syntax-highlighted Git diffs. Optional; `zsh/integrations.zsh` activates it only when installed.

These tools are not required by the core desktop configuration.

### Waybar

-   CPU, memory, and temperature monitoring
-   Audio controls and system tray
-   Date and time
-   Workspaces module
-   Catppuccin Mocha-inspired CSS styling
-   Optional dock bar (`dock.jsonc` / `dock.css`)

### Neovim

-   LazyVim base with local plugin overrides
-   LSP, Treesitter, Telescope and a custom Catppuccin colorscheme

## Dependencies

The installation script can automatically install these dependencies for you, or you can install them manually:

```bash
# Compositor, terminal, bar, launcher, notifications
sudo pacman -S hyprland hyprpicker kitty waybar wofi mako awww

# Shell and prompt
sudo pacman -S zsh starship eza bat fzf

# Editor, file manager, viewers
sudo pacman -S neovim yazi thunar imv zathura zathura-pdf-mupdf

# Apps bound to keys
sudo pacman -S spotify-launcher discord

# System
sudo pacman -S udiskie playerctl brightnessctl pavucontrol libnotify unarchiver \
    pipewire pipewire-alsa pipewire-pulse wireplumber \
    xdg-desktop-portal-hyprland grim slurp wl-clipboard cliphist \
    ananicy-cpp pacman-contrib curl jq ttf-jetbrains-mono-nerd

# Screenshot / OCR / QR
sudo pacman -S tesseract tesseract-data-eng tesseract-data-spa zbar

# AUR
paru -S obsidian brave-bin qogir-cursor-theme-git   # or yay -S ...
```

> Note: The install script will automatically detect if you have `paru` or `yay` installed for AUR packages. If neither is found, you'll need to manually install `obsidian`, `brave-bin`, and `qogir-cursor-theme-git`.

## Useful Resources

-   [Hyprland Wiki](https://wiki.hypr.land/)
-   [ArchWiki: Wayland](https://wiki.archlinux.org/title/Wayland)
-   [Awesome Hyprland](https://github.com/hyprland-community/awesome-hyprland)

## License

These dotfiles are available as open source under the terms of the [MIT License](LICENSE).
