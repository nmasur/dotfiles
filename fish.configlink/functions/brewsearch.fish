function brewsearch --description "Install brew plugins"
    set -l inst (brew formulae | eval "fzf $FZF_DEFAULT_OPTS -m --header='[press ctrl-i for info, enter to install]' --bind 'ctrl-i:preview(brew info {})'")

    if not test (count $inst) = 0
        for prog in $inst
            brew install "$prog"
        end
    end
end
