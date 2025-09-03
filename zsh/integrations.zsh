#!/usr/bin/env zsh
# External Tool Integrations

# ======= FZF Integration =======
# Key bindings for FZF (if available)
if [ -f /usr/share/fzf/key-bindings.zsh ]; then
    source /usr/share/fzf/key-bindings.zsh
elif [ -f ~/.fzf/shell/key-bindings.zsh ]; then
    source ~/.fzf/shell/key-bindings.zsh
fi

# FZF completion (if available)
if [ -f /usr/share/fzf/completion.zsh ]; then
    source /usr/share/fzf/completion.zsh
elif [ -f ~/.fzf/shell/completion.zsh ]; then
    source ~/.fzf/shell/completion.zsh
fi

# ======= Starship Prompt =======
# Initialize Starship prompt (if available)
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# ======= Zoxide Integration =======
# Initialize zoxide (if available)
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
    alias cd='z'
fi

# ======= Eza Integration =======
# Set up eza colors to match theme
if command -v eza >/dev/null 2>&1; then
    export EZA_COLORS="ur=0:uw=0:ux=0:ue=0:gr=0:gw=0:gx=0:tr=0:tw=0:tx=0:su=0:sf=0:xa=0:sn=32:sb=32:da=34:gm=34:gd=34:gv=34:gt=34"
fi

# ======= Bat Integration =======
# Set bat theme
if command -v bat >/dev/null 2>&1; then
    export BAT_THEME="Catppuccin-mocha"
fi

# ======= Delta Integration =======
# Git diff with delta (if available)
if command -v delta >/dev/null 2>&1; then
    export GIT_PAGER="delta"
fi

# ======= Ripgrep Integration =======
# Ripgrep configuration
if command -v rg >/dev/null 2>&1; then
    export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"
fi

# ======= Node.js Integration =======
# NVM integration (if available)
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    source "$HOME/.nvm/nvm.sh"
fi

if [ -s "$HOME/.nvm/bash_completion" ]; then
    source "$HOME/.nvm/bash_completion"
fi

# Yarn global bin path
if command -v yarn >/dev/null 2>&1; then
    export PATH="$(yarn global bin):$PATH"
fi

# ======= Python Integration =======
# Pyenv integration (if available)
if command -v pyenv >/dev/null 2>&1; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

# Poetry integration (if available)
if [ -f "$HOME/.poetry/env" ]; then
    source "$HOME/.poetry/env"
fi

# ======= Ruby Integration =======
# RVM integration (if available)
if [ -s "$HOME/.rvm/scripts/rvm" ]; then
    source "$HOME/.rvm/scripts/rvm"
fi

# ======= Rust Integration =======
# Cargo integration (if available)
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# ======= Go Integration =======
# Go path setup (if Go is installed)
if command -v go >/dev/null 2>&1; then
    export GOPATH="$HOME/go"
    export PATH="$GOPATH/bin:$PATH"
fi

# ======= Java Integration =======
# SDKMAN integration (if available)
if [ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

# ======= Docker Integration =======
# Docker completion (if available)
if command -v docker >/dev/null 2>&1; then
    if [ -f /usr/share/zsh/site-functions/_docker ]; then
        autoload -U _docker
    fi
fi

# ======= Kubernetes Integration =======
# Kubectl completion (if available)
if command -v kubectl >/dev/null 2>&1; then
    source <(kubectl completion zsh)
    alias k='kubectl'
    complete -F __start_kubectl k
fi

# ======= Kiro IDE Integration =======
# Kiro shell integration
if [[ "$TERM_PROGRAM" == "kiro" ]]; then
    . "$(kiro --locate-shell-integration-path zsh)"
fi

# ======= Kitty Integration =======
# Kitty shell integration (if running in Kitty)
if [[ "$TERM" == "xterm-kitty" ]]; then
    # Enable kitty features
    alias icat="kitty +kitten icat"
    alias d="kitty +kitten diff"
    alias clipboard="kitty +kitten clipboard"
fi

# ======= SSH Agent =======
# Start SSH agent if not running
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent -t 1h > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi
if [[ ! "$SSH_AUTH_SOCK" ]]; then
    source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
fi