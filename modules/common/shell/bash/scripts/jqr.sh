#!/usr/bin/env bash

# Adapted from: https://gist.github.com/reegnz/b9e40993d410b75c2d866441add2cb55

if [[ -z $1 ]] || [[ $1 == "-" ]]; then
    input=$(mktemp)
    trap 'rm -f $input' EXIT
    cat /dev/stdin >"$input"
else
    input=$1
fi

echo '' |
    fzf --phony \
        --height 100% \
        --preview-window='up:80%' \
        --query '.' \
        --print-query \
        --header $'CTRL-O: jq output\nCTRL-Y: copy output\nALT-Y: copy query' \
        --preview "jq --color-output -r {q} $input" \
        --bind "ctrl-o:execute(jq -r {q} $input)+clear-query+accept" \
        --bind "alt-y:execute(echo {q} | pbcopy)" \
        --bind "ctrl-y:execute(jq -r {q} $input | pbcopy)"
