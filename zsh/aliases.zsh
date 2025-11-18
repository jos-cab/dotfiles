#!/usr/bin/env zsh
# Aliases Configuration

# ======= File Operations =======
# Modern replacements for common commands
alias ls='eza -alh --color=auto --icons --group-directories-first'
alias ll='eza -l --color=auto --icons --group-directories-first'
alias la='eza -la --color=auto --icons --group-directories-first'
alias lt='eza -T --color=auto --icons'
alias cat='bat --style=numbers,changes,header'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# ======= Navigation =======
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# ======= Git Shortcuts =======
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -v'
alias gcm='git commit -m'
alias gco='git checkout'
alias gd='git diff'
alias gl='git pull'
alias gp='git push'
alias gs='git status'
alias gst='git status'
alias gb='git branch'
alias gba='git branch -a'
alias glog='git log --oneline --decorate --graph'

# ======= System =======
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ps='ps auxf'
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias mkdir='mkdir -pv'
alias wget='wget -c'
alias histg='history | grep'
alias myip='curl http://ipecho.net/plain; echo'

# ======= Package Management (Arch/Manjaro) =======
alias pacman='sudo pacman'
alias pacs='pacman -S'
alias pacu='pacman -Syu'
alias pacr='pacman -R'
alias pacss='pacman -Ss'
alias pacqi='pacman -Qi'
alias yays='yay -S'
alias yayu='yay -Syu'

# ======= Development =======
alias vim='nvim'
alias vi='nvim'
alias code='code .'
alias serve='python -m http.server'
alias ports='netstat -tulanp'

# ======= Applications =======
# Using X11 mode for Vulkan support (faster on NVIDIA)
alias brave='brave --ozone-platform=x11 --enable-features=VulkanFromANGLE,DefaultANGLEVulkan,Vulkan --password-store=basic --use-angle=vulkan --use-gl=angle --enable-gpu-rasterization --enable-zero-copy --profile-directory="Default"'

# ======= Utilities =======
alias reload='source ~/.zshrc'
alias zshconfig='${EDITOR:-nvim} ~/.zshrc'
alias ohmyzsh='${EDITOR:-nvim} ~/.oh-my-zsh'
alias h='history'
alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowtime=now
alias nowdate='date +"%d-%m-%Y"'

# ======= Fun =======
alias please='sudo'
alias fucking='sudo'
alias weather='curl wttr.in'
alias moon='curl wttr.in/Moon'
