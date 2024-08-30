if test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
end

if status is-interactive
    fish_config theme choose 'Solarized Dark'
    set fish_color_valid_path    # Reset theme's underlines on paths.
    starship init fish | source  # Set prompt.

    fish_hybrid_key_bindings     # vi mode but with emacs-style bindings.
    set fish_cursor_insert line  # Use cursor to distinguish insert/normal modes.

    set fish_greeting            # Shhh.
    set __fish_ls_command ls -F  # Avoid default ls colors added by fish.

    # Configure some environment variables for other utilities.
    if not set -q EDITOR
        set -l editors (
            path filter -x (which nvim) (which vim) (which vi) | path basename
        )
        set -x EDITOR $editors[1]
    end
    set -x LESS gij5MR
    set -x RIPGREP_CONFIG_PATH ~/.config/ripgrep.conf

    # Abbreviations are like bash/zsh aliases, but expand in place.
    bind . self-insert expand-abbr
    abbr --add dot --regex '(\.\./)*\.\.\.' --position anywhere --function rationalise-dot
    abbr --add np --function node-package-managers
    abbr --add psg pgrep -lf
    abbr --add vi --function EDITOR

    # Allow `vi` abbr to respond to changes to $EDITOR.
    function EDITOR
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
    function node-package-managers
        if test -f "package-lock.json"; echo npm
        else if test -f "yarn.lock"; echo yarn
        else; echo pnpm
        end
    end

    # Allow for easier upward directory traversal.
    function rationalise-dot
        set -l count (string split / $argv[1] | count)
        string repeat -n (math $count + 1) ../ | string trim -r -c /
    end
end
