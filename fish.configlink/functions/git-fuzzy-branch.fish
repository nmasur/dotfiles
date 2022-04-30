set -l current (git rev-parse --abbrev-ref HEAD | tr -d '\n')
set -l branch (git branch \
    --format "%(refname:short)" \
    | fzf \
        --height 50% \
        --header="On $current, $header" \
        --preview-window right:70% \
        --preview 'git log {} --color=always --pretty="format:%C(auto)%ar %h%d %s"' \
        )
and echo $branch
