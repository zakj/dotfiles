#!/bin/sh

alternates() {
  for i in $*; do
    type $i >/dev/null 2>&1 && echo $i && return
  done
}

set -a
EDITOR=$(alternates vim vi)
ENV="$HOME/.profile"
FIGNORE=".pyc:.DS_Store"
HISTIGNORE='&'
LESS=gij5MR
PAGER=$(alternates less more)
set +a

if [ -n "$PS1" ]; then
  test -n "$BASH" && PS1='\h:\w\$ '

  case $TERM in
  xterm* | rxvt | screen)
    test -n "$BASH" && PS1="\[]0;\u@\h:\w\]${PS1}"

    alias lynx='name Lynx; lynx -nopause'
    alias mutt="name mutt; mutt"
    name() { echo -n "]0;$*"; }
  ;;
  esac

  alias grep=egrep
  test "$PAGER" = less || alias less="$PAGER"
  alias ls='ls -F'
  alias ll='ls -laF'
  alias sudo=$(alternates tinysu sudo)
  alias term=$(alternates mrxvt terminal rxvt xterm)

  test "$EDITOR" = vi || alias vi="$EDITOR"

  set -o vi
  # Some familiar emacs-style bindings.
  bind '"\C-a"':beginning-of-line
  bind '"\C-e"':end-of-line
  bind '"\C-l"':clear-screen
  # Up and down arrows do prefix matching.
  bind '"\e[A"':history-search-backward
  bind '"\e[B"':history-search-forward
  shopt -s histappend

  psg() { ps auxww | egrep $* | fgrep -v grep; }
  psi() { psg $* | awk '{print $2}'; }
  vv() {
      vim -R -c 'runtime! macros/less.vim' -c 'let no_plugin_maps = 1' \
          -c 'set scrolloff=999 mouse=h laststatus=0' "${@--}"
  }

  lack() { ack --group --color "$@" | $PAGER; }
  mvack() { mvim $(ack -l "$@"); }
fi

if [ "$OSTYPE" = cygwin ]; then
    LESS=r$LESS
    USER=$(id -un); export USER
    psi() { psg $* | awk '{print $1}'; }
fi

unset alternates

test -f "$HOME/.local/profile" && source "$HOME/.local/profile"
