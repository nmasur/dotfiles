set vimfile (fd -t f --exec /usr/bin/stat -f "%m%t%N" | sort -nr | cut -f2 | fzf)
and set vimfile (echo $vimfile | tr -d '\r')
and commandline -r "vim $vimfile"
and commandline -f execute
