#!/usr/local/bin/fish

function notes --description "Notes functions"

    set -g NOTES_PATH $HOME/Documents/notes

    function note_dates
        set -g TODAY_NOTE (date +"%Y-%m-%d_%a")
        set -g YESTERDAY_NOTE (date -jv "-1d" +"%Y-%m-%d_%a")
        set -g TOMORROW_NOTE (date -jv "+1d" +"%Y-%m-%d_%a")
    end

    function note_header
        set -g CURRENT_WEATHER (curl -s "https://wttr.in/?format=1")
        set -g JOURNAL_HEADER "[[$YESTERDAY_NOTE]] | [[home]] | [[$TOMORROW_NOTE]]\n\n---\n\n$CURRENT_WEATHER\n\n# Today's Goals\n\n\n# Journal\n\n"
    end

    function journal --description "Create today's journal"
        note_dates
        if [ -f $NOTES_PATH/$TODAY_NOTE.md ]
            echo "Already exists."
        else
            note_header
            echo $JOURNAL_HEADER > $NOTES_PATH/$TODAY_NOTE.md
            echo "New journal added."
        end
    end

    function today --description "Open today's journal"
        set current_dir $PWD
        cd $NOTES_PATH
        note_dates
        if [ -f $TODAY_NOTE.md ]
            vim $TODAY_NOTE.md
        else
            note_header
            echo $JOURNAL_HEADER > $TODAY_NOTE.md
            echo "New journal added."
            vim $TODAY_NOTE.md
        end
        cd $current_dir
    end

    function meeting --description "Describe a meeting" -a "name"
        note_dates
        set today_date (date -j +"%Y-%m-%d")
        set time (date +"%I:%M%p" | tr '[:upper:]' '[:lower:]')
        set meeting_name (echo $name | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
        set meeting_note $today_date-$meeting_name
        printf "[[$TODAY_NOTE]] | #meeting\n\n# $name\n\n---\n\n" > $NOTES_PATH/$meeting_note.md
        printf "\n\n---\n\n$time - [[$meeting_note]]\n\n---\n\n" >> $NOTES_PATH/$TODAY_NOTE.md
        open "obsidian://open?vault=notes&file=$meeting_note"
    end

    function note --description "Edit or create a note" -a "filename"
        set current_dir $PWD
        cd $NOTES_PATH
        if test -n "$filename"
            vim $filename.md
        else
            set file (ls | fzf)
            if [ $status -eq 0 ]
                vim $file
            end
        end
        cd $current_dir
    end

    abbr -a qn 'quicknote'
    function quicknote --description "Write a quick note" -a "note"
        note_dates
        set time (date +"%I:%M%p" | tr '[:upper:]' '[:lower:]')
        printf "\n\n---\n\n#### [[$TODAY_NOTE]] at $time\n$note\n" >> $NOTES_PATH/quick-notes.md
    end

    abbr -a sn 'syncnotes'
    function syncnotes --description "Full git commit on notes"
        set current_dir $PWD
        cd $NOTES_PATH
        git pull
        git add -A
        git commit -m "autosync"
        git push
        cd $current_dir
    end

end
