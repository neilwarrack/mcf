# Set ripgrep as the default source for fzf
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow -g "!{.git,node_modules}/*" 2> /dev/null'

# Default options
export FZF_DEFAULT_OPTS='--ansi --select-1 --bind=alt-c:up,alt-t:down,alt-h:backward-char,alt-n:forward-char,alt-s:toggle-sort'

# Setup fzf if exists
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Claim back Alt-c
bind '"\ec": history-search-backward'

#######################################################################
#                            From FZF wiki                            #
#######################################################################

# Integration with z
# - like normal z when used with arguments
# - displays an fzf prompt when used without
unalias z 2> /dev/null
z()
{
  [ $# -gt 0 ] && _z "$*" && return
  cd "$(_z -l 2>&1 | fzf --height 40% --nth 2.. --reverse --inline-info +s --tac --query "${*##-* }" | sed 's/^[0-9,.]* *//')"
}

# fkill - kill process
fkill()
{
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
  if [ "x$pid" != "x" ]; then
    echo $pid | xargs kill -${1:-9}
  fi
}

# fv - fuzzy vim (with preview)
fv()
{
  local files
  IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0 --preview 'head -100 {}'))
  [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}
