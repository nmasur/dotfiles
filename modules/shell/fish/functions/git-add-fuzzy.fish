set gitfile (git status -s \
    | fzf \
        --height 50% \
        -m \
        --preview-window right:70% \
        --layout reverse \
        --preview 'set -l IFS; set gd (git diff --color=always (echo {} | awk \'{$1=$1};1\' | cut -d" " -f2)); if test "$gd"; echo "$gd"; else; bat --color=always (echo {} | awk \'{$1=$1};1\' | cut -d" " -f2); end')
and for gf in $gitfile
    set gf (echo $gf \
        | awk '{$1=$1};1' \
        | cut -d' ' -f2 \
        )
    and git add $gf
end
