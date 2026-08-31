# Capture stack samples of this fish process, the zellij server, and the
# zellij client WHILE the typing lag is happening. This names the guilty
# component directly: if fish's main thread is busy/blocked per keystroke the
# stacks show exactly where; if fish is idle while typing feels laggy, the
# delay is in zellij's render path instead.
#
# CAUTION (learned 2026-08-30): attaching the sampler to a lagging fish CURES
# the lag (thread suspend/resume unwedges it), so run this from a DIFFERENT
# pane with the lagging shell's pid: `lag-sample <pid>` (get it in the lagging
# shell with the builtin-only `echo $fish_pid`). Have someone type in the
# lagging pane while sampling runs — the first samples may catch the wedge.
# With no argument it samples the current shell.

set -l target $fish_pid
if test (count $argv) -ge 1; and test -n "$argv[1]"
    set target $argv[1]
end

set -l outdir ~/.local/state/lag-triage
mkdir -p $outdir
set -l ts (date +%Y%m%d-%H%M%S)
set -l dur 8

set -l fishfile $outdir/sample-$ts-fish-$target.txt
/usr/bin/sample $target $dur 1 -file $fishfile &>/dev/null &
disown

# this session's zellij server (socket path ends in the session name)
set -l serverpid (pgrep -f "zellij --server.*/$ZELLIJ_SESSION_NAME\$")
test -z "$serverpid"; and set serverpid (pgrep -f "zellij --server" | head -3)
for pid in $serverpid
    /usr/bin/sample $pid $dur 1 -file $outdir/sample-$ts-zellij-server-$pid.txt &>/dev/null &
    disown
end

# zellij clients (attached to ghostty): named zellij but without --server args
set -l allserver (pgrep -f "zellij --server")
set -l clientpid
for pid in (pgrep -x zellij)
    contains $pid $allserver; or set -a clientpid $pid
end
for pid in $clientpid[1..3]
    /usr/bin/sample $pid $dur 1 -file $outdir/sample-$ts-zellij-client-$pid.txt &>/dev/null &
    disown
end

# notify when done, without occupying the commandline
fish -c "sleep (math $dur + 2); echo; echo '== lag-sample done: '$outdir'/sample-$ts-*.txt =='" &
disown

echo "Sampling fish (pid $target), zellij server(s) [$serverpid], client(s) [$clientpid] for $dur s."
echo ">>> TYPE CONTINUOUSLY IN THE LAGGING PANE NOW (junk text is fine) <<<"
echo "Files: $outdir/sample-$ts-*.txt"
