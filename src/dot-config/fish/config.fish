if test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
end

if test -x ~/.local/bin/mise
    ~/.local/bin/mise activate | source
    ~/.local/bin/mise completion | source
end

if status is-interactive
    fish_config theme choose 'Solarized Dark'
    set fish_color_valid_path # Reset theme's underlines on paths.
    fish_hybrid_key_bindings # vi mode but with emacs-style bindings.
    set fish_cursor_insert line # Use cursor to distinguish insert/normal modes.
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
    abbr --add mr mise run
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

function fish_mode_prompt
    set -l color (test $status = 0; and echo brwhite; or echo brred)
    set -l char (test $fish_bind_mode = insert; and echo '➜'; or echo ':')
    echo -ns (set_color --bold $color) $char (set_color normal) " "
end

function fish_prompt
    set -l suffix (fish_is_root_user; and echo '#'; or echo '%')
    set -l read_only (not test -w .; and echo '🔒')
    echo -ns (prompt_pwd) $read_only $suffix " "
end

function fish_right_prompt
    set -l jj (jj log -r @ -T prompt --ignore-working-copy --no-graph --no-pager --color always 2>/dev/null)
    if test $status = 0
        echo -ns $jj " "
    else
        echo -ns (set_color brblack) (fish_vcs_prompt) (set_color normal) " "
    end
end

# Truncate jj root and home prefixes, and truncate all but the last two elements.
function prompt_pwd
    set -l dir $PWD

    set -l jj_root (jj root 2>/dev/null)
    if test -n "$jj_root"
        set dir (string replace -r (string escape --style=regex -- $jj_root)/? '' $dir)
        set jj_root (basename $jj_root)
    end

    set dir (string replace ~ '~' $dir)
    set components (string split -r / $dir)
    set components (string match -v '' -- $components)
    set components (string sub -l 1 $components[1..-3]) $components[-2..-1]
    echo -n (string join / -- $jj_root $components)
end
