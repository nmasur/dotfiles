# Guided diagnosis for the post-TUI typing-lag problem (Ghostty + Zellij + fish).
# Run this IN THE LAGGING SHELL the moment you notice the lag, BEFORE starting
# a new shell. It captures evidence, then applies targeted resets one at a time
# so the stage that cures the lag identifies the layer holding stuck state.
# Everything is logged for filing an upstream issue.

set -l logdir ~/.local/state/lag-triage
mkdir -p $logdir
set -l logfile $logdir/(date +%Y%m%d-%H%M%S).log

function _lt --inherit-variable logfile
    echo $argv | tee -a $logfile
end

function _lt_ask --inherit-variable logfile
    # usage: _lt_ask VARNAME prompt... -> sets global $VARNAME (default: skip)
    set -l __name $argv[1]
    read -g -P "$argv[2..] " $__name
    or set -g $__name skip
    test -z "$$__name"; and set -g $__name skip
    echo "ANSWER $__name: $$__name" >>$logfile
end

_lt "== lag-triage "(date)" =="
_lt "Log: $logfile"
_lt "Answer y / n, or press Enter to skip a question."
_lt ""

# ---- 1. Context -------------------------------------------------------------
_lt_ask ans_tui "Which TUI did you just exit (nvim/jjui/yazi/other)?"
_lt_ask ans_launch "Launched via (f)loating-pane keybind or (c)ommand typed in this shell?"

# ---- 2. Snapshot ------------------------------------------------------------
begin
    echo "-- snapshot --"
    fish --version
    echo "fish pid: $fish_pid, started: "(ps -o lstart= -p $fish_pid 2>/dev/null)
    zellij --version 2>/dev/null
    echo "escape delay: '$fish_escape_delay_ms' sequence delay: '$fish_sequence_key_delay_ms'"
    env | grep -iE '^(TERM|ZELLIJ|GHOSTTY|COLORTERM)' | sort
    echo "-- status features --"
    status features
    echo "-- stty -a --"
    stty -a
end >>$logfile 2>&1
_lt "Captured shell + environment snapshot."

# Proven root cause of the 2026-08 lag (see docs/CHANGELOG.md 2026-08-29):
# fish latches feature flags from its startup env before config.fish runs, so
# a shell with query-term ON sends terminal queries after every command; one
# reply zellij fails to relay permanently degrades this process's reader.
if status features | string match -qr '^query-term\s+on'
    _lt ""
    _lt "!! query-term is ON in this shell: fish did NOT get fish_features="
    _lt "!! no-query-term in its STARTUP environment (config.fish is too late)."
    _lt "!! This is the proven root cause of the post-TUI lag — a query reply"
    _lt "!! lost by zellij permanently degrades this fish process's reader."
    _lt "!! Fix: spawn fish with the variable exported (zellij default_shell"
    _lt "!! wrapper fish-no-query-term). Subshells are immune because they"
    _lt "!! inherit the exported variable — that's why a new shell 'fixes' it."
else
    _lt "query-term is off in this shell (good — the known root cause is ruled out)."
end

# ---- 3. Terminal state below the shell --------------------------------------
_lt ""
_lt "Querying terminal state (takes a few seconds)..."
term-probe report 2>&1 | tee -a $logfile
_lt ""
_lt "  ^ Things to look for: kitty flags with a reply > 0, modifyOtherKeys > 1,"
_lt "    any mouse/alternate-screen mode SET while at a shell prompt, or a slow"
_lt "    DA1 round-trip (> 100 ms means the input path itself is delayed)."

# ---- 4. Raw keystroke capture (bypasses fish entirely) ----------------------
_lt ""
_lt "Raw input capture: type ~10 characters at a steady pace, including one"
_lt "ESC press and one arrow key. This shows the exact bytes this pane delivers"
_lt "and their timing, with fish's input handling out of the picture."
term-probe keylog 2>&1 | tee -a $logfile
_lt_ask ans_keylog_instant "Did each keypress appear INSTANTLY in the capture? (y/n)"
_lt_ask ans_keylog_plain "Were plain letters single plain bytes like b'a' (not escape sequences)? (y/n)"

# ---- 5. Scope ---------------------------------------------------------------
_lt ""
_lt_ask ans_scope_pane "Optional: open a NEW zellij pane/tab and type — laggy there too? (y/n)"
_lt_ask ans_scope_window "Optional: type in a separate Ghostty window (outside this zellij session) — laggy? (y/n)"

# ---- 6. Staged resets -------------------------------------------------------
# Each stage resets one category of state a TUI could have left behind.
# The first stage that cures the lag names the culprit.
set -l fixed none

