# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

export TERM='xterm-256color'

# set terminal window title
title ()
{
  echo -ne "\033]0;$1\007"
}

vim-ag()
{
  vim -s <(printf "\e;Ag $1\n")
}

# Load secret configuration settings
if [ -f ~/.secrets ]; then
    . ~/.secrets
fi

BASH_TIME_STARTUP=${BASH_TIME_STARTUP:-1}

if [[ $BASH_TIME_STARTUP == 1 ]]; then
  # Track the time it takes to load each configuration file
  bash_times_file="/tmp/bashtimes.$$"
  echo -n > "$bash_times_file"
fi

timed_source()
{
  local file="$1"
  local before=$(date +%s%N)
  source "$file"
  local after=$(date +%s%N)
  echo "$file $before $after" >> "$bash_times_file"
}

source_dir()
{
  local dir="$1"
  local sourcer
  if [[ $BASH_TIME_STARTUP == 1 ]]; then
    sourcer='timed_source'
  else
    sourcer='source'
  fi
  if [[ -d $dir ]]
  then
    local conf_file
    for conf_file in "$dir"/*
    do
      if [[ -f $conf_file ]]; then
        $sourcer "$conf_file"
      fi
    done
  fi
}

if [ -z "$MCF" ]; then
  MCF=$HOME/.mcf
fi

source_dir $MCF/bash/local/before
source_dir $MCF/bash
source_dir $MCF/bash/local/after

unset source_dir
unset timed_source
unset bash_times_file
unset BASH_TIME_STARTUP
