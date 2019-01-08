# .bashrc

# Don't do anyting for non-interactive sessions
case $- in
    *i*) ;;
      *) return;;
esac

# Guard the root user against accidents
if [ $UID -eq "0" ];then
    alias rm='rm -i'
    alias cp='cp -i'
    alias mv='mv -i'
fi

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Color codes (see http://misc.flogisoft.com/bash/tip_colors_and_formatting)
# NB! We enclose the color codes with \[ and \] to specify that they are
# non-printing characters. Otherwise the terminal garbles long lines.
RCol='\[\e[0m\]'  # Reset
Bld='\[\e[1m\]'   # Bold
Red='\[\e[31m\]'  # Red
Gre='\[\e[32m\]'  # Green
Yel='\[\e[33m\]'  # Yellow
Blu='\[\e[34m\]'  # Light Blue
LGry='\[\e[97m\]' # Light Grey
Pur='\[\e[35m\]'  # Purple

# Root user is red, normal user is blue
if [ $UID -eq "0" ];then
    UCol="$Red"
else
    UCol="$Blu"
fi
# hostname color
HCol="$Blu"
# Terminal prompt
user_host="$Bld$UCol\u$RCol@$Bld$HCol\h$RCol"
source $HOME/.git-prompt.sh # from http://code-worrier.com/blog/git-branch-in-bash-prompt/
git_branch="$Bld$Pur\$(__git_ps1)$RCol"
PS1="[$user_host \W$git_branch]\$ "

EDITOR=vim
export EDITOR

export PROMPT_COMMAND='printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'

# Colored man
#export PAGER=most

# Commands with leading space will not be saved in ~/.bash_history
export HISTCONTROL="ignorespace"

if [ -f $HOME/.bash_aliases ]; then
    . $HOME/.bash_aliases
fi

# Wrapper to get notifications over ssh after a long running command
#
# You have to connect by specifying some communication ports:
#   ssh -R 4000:127.0.0.1:5000 user@remote
#   ssh -R 4001:127.0.0.1:5001 user@remote
# Local machine should listen for the notifications:
#   #!/usr/bin/env bash
#   while :
#   do
#       message=$(nc -l -p 5000)
#       notify-send -u normal -t -1 "${message}"
#   done
#
#   #!/usr/bin/env bash
#   while :
#   do
#       message=$(nc -l -p 5001)
#       notify-send -u critical -t -1 "${message}"
#   done
#
# Usage:
#   $ ntf <your command>
ntf() {
    start=$(date +%s)
    eval $(printf "%q " "$@")
    rc=$?
    duration=$(($(date +%s) - start))
    if [ $rc -eq 0 ]
    then
        echo "$@ ($(pwd)) successful on $(hostname)" | nc 127.0.0.1 4000
    else
        echo "$@ ($(pwd)) failed on $(hostname)" | nc 127.0.0.1 4001
    fi
}

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
