function git-show-fuzzy
    set commit (git log --pretty=oneline | fzf | cut -d' ' -f1)
    and git show $commit
end
