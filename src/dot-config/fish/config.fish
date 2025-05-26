if test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
end

if status is-interactive
    fish_config theme choose 'Solarized Dark'
    set fish_color_valid_path # Reset theme's underlines on paths.
    starship init fish | source # Set prompt.

    fish_hybrid_key_bindings # vi mode but with emacs-style bindings.
    set fish_cursor_insert line # Use cursor to distinguish insert/normal modes.

    # TODO remove this when fish supports ghostty
    if string match -q -- '*ghostty*' $TERM
        set -g fish_vi_force_cursor 1
    end

    set fish_greeting # Shhh.
    set __fish_ls_command ls -F # Avoid default ls colors added by fish.

    # Configure some environment variables for other utilities.
    if not set -q EDITOR
        set -l editors (
            for x in hx nvim vim vi; which $x; end | path filter -x | path basename
        )
        set -x EDITOR $editors[1]
    end
    set -x LESS gij5MR
    set -x RIPGREP_CONFIG_PATH ~/.config/ripgrep.conf

    # Abbreviations are like bash/zsh aliases, but expand in place.
    abbr --add gf --command jj git fetch
    abbr --add cl --command jj --set-cursor git clone --colocate git@github.com:%.git
    abbr --add np --function _node-package-managers
    abbr --add psg pgrep -lf
    abbr --add vi --function _EDITOR

    # Allow `vi` abbr to respond to changes to $EDITOR.
    function _EDITOR
        echo $EDITOR
    end

    # Normalize fancy grep tools.
    function g
        if type -q rg
            rg --pretty $argv | less -FX
        else if git rev-parse --is-inside-work-tree &>/dev/null
            git grep --color --heading --break $argv | less -FX
        else
            grep -R $argv . | less -FX
        end
    end

    # Normalize node package management.
    function _node-package-managers
        if test -f "package-lock.json"
            echo npm
        else if test -f "yarn.lock"
            echo yarn
        else
            echo pnpm
        end
    end

    # Allow for easier upward directory traversal.
    function _rationalise-dot
        set -l words (string split ' ' (commandline --cut-at-cursor))
        if string match -q --regex '^(\.\./)*\.\.$' -- $words[-1]
            commandline --insert /..
        else
            commandline --insert .
        end
    end
    bind . -M insert _rationalise-dot
end