_lt ""
_lt "Now applying resets one at a time. After each, type into the test prompt"
_lt "to judge whether the lag is gone."
_lt "CAVEAT: fish's read prompt may NOT exhibit lag even when the main"
_lt "commandline does. If typing at these test prompts never feels laggy at"
_lt "all, answer 'u' (unsure) instead of 'y' — a 'y' here is only meaningful"
_lt "if you could feel the lag at the test prompts before the reset."

if test $fixed = none
    _lt ""
    _lt "Stage A - kitty keyboard protocol: pop stack + clear all flags"
    printf '\e[<9u\e[=0;1u'
    _lt_ask ans_stage_a "  Test typing here, then Enter — lag gone? (y/n)"
    test "$ans_stage_a" = y; and set fixed "A (kitty keyboard state)"
end

if test $fixed = none
    _lt "Stage B - modifyOtherKeys off"
    printf '\e[>4;0m'
    _lt_ask ans_stage_b "  Test typing here, then Enter — lag gone? (y/n)"
    test "$ans_stage_b" = y; and set fixed "B (modifyOtherKeys)"
end

if test $fixed = none
    _lt "Stage C - normal keypad + normal cursor keys"
    printf '\e>\e[?1l'
    _lt_ask ans_stage_c "  Test typing here, then Enter — lag gone? (y/n)"
    test "$ans_stage_c" = y; and set fixed "C (application keypad/cursor mode)"
end

if test $fixed = none
    _lt "Stage D - disable mouse, focus reporting, synchronized output"
    printf '\e[?1000l\e[?1001l\e[?1002l\e[?1003l\e[?1005l\e[?1006l\e[?1015l\e[?1016l\e[?1004l\e[?2026l'
    _lt_ask ans_stage_d "  Test typing here, then Enter — lag gone? (y/n)"
    test "$ans_stage_d" = y; and set fixed "D (mouse/focus/sync modes)"
end

if test $fixed = none
    _lt "Stage E - leave alternate screen"
    printf '\e[?1049l'
    _lt_ask ans_stage_e "  Test typing here, then Enter — lag gone? (y/n)"
    test "$ans_stage_e" = y; and set fixed "E (alternate screen)"
end

if test $fixed = none
    _lt "Stage F - stty sane (line-discipline reset)"
    stty sane
    _lt_ask ans_stage_f "  Test typing here, then Enter — lag gone? (y/n)"
    test "$ans_stage_f" = y; and set fixed "F (termios/line discipline)"
end

if test $fixed = none
    _lt "Stage G - DECSTR soft terminal reset"
    printf '\e[!p'
    _lt_ask ans_stage_g "  Test typing here, then Enter — lag gone? (y/n)"
    test "$ans_stage_g" = y; and set fixed "G (DECSTR-resettable mode)"
end

# ---- 7. Verdict --------------------------------------------------------------
_lt ""
_lt "== Verdict =="
if test $fixed != none
    _lt "Lag cleared by stage $fixed."
    _lt "That state was stuck BELOW fish — in the Zellij pane or relayed to"
    _lt "Ghostty — and the TUI you exited ($ans_tui) failed to restore it, or"
    _lt "Zellij failed to restore it when the pane closed."
    _lt "Re-probing terminal state after the fix for comparison:"
    term-probe report 2>&1 | tee -a $logfile
    _lt ""
    _lt "-> File this log against zellij (or ghostty, if a separate window also"
    _lt "   lagged). The before/after probe diff pinpoints the exact stuck mode."
else if test "$ans_keylog_instant" = y; and test "$ans_keylog_plain" = y
    _lt "Raw input reaches this pane instantly as plain bytes, and no terminal"
    _lt "state reset helps: the lag lives INSIDE this fish process (reader state)."
    _lt "Confirm now: run 'exec fish' — if that cures it, it is fish-internal."
    _lt ""
    _lt "-> To catch it in the act, run your next long-lived shell as:"
    _lt "   FISH_DEBUG='reader,term-support' FISH_DEBUG_OUTPUT=$logdir/fish-debug.log fish"
    _lt "   then re-run lag-triage when it recurs and file both logs to fish-shell."
else
    _lt "Keystrokes were delayed or arrived as escape sequences BEFORE fish saw"
    _lt "them: the problem is in Zellij (client stdin parser / server) or Ghostty."
    _lt "  new pane also laggy:        $ans_scope_pane  (y -> session-wide, not this pane)"
    _lt "  separate window laggy:      $ans_scope_window  (y -> Ghostty itself)"
    _lt "-> File this log against zellij; include the keylog byte capture."
end
_lt ""
_lt "Full log: $logfile"

functions -e _lt _lt_ask
