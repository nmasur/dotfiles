function meeting --description "Describe a meeting" -a "name"
    note-dates
    set today_date (date -j +"%Y-%m-%d")
    set time (date +"%I:%M%p" | tr '[:upper:]' '[:lower:]')
    set meeting_name (echo $name | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
    set meeting_note $today_date-$meeting_name
    printf "[$TODAY_NOTE](journal/$TODAY_NOTE.md) | #meeting\n\n# $name\n\n---\n\n" > $NOTES_PATH/$meeting_note.md
    printf "\n\n---\n\n$time - [$name](../$meeting_note.md)\n\n---\n\n" >> $TODAY_NOTE_FILE
    open "obsidian://open?vault=notes&file=$meeting_note"
end
