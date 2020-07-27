#!/usr/local/bin/fish

if status --is-interactive

    # Set $PATH for finding programs
    set FISH_DIR (readlink ~/.config/fish)
    set DOTS (dirname $FISH_DIR)
    set PROJ (dirname $DOTS)
    set PATH $PATH /usr/local/bin ~/.local/bin $DOTS/bin ~/.cargo/bin
    set CDPATH . $HOME $PROJ $DOTS

    # Use `vi` in the shell with cursor shapes
    fish_vi_key_bindings
    set -g fish_vi_force_cursor
    set -g fish_cursor_default block
    set -g fish_cursor_insert line
    set -g fish_cursor_visual block
    set -g fish_cursor_replace_one underscore
    fish_vi_cursor

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
    notes
    aws

    # Use `starship` prompt
    starship init fish | source
end

