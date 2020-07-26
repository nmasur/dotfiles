#!/usr/local/bin/fish

if status --is-interactive

    # Set $PATH for finding programs
    set FISH_DIR (readlink ~/.config/fish)
    set DOTS (dirname $FISH_DIR)
    set PROJ (dirname $DOTS)
    set PATH $PATH /usr/local/bin ~/.local/bin $DOTS/bin ~/.cargo/bin
    set CDPATH . $HOME $PROJ $DOTS

    # Use `vi` in the shell
    fish_vi_key_bindings
    set XTERM_VERSION hello
    fish_vi_cursor
    set fish_cursor_default block
    set fish_cursor_insert line
    set fish_cursor_replace_one underscore
    set fish_cursor_visual block

    # Turn off greeting
    set fish_greeting ""

    # Autojump
    [ -f /usr/local/share/autojump/autojump.fish ]; and source /usr/local/share/autojump/autojump.fish

    # Colors
    theme_gruvbox

    # Aliases
    aliases

    # Individual features
    pyenv

    # Use `starship` prompt
    starship init fish | source
end

