function psf
    ps aux | rg -v "$USER.*rg $argv" | rg $argv
end
