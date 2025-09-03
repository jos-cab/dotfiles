#!/usr/bin/env zsh
# Completion Configuration

# ======= Completion System =======
# Initialize completion system
autoload -Uz compinit
compinit

# ======= Completion Settings =======
# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Use menu selection
zstyle ':completion:*' menu select

# Group completions by category
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'

# Use colors in completion
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Complete . and .. special directories
zstyle ':completion:*' special-dirs true

# Process completion
zstyle ':completion:*:processes' command 'ps -u $USER -o pid,user,comm -w -w'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' force-list always

# SSH/SCP completion
zstyle ':completion:*:(ssh|scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' group-order users hosts-domain hosts-host users hosts-ipaddr
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

# Git completion
zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash
zstyle ':completion:*:*:git*:*' group-order 'main commands' 'alias commands' 'external commands'

# Directory completion
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# History completion
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes

# Ignore completion functions for commands you don't have
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'

# Array completion element sorting
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# Don't complete uninteresting users
zstyle ':completion:*:*:*:users' ignored-patterns \
        adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
        clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
        gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
        ldap lp mail mailman mailnull man messagebus mldonkey mysql nagios \
        named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
        operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
        usbmux uucp vcsa wwwrun xfs '_*'

# Filename suffixes to ignore during completion (except after rm command)
zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns '*?.o' '*?.c~' '*?.old' '*?.pro'

# Command for process lists, the local web server details and host completion
zstyle ':completion:*:urls' local 'www' '/var/www/' 'public_html'

# Completion caching
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path ~/.zsh/cache/

# Expand partial paths
zstyle ':completion:*' expand 'yes'
zstyle ':completion:*' squeeze-slashes 'yes'

# Include non-hidden directories in globbed file completions for certain commands
zstyle ':completion::complete:*' '\'

# Use ls-colors for path completions
function _set-list-colors() {
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
    unfunction _set-list-colors
}
sched 0 _set-list-colors  # deferred since LC_COLORS might not be available yet