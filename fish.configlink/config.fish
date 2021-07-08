#!/usr/local/bin/fish

if status --is-interactive

    # Add directories to path
    set PATH $PATH \
        /usr/local/bin \
        ~/.local/bin \
        $DOTS/bin \
        ~/.cargo/bin

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

    # Autojump
    zoxide init fish | source

    # Colors
    if test -e $DOTS/fish.configlink/fish_colors
        command cat $DOTS/fish.configlink/fish_colors
    end

    # Fuzzy finder
    fzf_key_bindings
    set -gx FZF_DEFAULT_COMMAND 'fd --type file'
    set -g FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    set -g FZF_DEFAULT_OPTS '-m --height 50% --border'

    source $DOTS/fish.configlink/conf.d/nix-env.fish

    # Use `starship` prompt
    starship init fish | source

    # Hook into direnv
    direnv hook fish | source
end
