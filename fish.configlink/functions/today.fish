function today --description "Open today's journal"
    note-dates
    if [ -f $TODAY_NOTE_FILE ]
        vim $TODAY_NOTE_FILE
    else
        note-header
        printf $JOURNAL_HEADER > $TODAY_NOTE_FILE
        echo "New journal added."
        vim $TODAY_NOTE_FILE
    end
end
