#!/usr/local/bin/fish

function uncommitted --description "Find uncommitted git repos"
    set current_dir (pwd)
    cd $HOME/dev
    find . -type d -name '.git' | \
        while read dir
            cd $dir/../
            and if test -n (echo (git status -s))
                pwd
                git status -s
            end
            cd -
        end
    cd $current_dir
end
