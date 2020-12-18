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
