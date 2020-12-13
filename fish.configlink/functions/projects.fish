#!/usr/bin/local/fish

function projects --description "Projects tools"

    set PROJ $HOME/dev/work
    alias proj='cd $PROJ'

    function prj --description "cd to a project"
        set projdir (ls $PROJ | fzf)
        and cd $PROJ/$projdir
    end

end
