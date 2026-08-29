# One-shot reset of terminal state a TUI may have left behind (kitty keyboard
# flags, modifyOtherKeys, application keypad/cursor, mouse/focus reporting,
# alternate screen, termios). fish re-enables the modes it wants at the next
# prompt, so this is safe to run any time.
#
# Diagnostic value: if this cures the lag, the stuck state was below fish
# (run lag-triage next time to find which mode). If only `exec fish` cures
# it, the lag is inside the fish process itself.
printf '\e[<9u\e[=0;1u'
printf '\e[>4;0m'
printf '\e>\e[?1l'
printf '\e[?1000l\e[?1001l\e[?1002l\e[?1003l\e[?1005l\e[?1006l\e[?1015l\e[?1016l\e[?1004l\e[?2026l'
printf '\e[?1049l'
stty sane
echo "terminal state reset — if typing still lags, run lag-triage (before exec fish!)"
