#!/usr/local/bin/fish

function mactools
    function copy --description 'Copy file contents into clipboard'
        cat $argv | pbcopy
    end
end
