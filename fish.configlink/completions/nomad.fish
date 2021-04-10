
function __complete_nomad
    set -lx COMP_LINE (commandline -cp)
    test -z (commandline -ct)
    and set COMP_LINE "$COMP_LINE "
    /usr/local/bin/nomad
end
complete -f -c nomad -a "(__complete_nomad)"

