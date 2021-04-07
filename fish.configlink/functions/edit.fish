function edit --description "Open a file in Vim"
    set vimfile (fzf)
    and vim $vimfile
end

