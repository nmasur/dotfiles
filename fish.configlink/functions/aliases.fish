#!/usr/local/bin/fish

function aliases --description 'All aliases'

    # Directory aliases
    alias ls 'exa'                              # exa = improved ls
    abbr -a l 'ls'                              # Quicker shortcut for ls
    abbr -a lh 'ls -lh'                         # Pretty vertical list
    abbr -a ll 'ls -alhF'                       # Include hidden files

    # Git
    abbr -a gs 'git status'
    abbr -a gd 'git diff'
    abbr -a ga 'git add -A'
    abbr -a gc 'git commit -m'
    abbr -a gp 'git push'

    # Vim
    if command -v nvim > /dev/null
        alias vim='nvim'                                    # Use neovim if installed
        abbr -a vimrc 'vim $HOME/.config/nvim/init.vim'     # Edit ".vimrc" file
    end

    # Improved CLI Tools
    alias ping='prettyping --nolegend'
    abbr -a cat 'bat'                           # Swap cat with bat
    abbr -a oldcat 'cat'                        # If we need to use cat
    abbr -a h 'http -Fh --all'                  # Curl site for headers

    # Fun CLI Tools
    alias search='googler -j'
    alias checkip='curl checkip.amazonaws.com'
    alias weather='curl wttr.in'
    alias moon='curl wttr.in/Moon'
    alias ipinfo='curl ipinfo.io'
    alias worldmap='telnet mapscii.me'

    # Dotfile and config shortcuts
    alias reload='source $DOTS/fish.configlink/config.fish'     # Refresh fish shell
    abbr -a boot '$DOTS/scripts/bootstrap'
    abbr -a sshc 'vim ~/.ssh/config'
    abbr -a hosts 'sudo vim /etc/hosts'
    abbr -a frc 'vim $HOME/.config/fish/config.fish'
    abbr -a falias 'vim $HOME/.config/fish/functions/aliases.fish'

    # Cheat Sheets
    alias proj='cd $PROJ'
    abbr -a ssl 'openssl req -new -newkey rsa:2048 -nodes' \
                '-keyout server.key -out server.csr'

    # Docker
    abbr -a dc '$DOTS/bin/docker_cleanup'
    abbr -a dr 'docker run'
    abbr -a db 'docker build . -t'
    alias connect='docker run --rm -v ~/.aws:/root/.aws -v ~/.ssh:/root/.ssh -it connect-aws'

    # Terraform
    abbr -a te 'terraform'

    # Python
    abbr py 'python'
    alias domisty='cd $PROJ/misty && ./buildrun.sh'

    # Rust
    abbr -a ca 'cargo'

    # Non-MacOS
    if [ (uname) = "Linux" ]
        alias pbcopy='xclip -selection clipboard -in'
        alias pbpaste='xclip -selection clipboard -out'
    end

end
