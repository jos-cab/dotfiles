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
export BAT_THEME="Catppuccin mocha"

# ======= XDG Base Directory Specification =======
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"