#!/usr/local/bin/fish

if status --is-interactive

    # Set $PATH for finding programs
    set FISH_DIR (readlink ~/.config/fish)
    set DOTS (dirname $FISH_DIR)
    set PROJ (dirname $DOTS)
    set PATH $PATH /usr/local/bin ~/.local/bin $DOTS/bin ~/.cargo/bin
    set CDPATH . $HOME $PROJ
    set EDITOR nvim

    # Use `vi` in the shell with cursor shapes
    fish_vi_key_bindings
    bind yy fish_clipboard_copy
    bind Y fish_clipboard_copy
    bind -M visual y fish_clipboard_copy
    bind p fish_clipboard_paste
    set -g fish_vi_force_cursor
    set -g fish_cursor_default block
    set -g fish_cursor_insert line
    set -g fish_cursor_visual block
    set -g fish_cursor_replace_one underscore
    fish_vi_cursor

    # Turn off greeting
    set fish_greeting ""

    # Autojump
    zoxide init fish | source

    # Colors
    theme_gruvbox

    # Individual features
    aliases
    notes
    awstools
    mactools
    gittools
    projects

    # Fuzzy finder
    fzf_key_bindings
    set -g FZF_DEFAULT_COMMAND 'rg --files'
    set -g FZF_DEFAULT_OPTS '-m --height 50% --border'

    # Use `starship` prompt
    starship init fish | source
end

