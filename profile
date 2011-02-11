#!/bin/sh

alternates() {
  for i in $*; do
    type $i >/dev/null 2>&1 && echo $i && return
  done
}

set -a
PATH="$HOME/.local/bin:$HOME/bin:/usr/ucb:$HOME/sadm/bin:$HOME/mmake/bin"
PATH="$PATH:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"
PATH="$PATH:/usr/X11R6/bin:/var/qmail/bin:/usr/games"
CVS_RSH=ssh
EDITOR=$(alternates vim vi)
ENV="$HOME/.profile"
FIGNORE=".pyc:.DS_Store"
FTP_PASSIVE_MODE=YES
HISTIGNORE='&'
HOMETEXMF="$HOME/doc/texmf:$HOME/fenris/hometexmf"
TEXMFHOME="$HOMETEXMF"
LESS=gij5MR
PAGER=$(alternates less more)
QMAILINJECT=i
RSYNC_RSH=ssh
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

  #hgdiff() { vimdiff -c 'map q :qa!<CR>' <(hg cat "$1") "$1"; }
  cds() { cdsitepackages && test $# -gt 0 && cd "$@"; }
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
