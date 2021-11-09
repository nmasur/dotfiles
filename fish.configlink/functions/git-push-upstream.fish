function git-push-upstream --description "Create upstream branch"
    set -l branch (git branch 2>/dev/null | grep '^\*' | colrm 1 2)
    set -l command "git push --set-upstream origin $branch"
    commandline -r $command
    commandline -f execute
end
