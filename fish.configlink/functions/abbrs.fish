#!/usr/local/bin/fish

function abbrs --description 'All abbreviations'

    # Directory aliases
    abbr -a l 'ls'
    abbr -a lh 'ls -lh'
    abbr -a ll 'ls -alhF'
    abbr -a lf 'ls -lh | fzf'
    abbr -a c 'cd'
    abbr -a -- - 'cd -'
    abbr -a proj 'cd $PROJ'
    abbr -a mkd 'mkdir -pv'

    # Tmux
    abbr -a ta 'tmux attach-session'
    abbr -a tan 'tmux attach-session -t noah'
    abbr -a tnn 'tmux new-session -s noah'

    # Git
    abbr -a gs 'git status'
    abbr -a gd 'git diff'
    abbr -a gds 'git diff --staged'
    abbr -a gdp 'git diff HEAD^'
    abbr -a ga 'git add'
    abbr -a gaa 'git add -A'
    abbr -a gac 'git commit -am'
    abbr -a gc 'git commit -m'
    abbr -a gca 'git commit --amend'
    abbr -a gu 'git pull'
    abbr -a gp 'git push'
    abbr -a gpp 'git_set_upstream'
    abbr -a gl 'git log --graph --decorate --oneline -20'
    abbr -a gll 'git log --graph --decorate --oneline'
    abbr -a gco 'git checkout'
    abbr -a gcom 'git checkout master'
    abbr -a gcob 'git checkout -b'
    abbr -a gb 'git branch'
    abbr -a gbd 'git branch -d'
    abbr -a gbD 'git branch -D'
    abbr -a gr 'git reset'
    abbr -a grh 'git reset --hard'
    abbr -a grm 'git reset --mixed'
    abbr -a gm 'git merge'
    abbr -a gmf 'git-merge-fuzzy'
    abbr -a gcp 'git cherry-pick'
    abbr -a ghr 'gh repo view -w'
    abbr -a cdg 'cd (git rev-parse --show-toplevel)'

    # Vim
    abbr -a v 'vim'
    abbr -a vimrc 'vim $HOME/.vimrc'
    abbr -a vl 'vim -c "normal! `0"'
    abbr -a vh 'vim -c "Hist"'

    # Notes
    abbr -a qn 'quicknote "'
    abbr -a sn 'syncnotes'

    # Improved CLI Tools
    abbr -a cat 'bat'          # Swap cat with bat
    abbr -a h 'http -Fh --all' # Curl site for headers

    # Fun CLI Tools
    abbr goo 'googler'
    abbr gooj 'googler -j'

    # Dotfile and config shortcuts
    abbr -a s 'sudo'
    abbr -a boot '$DOTS/scripts/bootstrap'
    abbr -a sshc 'vim ~/.ssh/config'
    abbr -a hosts 'sudo nvim /etc/hosts'
    abbr -a frc 'vim $HOME/.config/fish/config.fish'
    abbr -a falias 'vim $HOME/.config/fish/functions/abbrs.fish'

    # Cheat Sheets
    abbr -a ssl 'openssl req -new -newkey rsa:2048 -nodes' \
                '-keyout server.key -out server.csr'
    abbr -a fingerprint 'ssh-keyscan myhost.com | ssh-keygen -lf -'
    abbr -a publickey 'ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub'

    # Docker
    abbr -a dc '$DOTS/bin/docker_cleanup'
    abbr -a dr 'docker run --rm -it'
    abbr -a db 'docker build . -t'
    abbr -a ds 'docker ps -a'
    abbr -a de 'docker exec -it'
    abbr -a dpy 'docker run --rm -it -v $PWD:/project python:alpine python'
    abbr -a alp 'docker run --rm -it -v $PWD:/project alpine sh'

    # Terraform
    abbr -a te 'terraform'
    abbr -a tap 'terraform apply'

    # Kubernetes
    abbr -a k 'kubectl'
    abbr -a pods 'kubectl get pods -A'
    abbr -a nodes 'kubectl get nodes'
    abbr -a deploys 'kubectl get deployments -A'
    abbr -a dash 'kube-dashboard'
    abbr -a ks 'k9s'

    # Python
    abbr -a py 'python'
    abbr -a po 'poetry'
    abbr -a pr 'poetry run python'
    abbr -a pl 'poetry run pylint *'
    abbr -a black 'poetry run black --target-version py38 .'
    abbr -a bl 'poetry run black --target-version py38 .'

    # Rust
    abbr -a ca 'cargo'

    # macOS
    abbr -a casks 'vim $DOTS/homebrew/Caskfile'

end
