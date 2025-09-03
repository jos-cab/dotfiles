#!/usr/bin/env zsh
# Zsh Plugins Configuration

# ======= Essential Plugins =======
# Fast syntax highlighting for better performance
zinit light zdharma-continuum/fast-syntax-highlighting

# Auto-suggestions while typing
zinit light zsh-users/zsh-autosuggestions

# Additional completions
zinit light zsh-users/zsh-completions

# ======= Plugin Settings =======
# Autosuggestions settings
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6c7086"  # Catppuccin Mocha overlay0
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# Syntax highlighting settings - Consistent Catppuccin Mocha colors
FAST_HIGHLIGHT_STYLES[default]='none'
FAST_HIGHLIGHT_STYLES[unknown-token]='fg=#f38ba8'  # Catppuccin Mocha red
FAST_HIGHLIGHT_STYLES[reserved-word]='fg=#cba6f7'  # Catppuccin Mocha mauve
FAST_HIGHLIGHT_STYLES[alias]='fg=#a6e3a1'          # Catppuccin Mocha green
FAST_HIGHLIGHT_STYLES[builtin]='fg=#a6e3a1'        # Catppuccin Mocha green (same as commands)
FAST_HIGHLIGHT_STYLES[function]='fg=#f9e2af'       # Catppuccin Mocha yellow
FAST_HIGHLIGHT_STYLES[command]='fg=#a6e3a1'        # Catppuccin Mocha green
FAST_HIGHLIGHT_STYLES[precommand]='fg=#94e2d5'     # Catppuccin Mocha teal
FAST_HIGHLIGHT_STYLES[commandseparator]='fg=#6c7086'
FAST_HIGHLIGHT_STYLES[hashed-command]='fg=#94e2d5'
FAST_HIGHLIGHT_STYLES[path]='fg=#89dceb'           # Catppuccin Mocha sky
FAST_HIGHLIGHT_STYLES[path_pathseparator]='fg=#6c7086'
FAST_HIGHLIGHT_STYLES[globbing]='fg=#f9e2af'       # Catppuccin Mocha yellow
FAST_HIGHLIGHT_STYLES[history-expansion]='fg=#89b4fa'
FAST_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#fab387'  # Catppuccin Mocha peach
FAST_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#fab387'
FAST_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#a6adc8'
FAST_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#eba0ac'  # Catppuccin Mocha maroon (softer than red)
FAST_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#eba0ac'
FAST_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#eba0ac'
FAST_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#f5c2e7'  # Catppuccin Mocha pink
FAST_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=#f5c2e7'
FAST_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=#f5c2e7'
FAST_HIGHLIGHT_STYLES[assign]='fg=#a6adc8'         # Catppuccin Mocha subtext0
FAST_HIGHLIGHT_STYLES[redirection]='fg=#cba6f7'    # Catppuccin Mocha mauve
FAST_HIGHLIGHT_STYLES[comment]='fg=#6c7086'        # Catppuccin Mocha overlay0
FAST_HIGHLIGHT_STYLES[variable]='fg=#94e2d5'       # Catppuccin Mocha teal