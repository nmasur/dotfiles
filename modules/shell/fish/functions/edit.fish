set vimfile (fzf)
and set vimfile (echo $vimfile | tr -d '\r')
and commandline -r "nvim $vimfile"
and commandline -f execute
