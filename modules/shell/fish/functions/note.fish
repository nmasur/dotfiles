if test -n "$filename"
    vim $NOTES_PATH/$filename.md
else
    set file (ls $NOTES_PATH | fzf)
    if [ $status -eq 0 ]
        vim $NOTES_PATH/$file
    end
end
