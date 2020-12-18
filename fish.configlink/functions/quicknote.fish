function quicknote --description "Write a quick note" -a "note"
    note-dates
    set time (date +"%I:%M%p" | tr '[:upper:]' '[:lower:]')
    printf "\n\n---\n\n#### $time\n$note\n" >> $TODAY_NOTE_FILE
end
