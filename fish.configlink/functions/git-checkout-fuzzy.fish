function git-checkout-fuzzy
    set branch (git-fuzzy-branch "checkout branch...")
    and git checkout $branch
end
