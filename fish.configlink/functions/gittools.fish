#!/usr/local/bin/fish

function gittools

    function git-fuzzy-branch -a header
        set -l current (git rev-parse --abbrev-ref HEAD | tr -d '\n')
        set -l branch (git branch --format "%(refname:short)" | eval "fzf $FZF_DEFAULT_OPTS --header='On $current, $header'")
        and echo $branch
    end

    function git-checkout-fuzzy
        set branch (git-fuzzy-branch "checkout branch...")
        and git checkout $branch
    end

    function git-merge-fuzzy
        git merge (git-fuzzy-branch "merge from...")
    end

    function git-delete-fuzzy
        git branch -d (git-fuzzy-branch "delete branch...")
    end

end
