#!/usr/bin/env sh

# Credit: https://gitlab.com/vahnrr/rofi-menus/-/blob/b1f0e8a676eda5552e27ef631b0d43e660b23b8e/scripts/rofi-prompt

# Rofi powered menu to prompt a message and get a yes/no answer.
# Uses: rofi

yes='Confirm'
no='Cancel'
query='Are you sure?'

while [ $# -ne 0 ]; do
    case "$1" in
        -y | --yes)
            [ -n "$2" ] && yes="$2" || yes=''
            shift
            ;;

        -n | --no)
            [ -n "$2" ] && no="$2" || no=''
            shift
            ;;

        -q | --query)
            [ -n "$2" ] && query="$2"
            shift
            ;;
    esac
    shift
done

chosen=$(printf '%s;%s\n' "$yes" "$no" |
    rofi -theme-str '@import "prompt.rasi"' \
        -hover-select \
        -me-select-entry "" \
        -me-accept-entry MousePrimary \
        -p "$query" \
        -dmenu \
        -sep ';' \
        -a 0 \
        -u 1 \
        -selected-row 1)

case "$chosen" in
    "$yes") return 0 ;;
    *) return 1 ;;
esac
