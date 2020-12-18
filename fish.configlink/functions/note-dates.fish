function note-dates
    set -g TODAY_NOTE (date +"%Y-%m-%d_%a")
    set -g YESTERDAY_NOTE (date -jv "-1d" +"%Y-%m-%d_%a")
    set -g TOMORROW_NOTE (date -jv "+1d" +"%Y-%m-%d_%a")
    set -g LONG_DATE (date +"%A, %B %e, %Y" | sed 's/  */ /g')
    set -g TODAY_NOTE_FILE $NOTES_PATH/journal/$TODAY_NOTE.md
end
