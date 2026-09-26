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
alias weather='curl wttr.in'

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
alias brave='brave --ozone-platform=wayland --enable-features=UseOzonePlatform --password-store=basic --profile-directory="Default"'

# ======= Utilities =======
alias fastfetch='command fastfetch --config "$HOME/.config/fastfetch/config.jsonc"'
alias reload='source ~/.zshrc'
alias zshconfig='${EDITOR:-nvim} ~/.zshrc'
alias ohmyzsh='${EDITOR:-nvim} ~/.oh-my-zsh'
alias h='history'
alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowtime=now
alias nowdate='date +"%d-%m-%Y"'
alias week='date +%V'
alias calweek='cal -w'
qr() {
    [[ -n "$*" ]] || { print -u2 'Usage: qr <text>'; return 1; }
    printf '%s' "$*" | curl -fsS -F '-=<-' https://qrenco.de
}
cheat() { curl -fsS "https://cheat.sh/$1"; }

# ======= Fun =======
alias please='sudo'
alias fucking='sudo'
alias moon='curl wttr.in/Moon'
alias coin='shuf -e heads tails -n 1'
alias dice='shuf -i 1-6 -n 1'
dices() {
    [[ "$1" == <-> && "$1" -gt 0 ]] || { print -u2 'Usage: dices <number>'; return 1; }
    shuf -i 1-6 -n "$1"
}
alias magic8='shuf -e "Yes" "No" "Probably" "Ask again later" "Definitely not" -n 1'
iss() { curl -fsS http://api.open-notify.org/iss-now.json | jq -r '.iss_position | "lat: \(.latitude)  lon: \(.longitude)"'; }
chuck() { curl -fsS https://api.chucknorris.io/jokes/random | jq -r '.value'; }
dadjoke() { curl -fsS -H 'Accept: text/plain' https://icanhazdadjoke.com/; }
catfact() { curl -fsS https://catfact.ninja/fact | jq -r '.fact'; }
advice() { curl -fsS https://api.adviceslip.com/advice | jq -r '.slip.advice'; }
bored() { curl -fsS https://bored-api.appbrewery.com/random | jq -r '.activity'; }
alias parrot='curl -fsS https://parrot.live'
alias rickroll='curl -fsS https://ascii.live/rick'
alias fortune='fortune | cowsay | lolcat'
number() { curl -fsS "https://numbersapi.com/${1:-random}/trivia"; printf "\\n"; }
age() {
    [[ -n "$1" && "$1" != <-> ]] || { print -u2 'Usage: age <name>'; return 1; }
    curl -fsS "https://api.agify.io?name=$1" | jq -r 'if .age then "\(.name): ~\(.age) years" else "No age data found for \(.name)" end'
}
