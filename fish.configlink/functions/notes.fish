#!/usr/local/bin/fish

function notes --description "Notes functions"

    function journal --description "Create today's journal"
        set today (date -j +"%Y-%m-%d_%a")
        set today_journal $HOME/Documents/notes/journal/$today.md
        if [ -f $today_journal ]
            echo "Already exists."
        else
            set yesterday (date -jv "-1d" +"%Y-%m-%d_%a")
            set tomorrow (date -jv "+1d" +"%Y-%m-%d_%a")
            printf "[[journal/$yesterday|Previous]] - [[calendar|Index]] - [[journal/$tomorrow|Next]]\n\n---\n\n # Tasks\n\n\n# Log\n\n\n# Communication\n\n---\n\n# Meetings\n\n" > $today_journal
            echo "New journal added."
        end
    end

end
