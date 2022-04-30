set commitline (git log \
    --pretty="format:%C(auto)%ar %h%d %s" \
    | fzf \
        --height 50% \
        --preview 'git show --color=always (echo {} | cut -d" " -f4)' \
        )
and set commit (echo $commitline | cut -d" " -f4)
and echo $commit
