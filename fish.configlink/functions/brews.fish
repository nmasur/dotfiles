function brews --description "Open Homebrew bundles file"
    set -lx brewdir $DOTS/homebrew
    set -l brewfile (basename $brewdir/*.Brewfile \
        | fzf \
            --height 70% \
            --preview-window right:70% \
            --preview 'bat --color=always $brewdir/{}' \
    )
    and vim $brewdir/$brewfile
end
