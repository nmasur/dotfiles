function recent --description "Open a recent file in Vim"
    set vimfile (fd --exec stat -f "%m%t%N" | sort -nr | cut -f2 | fzf)
    and vim $vimfile
end
