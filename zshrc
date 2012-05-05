#{{{ Options
setopt auto_pushd        # Use the directory stack more easily.
setopt no_beep           # Shhhh.
setopt correct           # Spelling correction for commands.
setopt no_flow_control   # Ignore ^S/^Q.
setopt hist_ignore_dups  # Don't insert immediate duplicates into history.
setopt prompt_subst      # Allow shell substitution in prompts.

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
PROMPT='%m:%~'
PROMPT+='%(?.%#.%B%F{red}✖%b%f) '

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

# Give a short name to the given (or current) directory.
namedir() { eval "$1=${2-$PWD}" && : ~$1 }

# Search the output of `ps` for a term, hiding the grep command.
psg() { ps auxww | egrep $* | fgrep -v "egrep $*" }

# Page ack results without losing groups/colors.
lack() { ack --group --color $* | $PAGER }

# Open all matching files in mvim.
mvack() { mvim $(ack -l $*) }

#}}}
#{{{ zle
# vi mode (from $EDITOR), with some familiar Emacs-style friends.
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^R' history-incremental-search-backward
bindkey '\e[A' up-line-or-search
bindkey '\e[B' down-line-or-search
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
