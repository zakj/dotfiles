typeset -U path
path=(~/.local/bin ~/bin /usr/local/bin /usr/local/sbin $path)
fpath+=~/.zfuncs

# Don't offer built-in completion commands as corrections.
CORRECT_IGNORE=_*
