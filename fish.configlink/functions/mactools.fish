#!/usr/local/bin/fish

function mactools

    function copy --description 'Copy file contents into clipboard'
        cat $argv | pbcopy
    end

    abbr -a brews 'vim $DOTS/homebrew/Brewfile'
    abbr -a casks 'vim $DOTS/homebrew/Caskfile'

    function brewsearch --description "Install brew plugins"
        set -l inst (brew search | eval "fzf $FZF_DEFAULT_OPTS -m --header='[brew:install]'")

        if not test (count $inst) = 0
            for prog in $inst
                brew install "$prog"
            end
        end
    end

end
