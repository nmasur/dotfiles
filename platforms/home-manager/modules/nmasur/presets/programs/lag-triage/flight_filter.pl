# Flight-recorder filter for fish's FISH_DEBUG stream (see fish-no-query-term
# in zellij.nix). Reads the FIFO fish writes its debug log to, prefixes every
# line with a millisecond wall-clock timestamp, and redacts anything typed or
# pasted so the always-on log never holds secrets.
#
# Timing is the whole point: the gap between "Read byte" and the following
# "Writing terminal command" is how long fish itself took to handle a key. If
# that gap stays small while the pane feels laggy, the delay is downstream of
# fish (zellij/ghostty), not in fish.
#
# Usage: perl flight_filter.pl <fifo> <logfile>
use strict;
use warnings;
use Time::HiRes qw(time);
use POSIX qw(strftime);

my ($fifo, $logfile) = @ARGV;
open(my $in, '<', $fifo) or exit 1;
# fish has the FIFO open now; nothing else needs the path.
unlink $fifo;
open(my $out, '>>', $logfile) or exit 1;
$out->autoflush(1);

# Commands worth naming in the log; everything else is redacted.
my $keep_cmd = qr/^(heal-autosuggest|set -g fish_autosuggestion_enabled|exec fish|lag-)/;

while (my $line = <$in>) {
    $line =~ s/\0//g;
    # Keystrokes: keep control/escape identities, drop printable content.
    if ($line =~ /^(reader: Read byte) (.*)$/) {
        my ($prefix, $b) = ($1, $2);
        $b = '<printable>' unless $b =~ /^\\(e|r|t|n|x[0-9a-fA-F]+)$/;
        $line = "$prefix $b\n";
    }
    elsif ($line =~ /^(reader: Read char) (\S+)/) {
        my ($prefix, $k) = ($1, $2);
        $k = '<printable>'
          unless $k =~ /^(enter|tab|escape|backspace|delete|space|up|down|left|right|home|end)$|^(ctrl|alt|shift|super)-/;
        $line = "$prefix $k\n";
    }
    elsif ($line =~ /^reader: adding peeked /) {
        $line = "reader: adding peeked <redacted>\n";
    }
    elsif ($line =~ /^reader: Found binding .*?commands: (\[[^\]]*\])/) {
        $line = "reader: Found binding $1\n";
    }
    $line =~ s/(Error while expanding string ).*/$1<redacted>/;
    $line =~ s/(CommandStart\(")(.*)("\))/$1 . ($2 =~ $keep_cmd ? $2 : '<cmd>') . $3/e;
    $line =~ s/(WindowTitle\().*(\))/$1<title>$2/;
    my $t = time;
    printf $out "%s.%03d %s", strftime('%H:%M:%S', localtime $t), ($t - int $t) * 1000, $line;
}
