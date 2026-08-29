#!/usr/bin/env python3
"""Deterministic repro of permanent fish reader degradation (fish 4.8.1).

This is evidence for an upstream fish-shell report, and the proof behind the
fish-no-query-term wrapper in presets/programs/zellij.nix. Not installed by
the nix module; run directly: python3 upstream_repro.py [queryterm|noqueryterm]

Finding: with the query-term feature enabled (latched from the startup env,
which is fish's default), fish sends OSC 11 + CPR (\e[6n) + DA1 (\e[0c)
after every external command and waits for the replies. If the terminal
fails to reply during ONE such cycle -- even though it answered every query
before and answers every query after -- that fish process's interactive
reader is PERMANENTLY degraded: keystrokes are no longer echoed (>3s each,
never recovers). In production this happens when zellij drops/mis-relays a
reply during TUI teardown or heavy output (cf. zellij-org/zellij#5158), and
it presents as permanent typing lag cured only by replacing the process.
With fish_features=no-query-term in the startup environment, the same
sequence has zero effect (~35ms echo throughout).

Phases:
  A. terminal answers all queries        -> echo ~35ms (both variants)
  B. replies dropped for one command     -> queryterm: echo dead, permanently
  C. replies restored, another command   -> queryterm: still dead
"""
import os, pty, re, select, subprocess, sys, time, fcntl, termios

VARIANT = sys.argv[1] if len(sys.argv) > 1 else "queryterm"

env = dict(os.environ)
env["TERM"] = "xterm-ghostty"
env["ZELLIJ"] = "0"
env["ZELLIJ_SESSION_NAME"] = "repro"
env["FISH_DEBUG"] = "term-support"
env["FISH_DEBUG_OUTPUT"] = f"/tmp/fish-lagrepro-{VARIANT}.log"
env.pop("fish_features", None)
if VARIANT == "noqueryterm":
    env["fish_features"] = "no-query-term"

master, slave = pty.openpty()
# give it a size
fcntl.ioctl(master, termios.TIOCSWINSZ, b"\x00\x28\x00\x78\x00\x00\x00\x00")
proc = subprocess.Popen(
    ["fish", "-i", "--no-config"],
    stdin=slave, stdout=slave, stderr=slave, env=env,
    preexec_fn=lambda: (os.setsid(), fcntl.ioctl(0, termios.TIOCSCTTY, 0)),
    close_fds=True,
)
os.close(slave)

RESPOND = True
transcript = []

def respond(data):
    """Answer terminal queries the way a well-behaved terminal would."""
    out = b""
    for m in re.finditer(rb"\x1b\[6n", data):
        out += b"\x1b[40;1R"                       # CPR
    for m in re.finditer(rb"\x1b\[0?c", data):
        out += b"\x1b[?62;22c"                     # DA1
    for m in re.finditer(rb"\x1b\[\?u", data):
        out += b"\x1b[?0u"                         # kitty flags
    for m in re.finditer(rb"\x1b\]11;\?", data):
        out += b"\x1b]11;rgb:2828/2828/2828\x1b\\" # OSC 11
    for m in re.finditer(rb"\x1b\[>0?q", data):
        out += b"\x1bP>|ghostty 1.3.1\x1b\\"       # XTVERSION
    for m in re.finditer(rb"\x1bP\+q[0-9a-fA-F;]+\x1b\\", data):
        out += b"\x1bP0+r\x1b\\"                   # XTGETTCAP: not found
    for m in re.finditer(rb"\x1b\[\?(\d+)\$p", data):
        out += b"\x1b[?%s;2$y" % m.group(1)        # DECRQM: reset
    return out

def pump(timeout):
    """Read fish output for `timeout` seconds, answering queries if RESPOND."""
    buf = b""
    end = time.monotonic() + timeout
    while time.monotonic() < end:
        r, _, _ = select.select([master], [], [], 0.03)
        if r:
            try:
                data = os.read(master, 65536)
            except OSError:
                return buf
            buf += data
            transcript.append(data)
            if RESPOND:
                reply = respond(data)
                if reply:
                    os.write(master, reply)
    return buf

def send(s):
    os.write(master, s if isinstance(s, bytes) else s.encode())

def measure_echo(chars, settle=0.1):
    """Send chars one at a time; measure time until each is echoed."""
    results = []
    for ch in chars:
        pump(settle)
        t0 = time.monotonic()
        send(ch)
        deadline = time.monotonic() + 3.0
        latency = None
        buf = b""
        while time.monotonic() < deadline:
            buf += pump(0.02)
            if ch.encode() in buf:
                latency = (time.monotonic() - t0) * 1000
                break
        results.append((ch, latency))
    return results

print(f"=== variant: {VARIANT} ===")
pump(1.2)  # startup, queries answered

send("echo warmup\r")
pump(0.8)

print("phase A: terminal responsive, echo latency per key:")
for ch, ms in measure_echo("abcde"):
    print(f"  {ch}: {ms:.0f} ms" if ms else f"  {ch}: NO ECHO in 3s")
send("\x15")  # ctrl-u clear line
pump(0.3)

# Run external command, then STOP answering queries (simulate lost relay)
send("sh -c true\r")
time.sleep(0.05)
RESPOND = False
pump(1.0)

print("phase B: after external command with query replies DROPPED:")
for ch, ms in measure_echo("fghij"):
    print(f"  {ch}: {ms:.0f} ms" if ms else f"  {ch}: NO ECHO in 3s")
send("\x15")
pump(0.3)

# Does it persist across further commands, with responses restored?
RESPOND = True
send("sh -c true\r")
pump(1.0)
print("phase C: responses restored, after another external command:")
for ch, ms in measure_echo("klmno"):
    print(f"  {ch}: {ms:.0f} ms" if ms else f"  {ch}: NO ECHO in 3s")

send("\x15")
pump(0.2)
send("exit\r")
pump(0.5)
try:
    proc.wait(timeout=3)
except subprocess.TimeoutExpired:
    proc.kill()
