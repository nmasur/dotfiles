#!/usr/local/bin/fish

function aliases --description 'All aliases'

    # Directory aliases
    alias ls 'exa'                              # exa = improved ls
    abbr -a l 'ls'                              # Quicker shortcut for ls
    abbr -a lh 'ls -lh'                         # Pretty vertical list
    abbr -a ll 'ls -alhF'                       # Include hidden files
    abbr -a c 'cd'

    # Tmux
    abbr -a ta 'tmux attach-session'
    abbr -a tan 'tmux attach-session -t noah'

    # Git
    abbr -a gs 'git status'
    abbr -a gd 'git diff'
    abbr -a gds 'git diff --staged'
    abbr -a ga 'git add'
    abbr -a gaa 'git add -A'
    abbr -a gc 'git commit -m'
    abbr -a gcm 'git commit -am'
    abbr -a gca 'git commit --amend'
    abbr -a gu 'git pull'
    abbr -a gp 'git push'
    abbr -a gpp 'git_set_upstream'
    abbr -a gl 'git log --graph --decorate --oneline -20'
    abbr -a gll 'git log --graph --decorate --oneline'
    abbr -a gco 'git checkout'
    abbr -a gcob 'git checkout -b'
    abbr -a gb 'git branch'
    abbr -a grh 'git reset --hard'
    abbr -a ghb 'gh repo view -w'

    # Vim
    abbr -a v 'vim'
    if command -v nvim > /dev/null
        alias vim='nvim'                                    # Use neovim if installed
        abbr -a vimrc 'vim $HOME/.config/nvim/init.vim'     # Edit ".vimrc" file
    end

    # Improved CLI Tools
    alias ping='prettyping --nolegend'
    abbr -a cat 'bat'                           # Swap cat with bat
    abbr -a h 'http -Fh --all'                  # Curl site for headers

    # Fun CLI Tools
    alias search='googler -j'
    alias checkip='curl checkip.amazonaws.com'
    alias weather='curl wttr.in'
    alias moon='curl wttr.in/Moon'
    alias ipinfo='curl ipinfo.io'
    alias worldmap='telnet mapscii.me'
    function qr
        qrencode $argv[1] -o /tmp/qr.png | open /tmp/qr.png
    end

    # Dotfile and config shortcuts
    alias reload='source $DOTS/fish.configlink/config.fish'     # Refresh fish shell
    abbr -a boot '$DOTS/scripts/bootstrap'
    abbr -a sshc 'vim ~/.ssh/config'
    abbr -a hosts 'sudo nvim /etc/hosts'
    abbr -a frc 'vim $HOME/.config/fish/config.fish'
    abbr -a falias 'vim $HOME/.config/fish/functions/aliases.fish'

    # Cheat Sheets
    abbr -a ssl 'openssl req -new -newkey rsa:2048 -nodes' \
                '-keyout server.key -out server.csr'
    abbr -a get-fingerprint 'ssh-keyscan myhost.com | ssh-keygen -lf -'
    abbr -a public-key 'ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub'

    # Docker
    abbr -a dc '$DOTS/bin/docker_cleanup'
    abbr -a dr 'docker run --rm -it'
    abbr -a db 'docker build . -t'
    abbr -a ds 'docker ps -a'
    abbr -a de 'docker exec -it'
    alias connect='docker run --rm -v ~/.aws:/root/.aws -v ~/.ssh:/root/.ssh -it connect-aws'

    # Terraform
    abbr -a te 'terraform'

    # Kubernetes
    abbr -a k 'kubectl'
    abbr -a pods 'kubectl get pods -A'
    abbr -a nodes 'kubectl get nodes'
    abbr -a deploys 'kubectl get deployments -A'
    abbr -a dash 'kube-dashboard'

    # Python
    abbr -a py 'python'
    abbr -a dpy 'docker run --rm -it -v $PWD:/project python:alpine python'
    abbr -a po 'poetry'
    abbr -a pr 'poetry run python'
    abbr -a pl 'poetry run pylint *'
    abbr -a black 'poetry run black --target-version py38 .'
    abbr -a bl 'poetry run black --target-version py38 .'
    alias domisty='cd $PROJ/misty && ./buildrun.sh'

    # Rust
    abbr -a ca 'cargo'

    # Non-MacOS
    if [ (uname) = "Linux" ]
        alias pbcopy='xclip -selection clipboard -in'
        alias pbpaste='xclip -selection clipboard -out'
    end

end
