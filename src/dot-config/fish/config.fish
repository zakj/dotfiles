if test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv | source
end

if test -x ~/.local/bin/mise
    ~/.local/bin/mise activate | source
    ~/.local/bin/mise completion fish | source
end

if status is-interactive
    fish_config theme choose 'Solarized Dark'
    set fish_color_valid_path # Reset theme's underlines on paths.
    set fish_greeting # Shhh.
    set __fish_ls_command ls -F # Avoid default ls colors added by fish.
    # Set a line cursor at the prompt, but fall back to block elsewhere.
    set fish_cursor_default line
    set fish_cursor_external block
    fish_vi_cursor

    # Configure some environment variables for other utilities.
    if not set -q EDITOR
        set -l editors (
            for x in hx nvim vim vi; which $x; end | path filter -x | path basename
        )
        set -x EDITOR $editors[1]
    end
    set -x LESS gij5MR
    set -x RIPGREP_CONFIG_PATH ~/.config/ripgrep.conf

    # cd to any ~/src/* without repetition.
    test -d ~/src; and set CDPATH . ~/src

    # Abbreviations are like bash/zsh aliases, but expand in place.
    abbr --add gf --command jj git fetch
    abbr --add L --position anywhere --set-cursor "%| less"
    abbr --add mr mise run
    abbr --add np --function _node-package-managers
    abbr --add psg pgrep -lf

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
        string replace '...' '../..' (commandline -t)
    end
    abbr --add ... --position anywhere --regex '[./]*\.\.\.' --function _rationalise-dot
    bind . self-insert expand-abbr

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

    # Grep and edit matches.
    function ge
        $EDITOR (rg --column $argv | cut -d : -f -3)
    end
end

function fish_prompt
    set -l color (test $status = 0; and echo brwhite; or echo brred)
    set -l prefix (echo -ns (set_color --bold $color) '➜' (set_color normal))
    set -l suffix (fish_is_root_user; and echo '#'; or echo '%')
    set -l read_only (test -w .; or echo '🔒')
    echo -ns $prefix " " (prompt_pwd) $read_only $suffix " "
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
        set dir (string replace $jj_root (basename $jj_root) $dir)
    end

    set dir (string replace $HOME '~' $dir)
    set components (string split -r / $dir)
    set components (string sub -l 1 $components[1..-3]) $components[-2..-1]
    echo -n (string join / -- $components)
end
