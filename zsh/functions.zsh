#!/usr/bin/env zsh
# Custom Functions

# ======= File Operations =======
# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)     echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# ======= Git Functions =======
# Git clone and cd into directory
gclone() {
    git clone "$1" && cd "$(basename "$1" .git)"
}

# Quick commit with message
qcommit() {
    git add . && git commit -m "$1"
}

# ======= System Functions =======
# Find process by name
psgrep() {
    ps aux | grep -v grep | grep "$@" -i --color=auto
}

# Kill process by name
killall() {
    ps aux | grep -v grep | grep "$@" | awk '{print $2}' | xargs kill
}

# ======= Network Functions =======
# Get external IP (detailed)
extip() {
    echo "External IP: $(curl -s http://ipecho.net/plain)"
    echo "Location: $(curl -s http://ipinfo.io/city), $(curl -s http://ipinfo.io/country)"
}

# Get local IP
localip() {
    ip route get 1.1.1.1 | awk '{print $7; exit}'
}

# ======= Development Functions =======
# Start a simple HTTP server with custom options
httpserver() {
    local port="${1:-8000}"
    local directory="${2:-.}"
    echo "Starting HTTP server on port $port serving directory: $directory"
    cd "$directory" && python3 -m http.server "$port"
}

# Find and replace in files
findreplace() {
    if [ $# -ne 3 ]; then
        echo "Usage: findreplace <directory> <find> <replace>"
        return 1
    fi
    find "$1" -type f -exec sed -i "s/$2/$3/g" {} +
}

# ======= Utility Functions =======
# Detailed weather function with options
weatherinfo() {
    local city="${1:-}"
    local format="${2:-}"
    
    if [ -n "$format" ]; then
        # Custom format (e.g., weatherinfo "London" "?format=3")
        curl "wttr.in/$city$format"
    elif [ -n "$city" ]; then
        # Full weather for specific city
        curl "wttr.in/$city"
    else
        # Full weather for current location
        curl "wttr.in"
    fi
}

# Create backup of file
backup() {
    cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
}

# Show disk usage of current directory
duh() {
    du -h --max-depth=1 | sort -hr
}

# ======= FZF Functions =======
# FZF file finder and editor
fzf-edit() {
    local file
    file=$(fzf --preview 'bat --style=numbers --color=always {}' --preview-window=right:60%:wrap)
    [ -n "$file" ] && ${EDITOR:-nvim} "$file"
}

# FZF directory finder and cd
fzf-cd() {
    local dir
    dir=$(find . -type d 2>/dev/null | fzf --preview 'tree -C {} | head -200')
    [ -n "$dir" ] && cd "$dir"
}

# FZF process killer
fzf-kill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m --header='[kill:process]' | awk '{print $2}')
    [ -n "$pid" ] && echo "$pid" | xargs kill -${1:-9}
}

# ======= Docker Functions (if Docker is installed) =======
# Docker cleanup
docker-cleanup() {
    docker system prune -af
    docker volume prune -f
}

# Docker shell into container
dsh() {
    docker exec -it "$1" /bin/bash
}