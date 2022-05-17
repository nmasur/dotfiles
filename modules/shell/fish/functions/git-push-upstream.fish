set -l branch (git branch 2>/dev/null | grep '^\*' | colrm 1 2)
and set -l command "git push --set-upstream origin $branch"
and commandline -r $command
and commandline -f execute
and echo "git push --set-upstream origin $branch"
and git push --set-upstream origin $branch
