#!/usr/local/bin/fish

if status --is-interactive

    # Set $PATH for finding programs
    set FISH_DIR (readlink ~/.config/fish)
    set DOTS (dirname $FISH_DIR)
    set PATH $PATH /usr/local/bin ~/.local/bin $DOTS/bin ~/.cargo/bin
    set CDPATH . $HOME
    set EDITOR nvim
    set PROJ $HOME/dev/work
    set -gx NOTES_PATH $HOME/notes

    # Aliases
    alias reload='source $DOTS/fish.configlink/config.fish'
    alias ls 'exa'
    alias proj 'cd $PROJ'
    if command -v nvim > /dev/null
        alias vim='nvim'
        abbr -a vimrc 'vim $HOME/.config/nvim/init.vim'
    end
    alias ping='prettyping --nolegend'
    alias weather='curl wttr.in/$WEATHER_CITY'
    alias moon='curl wttr.in/Moon'
    alias ipinfo='curl ipinfo.io'
    alias worldmap='telnet mapscii.me'
    alias connect='docker run --rm -v ~/.aws:/root/.aws -v ~/.ssh:/root/.ssh -it connect-aws'
    if [ (uname) = "Linux" ]
        alias pbcopy='xclip -selection clipboard -in'
        alias pbpaste='xclip -selection clipboard -out'
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

    # Turn off greeting
    set fish_greeting ""

    # Autojump
    zoxide init fish | source

    # Colors
    theme_gruvbox dark

    # Fuzzy finder
    fzf_key_bindings
    set -g FZF_DEFAULT_COMMAND 'fd --type file'
    set -g FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    set -g FZF_DEFAULT_OPTS '-m --height 50% --border'

    # Use `starship` prompt
    starship init fish | source
end

