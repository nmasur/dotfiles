#!/usr/local/bin/fish

function notes --description "Notes functions"

    set -gx NOTES_PATH $HOME/notes

    function note_dates
        set -g TODAY_NOTE (date +"%Y-%m-%d_%a")
        set -g YESTERDAY_NOTE (date -jv "-1d" +"%Y-%m-%d_%a")
        set -g TOMORROW_NOTE (date -jv "+1d" +"%Y-%m-%d_%a")
        set -g LONG_DATE (date +"%A, %B %e, %Y" | sed 's/  */ /g')
        set -g TODAY_NOTE_FILE $NOTES_PATH/journal/$TODAY_NOTE.md
    end

    function note_header
        set -g CURRENT_WEATHER (curl -s "https://wttr.in/?format=1")
        set -g JOURNAL_HEADER "[Yesterday]($YESTERDAY_NOTE.md) | [Home](home.md) | [Tomorrow]($TOMORROW_NOTE.md)\n\n$LONG_DATE\n$CURRENT_WEATHER\n#journal\n\n---\n\n# Today's Goals\n\n\n# Journal\n\n"
    end

    function journal --description "Create today's journal"
        note_dates
        if [ -f $TODAY_NOTE_FILE ]
            echo "Already exists."
        else
            note_header
            printf $JOURNAL_HEADER > $TODAY_NOTE_FILE
            echo "New journal added."
        end
    end

    function today --description "Open today's journal"
        note_dates
        if [ -f $TODAY_NOTE_FILE ]
            vim $TODAY_NOTE_FILE
        else
            note_header
            printf $JOURNAL_HEADER > $TODAY_NOTE_FILE
            echo "New journal added."
            vim $TODAY_NOTE_FILE
        end
    end

    function meeting --description "Describe a meeting" -a "name"
        note_dates
        set today_date (date -j +"%Y-%m-%d")
        set time (date +"%I:%M%p" | tr '[:upper:]' '[:lower:]')
        set meeting_name (echo $name | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
        set meeting_note $today_date-$meeting_name
        printf "[$TODAY_NOTE](journal/$TODAY_NOTE.md) | #meeting\n\n# $name\n\n---\n\n" > $NOTES_PATH/$meeting_note.md
        printf "\n\n---\n\n$time - [$name](../$meeting_note)\n\n---\n\n" >> $TODAY_NOTE_FILE
        open "obsidian://open?vault=notes&file=$meeting_note"
    end

    function note --description "Edit or create a note" -a "filename"
        if test -n "$filename"
            vim $NOTES_PATH/$filename.md
        else
            set file (ls $NOTES_PATH | fzf)
            if [ $status -eq 0 ]
                vim $NOTES_PATH/$file
            end
        end
    end

    abbr -a qn 'quicknote'
    function quicknote --description "Write a quick note" -a "note"
        note_dates
        set time (date +"%I:%M%p" | tr '[:upper:]' '[:lower:]')
        printf "\n\n---\n\n#### $time\n$note\n" >> $TODAY_NOTE_FILE
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
