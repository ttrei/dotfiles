# .bashrc

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
Blu='\[\e[34m\]' # Light Blue
LGry='\[\e[97m\]' # Light Grey

# Root user is red, normal user is blue
if [ $UID -eq "0" ];then
    UCol="$Red"
else
    UCol="$Blu"
fi
# hostname color
HCol="$Blu"
# Terminal prompt
PS1="[$Bld$UCol\u$RCol@$Bld$HCol\h$RCol \W]$ "

EDITOR=/usr/bin/vim
export EDITOR

# Colored man
#export PAGER=most

# Commands with leading space will not be saved in ~/.bash_history
export HISTCONTROL="ignorespace"

if [ -f /home/reinis/.bash_aliases ]; then
    . /home/reinis/.bash_aliases
fi
