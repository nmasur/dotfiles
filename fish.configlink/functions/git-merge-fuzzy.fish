function git-merge-fuzzy
    set branch (git-fuzzy-branch "merge from...")
    and git merge $branch
end
