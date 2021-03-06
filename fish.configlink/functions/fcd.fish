function fcd --description 'Jump to directory' -a 'directory'
    if test -z $directory
        set directory "$HOME"
    end
    if ! test -d $directory
        echo "Directory not found: $directory"
        return 1
    end
    set jump (fd -t d . $directory | fzf)
    and cd $jump $argv;
end
