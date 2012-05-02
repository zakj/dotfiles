setopt auto_pushd        # Use the directory stack more easily.
setopt no_beep           # Shhhh.
setopt correct           # Spelling correction for commands.
setopt no_flow_control   # Ignore ^S/^Q.
setopt hist_ignore_dups  # Don't insert immediate duplicates into history.
setopt prompt_subst      # Allow shell substitution in prompts.

# External environment
export EDITOR=vim
export LESS=gij5MR
export PAGER=less

# History
HISTFILE=~/.history
HISTSIZE=10000
SAVEHIST=$HISTSIZE

# Prompts
PROMPT='%m:%~'
# "%", or "#" when root, or red "x" if the last command exited non-zero.
PROMPT+='%(?.%#.%B%F{red}✖%b%f) '
# Dirtiness flag in green, current branch in dark grey.
RPROMPT='%F{green}$(git_dirty)%B%F{black}$(git_branch)%b%f'

# Aliases
alias ls='ls -F'
alias ll='ls -laF'
alias vi=$EDITOR

# Completion
autoload -U compinit
compinit -i


# Give a short name to the given (or current) directory.
namedir() { eval "$1=${2-$PWD}" && : ~$1 }

# Search the output of `ps` for a term, hiding the grep command.
psg() { ps auxww | egrep $* | fgrep -v "egrep $*" }

# Page ack results without losing groups/colors.
lack() { ack --group --color $* | $PAGER }

# Open all matching files in mvim.
mvack() { mvim $(ack -l $*) }

# Display the current git branch.
git_branch() { print -n ${$(git symbolic-ref HEAD 2>/dev/null)##*/} }

# Display a symbol if the local repository has changes.
git_dirty() { [[ -n $(git status --porcelain 2>/dev/null) ]] && print -n '⚡' }

# Manage terminal window titles.
if [[ $TERM =~ "(rxvt|xterm).*" ]]; then
    termtitle() { print -Pn "\e]0;$*\a" }
    precmd() { termtitle '%n@%m:%~' }
    preexec() { termtitle $1 }
fi


# zle; vi mode (from $EDITOR), with some familiar Emacs-style friends.
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


# Local overrides
[[ -f ~/.local/zshrc ]] && source ~/.local/zshrc || true
