function brewinfo --description "Lookup brew plugins"
    set -l inst (brew search | eval "fzf $FZF_DEFAULT_OPTS -m --header='[brew:info]'")

    if not test (count $inst) = 0
        for prog in $inst
            brew info "$prog"
        end
    end
end
