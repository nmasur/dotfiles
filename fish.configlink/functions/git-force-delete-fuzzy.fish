function git-force-delete-fuzzy
    set branch (git-fuzzy-branch "force delete branch...")
    and git branch -D $branch
end
