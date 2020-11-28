#!/usr/local/bin/fish

function mactools

    function copy --description 'Copy file contents into clipboard'
        cat $argv | pbcopy
    end

    abbr -a casks 'vim $DOTS/homebrew/Caskfile'

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

    function brewinfo --description "Lookup brew plugins"
        set -l inst (brew search | eval "fzf $FZF_DEFAULT_OPTS -m --header='[brew:info]'")

        if not test (count $inst) = 0
            for prog in $inst
                brew info "$prog"
            end
        end
    end

    function brewsearch --description "Install brew plugins"
        set -l inst (brew search | eval "fzf $FZF_DEFAULT_OPTS -m --header='[brew:install]'")

        if not test (count $inst) = 0
            for prog in $inst
                brew install "$prog"
            end
        end
    end

end
