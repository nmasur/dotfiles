if count $argv >/dev/null
    curl ipinfo.io/$argv
else
    curl checkip.amazonaws.com
end
