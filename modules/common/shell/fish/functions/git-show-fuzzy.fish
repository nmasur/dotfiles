set commitline (git log \
   --pretty="format:%C(auto)%ar %h%d %s" \
   | fzf \
   )
and set commit (echo $commitline | cut -d" " -f4 )
and git show $commit
