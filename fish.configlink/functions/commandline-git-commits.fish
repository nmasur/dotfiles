#!/usr/local/bin/fish

function commandline-git-commits
    set commit (git-commits)
    if [ $commit ]
        commandline -i "$commit"
    else
        commandline -i "HEAD"
    end
end
