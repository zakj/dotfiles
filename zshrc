# Options  {{{1
setopt no_beep           # Shhhh.
setopt no_flow_control   # Ignore ^S/^Q.
setopt hist_ignore_dups  # Don't insert immediate duplicates into history.
setopt share_history     # Read/write from the history file immediately.

# Environment  {{{1
typeset -U PATH path
fpath=(~/.zfuncs $fpath)

# Homebrew
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval $(/opt/homebrew/bin/brew shellenv)
  fpath=($(brew --prefix)/share/zsh/site-functions $fpath)
fi

export EDITOR=$(basename $(whence nvim || whence vim))
export LESS=gij5MR
export PAGER=less

# Python virtual environments.
export WORKON_HOME=~/.virtualenvs
export PIP_VIRTUALENV_BASE=$WORKON_HOME
export PIP_RESPECT_VIRTUALENV=1
export VIRTUALENV_USE_DISTRIBUTE=1

# zsh config; no need to export this.
CORRECT_IGNORE=_*  # don't offer built-in completion commands as corrections
HISTFILE=~/.history
HISTSIZE=10000
SAVEHIST=$HISTSIZE

# Prompt  {{{1
# Working directory with truncated long paths.
PROMPT='%5(~.%-1~/…/%2~.%~)%# '
# Prepend the hostname if this is a remote host.
test -n "$SSH_CLIENT" && PROMPT="%m:$PROMPT"
# Prepend a marker whose color reflects last command exit status.
[[ -v VSCODE_SHELL_INTEGRATION ]] || PROMPT="%F{15}%(?..%F{9})➜%f $PROMPT"

# vcs_info output in RPROMPT.
autoload -U add-zsh-hook vcs_info
add-zsh-hook -U precmd precmd-prompt
precmd-prompt() { vcs_info; RPROMPT=$vcs_info_msg_0_ }

() {
  local format='%m%c%u%F{8}%b'
  zstyle ':vcs_info:*' formats "$format%f"
  zstyle ':vcs_info:*' actionformats "$format%F{yellow}⚡%a%f"
  zstyle ':vcs_info:*' enable git hg svn
  zstyle ':vcs_info:*' check-for-changes true
  zstyle ':vcs_info:*' stagedstr '%F{green}•'
  zstyle ':vcs_info:*' unstagedstr '%F{red}•'
}

# vcs_info doesn't detect added/removed files, so I do it myself.
autoload -U -- +vi-get-data-git
zstyle ':vcs_info:git*' check-for-changes false
zstyle ':vcs_info:git*+post-backend:*' hooks get-data-git

# Enable completion.
autoload -U compinit
compinit -i

# Aliases and functions  {{{1
alias ls='ls -F'
alias ll='ls -laF'
alias vi=$EDITOR
alias psg='pgrep -lf'
alias youtube-dl='noglob yt-dlp'

# cdr provides a selectable list of recently-visited directories.
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':completion:*:*:cdr:*:*' menu selection

# zmv saves writing loops and replacements for common rename tasks.
# usage: noglob zmv -W prefix-1.* prefix-2.*
autoload -Uz zmv

# Give a short name to the given (or current) directory.
namedir() { eval "$1='${2-$PWD}'" && cd ~$1 }

# Normalize recursive grep tools.
g() {
  if whence rg &>/dev/null; then
    rg -p \
      --colors match:none --colors match:fg:black --colors match:bg:yellow \
      --colors path:fg:green --colors path:style:bold \
      --colors line:fg:yellow --colors line:style:intense --colors line:style:bold \
      "$@" | less -FX
  elif whence ag &>/dev/null; then
    ag --pager 'less -FX' "$@"
  elif git rev-parse --is-inside-work-tree &>/dev/null; then
    git grep --color --heading --break "$@" | less -FX
  else
    autoload colors && colors && echo "$fg_bold[red]falling back to grep -R$reset_color" >&2
    grep -R "$@" . | less -FX
  fi
}

# Normalize node package management.
np() {
  if [ -f "package-lock.json" ]; then npm "$@"
  elif [ -f "yarn.lock" ]; then yarn "$@"
  else pnpm "$@"
  fi
}

# Open all recursive-grep results in an editor.
eg() {
  "$EDITOR" $(g -l "$@")
}

# Reconnect ssh socket in an existing tmux session.
fixssh() {
  for line in "${(f)$(tmux show-environment)}"; do
    if [[ $line =~ '^SSH_\w+=' ]]; then
      echo export $line
      export $line
    fi
  done
}

# zle  {{{1
# vi mode (from $EDITOR), with some familiar Emacs-style friends.
bindkey -v
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
# History search.
bindkey '^R' history-incremental-search-backward
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey '\e[A' history-beginning-search-backward-end
bindkey '\e[B' history-beginning-search-forward-end
# Perform history completion when pressing space.
bindkey ' ' magic-space
# ^Y to insert the kill buffer; ctrl-shift-y to rotate through the killring.
bindkey '^Y' yank
bindkey '\e[Z' yank-pop

# Save keypresses when referring to parent directories.
rationalise-dot() {
  if [[ $LBUFFER = *.. ]]; then
    LBUFFER+=/..
  else
    LBUFFER+=.
  fi
}
zle -N rationalise-dot
bindkey . rationalise-dot

page-up-within-tmux() {
  if [[ $TMUX != '' ]]; then
    tmux copy-mode -u
  fi
}
zle -N page-up-within-tmux
bindkey "${terminfo[kpp]}" page-up-within-tmux

# Misc  {{{1

# Manage terminal window titles.
if [[ $TERM =~ "(rxvt|xterm).*" ]]; then
  termtitle() { print -Pn "\e]0;$*\a" }
  precmd-termtitle() { termtitle '%n@%m:%~' }
  preexec-termtitle() { termtitle $1 }
  autoload -U add-zsh-hook
  add-zsh-hook -U precmd precmd-termtitle
  add-zsh-hook -U preexec preexec-termtitle
fi

# Local overrides
[[ -f ~/.local/zshrc ]] && source ~/.local/zshrc || true
