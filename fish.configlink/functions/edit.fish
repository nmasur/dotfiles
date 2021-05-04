function edit --description "Open a file in Vim"
    set vimfile (fzf)
    and set vimfile (echo $vimfile | tr -d '\r')
    and commandline -r "vim $vimfile"
    and commandline -f execute
end
