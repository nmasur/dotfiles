#!/usr/local/bin/fish

if status --is-interactive

    # Aliases
    set PATH $PATH /usr/local/bin ~/.local/bin $DOTS/bin ~/.cargo/bin
    if command -v nvim > /dev/null
        alias vim='nvim'
        abbr -a vimrc 'vim $HOME/.config/nvim/init.vim'
    end
    if [ (uname) = "Linux" ]
        linux
    end

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
    theme_gruvbox dark

    # Fuzzy finder
    fzf_key_bindings
    set -gx FZF_DEFAULT_COMMAND 'fd --type file'
    set -g FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    set -g FZF_DEFAULT_OPTS '-m --height 50% --border'

    # Use `starship` prompt
    starship init fish | source
end
