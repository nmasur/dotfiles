function git-delete-fuzzy
    set branch (git-fuzzy-branch "delete branch...")
    and git branch -d $branch
end
