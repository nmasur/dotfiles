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
        set branch (git-fuzzy-branch "merge from...")
        and git merge
    end

    function git-delete-fuzzy
        set branch (git-fuzzy-branch "delete branch...")
        and git branch -d
    end

    function git-force-delete-fuzzy
        set branch (git-fuzzy-branch "force delete branch...")
        and git branch -D
    end

    function git
        if contains f $argv
            switch $argv[1]
                case "checkout"
                    git-checkout-fuzzy
                case "merge"
                    git-merge-fuzzy
                case "branch"
                    if test "$argv[2]" = "-d"
                        git-delete-fuzzy
                    else if test "$argv[2]" = "-D"
                        git-force-delete-fuzzy
                    else
                        echo "Not a fuzzy option."
                        return 1
                    end
                case "*"
                    echo "No fuzzy option."
                    return 1
                end
        else
            command git $argv
        end
    end

end
