#!/usr/bin/local/fish

function projects --description "Projects tools"

    alias proj='cd $PROJ'

    function prj --description "cd to a project"
        set projdir (ls $PROJ | fzf)
        if [ $status -eq 0 ]
            cd $projdir
        else
            return 1
        end
    end

end
