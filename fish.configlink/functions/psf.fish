function psf --description "Search for open process" -a "process"
    ps aux | rg -v "$USER.*rg $argv" | rg $argv
end
