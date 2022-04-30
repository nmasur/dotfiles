if contains f $argv
    switch $argv[1]
        case checkout
            git-checkout-fuzzy
        case add
            git-add-fuzzy
        case show
            git-show-fuzzy
        case merge
            git-merge-fuzzy
        case branch
            if test "$argv[2]" = -d
                git-delete-fuzzy
            else if test "$argv[2]" = -D
                git-force-delete-fuzzy
            else
                echo "Not a fuzzy option."
                return 1
            end
        case reset
            set commit (git-commits)
            and if test "$argv[2]" = --hard
                git reset --hard $commit
            else
                git reset $commit
            end
        case "*"
            echo "No fuzzy option."
            return 1
    end
else
    if count $argv >/dev/null
        command git $argv
    else
        command git status -sb
    end
end
