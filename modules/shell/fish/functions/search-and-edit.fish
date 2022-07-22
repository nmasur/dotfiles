set vimfile ( \
    rg \
      --color=always \
      --line-number \
      --no-heading \
      --smart-case \
      --iglob "!/Library/**" \
      --iglob "!/System/**" \
      --iglob "!Users/$HOME/Library/*" \
      ".*" \
    | fzf --ansi \
        --height "80%" \
        --color "hl:-1:underline,hl+:-1:underline:reverse" \
        --delimiter : \
        --preview 'bat --color=always {1} --highlight-line {2}' \
        --preview-window 'up,60%,border-bottom,+{2}+3/3,~3'
)
and set line_number (echo $vimfile | tr -d '\r' | cut -d':' -f2)
and set vimfile (echo $vimfile | tr -d '\r' | cut -d':' -f1)
and commandline -r "vim +$line_number $vimfile"
and commandline -f execute
