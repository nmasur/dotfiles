#!/usr/bin/env bash

# THEME="$HOME/.config/rofi/config.rasi"

ICON_UP=""
ICON_DOWN=""
ICON_OPT=""
options="$ICON_UP\n$ICON_OPT\n$ICON_DOWN"
chosen="$(echo -e "$options" | rofi -theme-str 'listview { layout:horizontal; }' -dmenu)"
echo "$chosen"
