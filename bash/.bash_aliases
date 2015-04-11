# Safe rm
alias rm='rm --preserve-root'

# Colored ls and grep
alias ls='ls -h --color=auto --group-directories-first'
alias grep='grep --color=auto'

# Disk usage
alias duu='du -ms ./* | sort -n'
alias dua='du -ma --max-depth=1 | sort -n'
alias duuk='du -ks ./* | sort -n'
alias duuu='du -ms .[!.]* *| sort -n'
alias duuuk='du -ks .[!.]* *| sort -n'

# Clean swap
alias reswap='sudo swapoff -a && sudo swapon -a'

# Clone the current terminal window
alias cl='xfce4-terminal --working-directory=`pwd` &'
