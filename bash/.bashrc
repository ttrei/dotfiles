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

EDITOR=/usr/bin/vim
export EDITOR

# Colored man
#export PAGER=most

# Commands with leading space will not be saved in ~/.bash_history
export HISTCONTROL="ignorespace"

if [ -f /home/reinis/.bash_aliases ]; then
    . /home/reinis/.bash_aliases
fi

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
