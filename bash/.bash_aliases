# Safe rm
alias rm='rm --preserve-root'

# Colored tools
alias ls='ls -h --color=auto --group-directories-first'
alias grep='grep --color=auto'
alias tree='tree -C'

# Disk usage
alias duu='du -ms ./* | sort -n'
alias dua='du -ma --max-depth=1 | sort -n'
alias duuk='du -ks ./* | sort -n'
alias duuu='du -ms .[!.]* *| sort -n'
alias duuuk='du -ks .[!.]* *| sort -n'

# git
alias go='git checkout'
__git_complete go _git_checkout

alias gd='git diff'
__git_complete gd _git_diff

alias gdd='git difftool -d'
__git_complete gdd _git_difftool

alias gm='git merge'
__git_complete gm _git_merge

alias gr='git rebase'
__git_complete gr _git_rebase

alias ga='gitk --all'
alias ghm='gitk HEAD master'
alias gf='git fetch --all --prune'
alias gu='git-up'

# Clean swap
alias reswap='sudo swapoff -a && sudo swapon -a'

# Get keycodes
alias kc="xev | grep -A2 --line-buffered '^KeyRelease' | sed -n '/keycode /s/^.*keycode \([0-9]*\).* (.*, \(.*\)).*$/\1 \2/p'"

# Tmux with 256 colors
alias tmux='TERM=xterm-256color tmux'

# Clone the current terminal window
alias cl='xfce4-terminal --working-directory=`pwd` &'
