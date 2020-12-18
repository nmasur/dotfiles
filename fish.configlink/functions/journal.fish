function journal --description "Create today's journal"
    note-dates
    if [ -f $TODAY_NOTE_FILE ]
        echo "Already exists."
    else
        note-header
        printf $JOURNAL_HEADER > $TODAY_NOTE_FILE
        echo "New journal added."
    end
end
