#!/usr/local/bin/fish

function gittools

    function git-fuzzy-branch -a header
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
    end

    function git-commits
        set commitline (git log \
            --pretty="format:%C(auto)%ar %h%d %s" \
            | fzf \
                --height 50% \
                --preview 'git show --color=always (echo {} | cut -d" " -f4)' \
                )
        and set commit (echo $commitline | cut -d" " -f4)
        and echo $commit
    end

    function git-checkout-fuzzy
        set branch (git-fuzzy-branch "checkout branch...")
        and git checkout $branch
    end

    function git-show-fuzzy
        set commit (git log --pretty=oneline | fzf | cut -d' ' -f1)
        and git show $commit
    end

    function git-add-fuzzy
        set gitfile (git status -s \
            | fzf \
                --height 50% \
                -m \
                --preview-window right:70% \
                --preview 'set -l IFS; set gd (git diff --color=always (echo {} | awk \'{$1=$1};1\' | cut -d" " -f2)); if test "$gd"; echo "$gd"; else; bat --color=always (echo {} | awk \'{$1=$1};1\' | cut -d" " -f2); end')
        and for gf in $gitfile
            set gf (echo $gf \
                | awk '{$1=$1};1' \
                | cut -d' ' -f2 \
                )
            and git add $gf
        end
    end

    function git-merge-fuzzy
        set branch (git-fuzzy-branch "merge from...")
        and git merge $branch
    end

    function git-delete-fuzzy
        set branch (git-fuzzy-branch "delete branch...")
        and git branch -d $branch
    end

    function git-force-delete-fuzzy
        set branch (git-fuzzy-branch "force delete branch...")
        and git branch -D $branch
    end

    function git
        if contains f $argv
            switch $argv[1]
                case "checkout"
                    git-checkout-fuzzy
                case "add"
                    git-add-fuzzy
                case "show"
                    git-show-fuzzy
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
                case "reset"
                    set commit (git-commits)
                    and if test "$argv[2]" = "--hard"
                        git reset --hard $commit
                    else
                        git reset $commit
                    end
                case "*"
                    echo "No fuzzy option."
                    return 1
                end
        else
            if count $argv > /dev/null
                command git $argv
            else
                command git status -sb
            end
        end
    end

end
