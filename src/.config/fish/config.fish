if test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
end

if status is-interactive
    fish_config theme choose 'Solarized Dark'
    set fish_color_valid_path
    starship init fish | source

    fish_vi_key_bindings
    set fish_cursor_insert line

    set fish_greeting
    set __fish_ls_command ls -F

    if not set -q EDITOR
        set -l editors (
            path filter -x (which nvim) (which vim) (which vi) | path basename
        )
        set -x EDITOR $editors[1]
    end
    function EDITOR; echo $EDITOR; end
    set -x LESS gij5MR
    set -x RIPGREP_CONFIG_PATH ~/.config/ripgrep.conf

    abbr --add dotdot --regex '^\.\.+$' --function rationalise-dot
    abbr --add np --function node-package-managers
    abbr --add psg pgrep -lf
    abbr --add vi --function EDITOR

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
    # TODO: allow for this to expand anywhere so I can use it eg mv ../../
    function rationalise-dot
        echo (string repeat -n (math (string length -- $argv[1]) - 1) ../)
    end
end
