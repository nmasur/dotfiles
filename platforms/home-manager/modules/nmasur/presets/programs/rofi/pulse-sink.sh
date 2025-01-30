#!/usr/bin/env bash

# Credit: https://gist.github.com/Nervengift/844a597104631c36513c

sink=$(
    ponymix -t sink list |
        awk '/^sink/ {s=$1" "$2;getline;gsub(/^ +/,"",$0);print s" "$0}' |
        rofi \
            -dmenu \
            -p 'pulseaudio sink:' \
            -width 100 \
            -hover-select \
            -me-select-entry '' \
            -me-accept-entry MousePrimary \
            -theme-str 'inputbar { enabled: false; }' |
        grep -Po '[0-9]+(?=:)'
) &&
    ponymix set-default -d "$sink" &&
    for input in $(ponymix list -t sink-input | grep -Po '[0-9]+(?=:)'); do
        echo "$input -> $sink"
        ponymix -t sink-input -d "$input" move "$sink"
    done
