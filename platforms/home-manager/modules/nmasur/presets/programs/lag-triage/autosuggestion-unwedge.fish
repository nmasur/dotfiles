# Self-heal for the post-TUI typing lag (fish 4.8.1, see docs/CHANGELOG.md
# 2026-08-29..31): exiting a TUI can wedge fish's autosuggestion pipeline,
# after which every keystroke at the commandline lags until the process is
# replaced. Empirically validated cure: turn autosuggestions off and back on
# in the affected shell. This hook applies that reset after every command —
# i.e. at the exact moment a TUI has just exited — using only builtins, so it
# is effectively free and invisible.
#
# Caveats, recorded for honesty: the manual cure had keystrokes between the
# off and the on; whether an immediate off/on inside an event handler resets
# the same reader state is unproven (the flight recorder stays armed to catch
# any recurrence). If lag ever appears despite this hook, cure manually with
#   set -g fish_autosuggestion_enabled 0   (type a few chars)
#   set -g fish_autosuggestion_enabled 1
# and save ~/.local/state/lag-triage/flight/ logs for that shell's pid.

# Respect a deliberate user choice to keep autosuggestions off.
if test "$fish_autosuggestion_enabled" != 0
    set -g fish_autosuggestion_enabled 0
    set -g fish_autosuggestion_enabled 1
end
