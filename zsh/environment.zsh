#!/usr/bin/env zsh
# Environment Variables and Settings

# ======= Editor Settings =======
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'

# ======= History Settings =======
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_BEEP

# ======= Directory Settings =======
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# ======= Completion Settings =======
setopt COMPLETE_ALIASES
setopt ALWAYS_TO_END
setopt AUTO_MENU
setopt AUTO_LIST
setopt AUTO_PARAM_SLASH
setopt COMPLETE_IN_WORD
unsetopt MENU_COMPLETE
unsetopt FLOW_CONTROL

# ======= Globbing Settings =======
setopt EXTENDED_GLOB
setopt GLOB_DOTS
unsetopt CASE_GLOB

# ======= Other Settings =======
setopt CORRECT
setopt INTERACTIVE_COMMENTS
setopt MULTIOS
setopt NO_BEEP
setopt PROMPT_SUBST

# ======= Key Bindings =======
# Enable emacs keybindings for standard navigation keys
bindkey -e

# Standard key bindings for navigation
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^B' backward-char
bindkey '^F' forward-char
bindkey '^D' delete-char
bindkey '^K' kill-line
bindkey '^U' kill-whole-line
bindkey '^W' backward-kill-word
bindkey '^Y' yank

# Word navigation
bindkey '^[b' backward-word
bindkey '^[f' forward-word

# Home/End keys (various terminal compatibility)
bindkey '\e[1~' beginning-of-line
bindkey '\e[4~' end-of-line
bindkey '\e[7~' beginning-of-line
bindkey '\e[8~' end-of-line
bindkey '\e[H' beginning-of-line
bindkey '\e[F' end-of-line
bindkey '\eOH' beginning-of-line
bindkey '\eOF' end-of-line

# Delete key
bindkey '\e[3~' delete-char

# Ctrl+Delete to delete a word
bindkey $'\x08' backward-kill-word

# Ctrl+Arrow keys for word navigation (various terminal compatibility)
bindkey '\e[1;5D' backward-word
bindkey '\e[1;5C' forward-word
bindkey '\e[5D' backward-word
bindkey '\e[5C' forward-word

# ======= Language and Locale =======
export LANG=C.utf8
export LC_ALL=C.utf8
export LC_CTYPE=C.utf8

# ======= Path Settings =======
# Add local bin directories to PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# ======= Application Settings =======
# Less settings
export LESS='-R -i -w -M -z-4'
export LESSHISTFILE=-

# FZF settings
export FZF_DEFAULT_OPTS="
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
--height=40% --layout=reverse --border --margin=1 --padding=1"

# Bat (cat replacement) settings
export BAT_THEME="Catppuccin Mocha"

# Qt Platform Theme
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_STYLE_OVERRIDE=kvantum

# Ensure Qt apps use dark theme
export QT_AUTO_SCREEN_SCALE_FACTOR=1
export QT_ENABLE_HIGHDPI_SCALING=1

# Dark Theme Preference
export GTK_THEME=catppuccin-mocha-mauve-standard+default
export GTK_APPLICATION_PREFER_DARK_THEME=1

# ======= XDG Base Directory Specification =======
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"