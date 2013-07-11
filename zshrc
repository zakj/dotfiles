#{{{ Options
setopt no_beep           # Shhhh.
setopt no_flow_control   # Ignore ^S/^Q.
setopt hist_ignore_dups  # Don't insert immediate duplicates into history.

#}}}
#{{{ Environment
export EDITOR=vim
export LESS=gij5MR
export PAGER=less

# Python virtual environments.
export WORKON_HOME=~/.virtualenvs
export PIP_VIRTUALENV_BASE=$WORKON_HOME
export PIP_RESPECT_VIRTUALENV=1
export VIRTUALENV_USE_DISTRIBUTE=1

# zsh history; no need to export this.
HISTFILE=~/.history
HISTSIZE=10000
SAVEHIST=$HISTSIZE

#}}}
#{{{ Prompt
# Hostname and pwd, then %/# or a red symbol if the last command failed.
PROMPT='%~'
PROMPT+='%(?.%#.%B%F{red}✖%b%f) '

# Include the hostname if this is a remote host.
test -n "$SSH_CLIENT" && PROMPT="%m:$PROMPT"

# vcs_info output in RPROMPT.
autoload -U add-zsh-hook vcs_info
add-zsh-hook -U precmd precmd-prompt
precmd-prompt() { vcs_info; RPROMPT=$vcs_info_msg_0_ }

() {
    local format='%m%c%u%B%F{black}%b'
    zstyle ':vcs_info:*' formats "$format%%b%f"
    zstyle ':vcs_info:*' actionformats "$format%%b%F{yellow}⚡%a%f"
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

#}}}
#{{{ Aliases and functions
alias ls='ls -F'
alias ll='ls -laF'
alias vi=$EDITOR
alias psg='pgrep -lf'
alias lag='ag --pager $PAGER'

# cdr provides a selectable list of recently-visited directories.
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':completion:*:*:cdr:*:*' menu selection

# zmv saves writing loops and replacements for common rename tasks.
# usage: noglob zmv -W prefix-1.* prefix-2.*
autoload -Uz zmv

# Give a short name to the given (or current) directory.
namedir() { eval "$1=${2-$PWD}" && : ~$1 }

# Open all matching files in mvim.
mvag() { ag -l "$@" | xargs mvim }

#}}}
#{{{ zle
# vi mode (from $EDITOR), with some familiar Emacs-style friends.
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

#}}}

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

# vim:foldmethod=marker
