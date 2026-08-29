"""Probe the terminal state of the current pane, below the shell.

Modes:
  report  - query kitty-keyboard flags, modifyOtherKeys, and DEC private
            modes directly on /dev/tty, reporting each reply (or lack of
            one) and its round-trip latency. Answers may come from Zellij
            (pane state) or be relayed from Ghostty (window state).
  keylog  - raw-mode keystroke capture: prints the exact bytes and
            inter-key latency for every keypress, bypassing the shell's
            input machinery entirely. Press q to finish.

Used by the `lag-triage` fish function to pin down which layer
(fish / zellij / ghostty) is holding stuck state when typing lags
after a TUI exits.
"""

import os
import re
import select
import sys
import termios
import time
import tty

# DECRQM reply values
DECRQM_VALUES = {
    "0": "not recognized",
    "1": "SET",
    "2": "reset",
    "3": "permanently set",
    "4": "permanently reset",
}

DEC_MODES = [
    (1, "application cursor keys (DECCKM)"),
    (25, "cursor visible"),
    (1000, "mouse click reporting"),
    (1002, "mouse drag reporting"),
    (1003, "mouse all-motion reporting"),
    (1004, "focus reporting"),
    (1006, "SGR mouse encoding"),
    (1049, "alternate screen"),
    (2004, "bracketed paste"),
    (2026, "synchronized output"),
    (2031, "color theme reporting"),
]

QUERIES = [
    ("kitty keyboard flags (\\e[?u)", b"\x1b[?u", rb"\x1b\[\?(\d+)u", None),
    ("modifyOtherKeys (XTQMODKEYS)", b"\x1b[?4m", rb"\x1b\[>4;(\d+)m", None),
    ("background color (OSC 11)", b"\x1b]11;?\x1b\\", rb"\x1b\]11;([^\x07\x1b]+)", None),
] + [
    (
        f"DEC mode {num} — {desc}",
        b"\x1b[?%d$p" % num,
        rb"\x1b\[\?%d;(\d+)\$y" % num,
        DECRQM_VALUES,
    )
    for num, desc in DEC_MODES
]


def read_for(fd, seconds):
    buf = b""
    end = time.monotonic() + seconds
    while True:
        remaining = end - time.monotonic()
        if remaining <= 0:
            break
        r, _, _ = select.select([fd], [], [], remaining)
        if not r:
            break
        buf += os.read(fd, 4096)
    return buf


def report(fd):
    lines = []
    raw_dump = b""
    for label, query, pattern, value_names in QUERIES:
        raw_dump += read_for(fd, 0.02)  # drain stragglers
        start = time.monotonic()
        os.write(fd, query)
        buf = b""
        match = None
        deadline = time.monotonic() + 0.35
        while time.monotonic() < deadline:
            buf += read_for(fd, 0.05)
            match = re.search(pattern, buf)
            if match:
                break
        raw_dump += buf
        if match:
            latency = (time.monotonic() - start) * 1000
            value = match.group(1).decode("ascii", "replace")
            if value_names:
                value = f"{value} ({value_names.get(value, '?')})"
            lines.append(f"  {label:45s} = {value:24s} [{latency:6.1f} ms]")
        else:
            lines.append(f"  {label:45s} = (no reply)")

    # DA1 as a fence: every terminal answers it, so its round-trip time
    # measures the whole input path (ghostty -> zellij -> pane -> here).
    start = time.monotonic()
    os.write(fd, b"\x1b[c")
    buf = b""
    match = None
    deadline = time.monotonic() + 2.0
    while time.monotonic() < deadline:
        buf += read_for(fd, 0.05)
        match = re.search(rb"\x1b\[\?([0-9;]*)c", buf)
        if match:
            break
    raw_dump += buf
    if match:
        latency = (time.monotonic() - start) * 1000
        lines.append(
            f"  {'device attributes (DA1) round-trip':45s} = "
            f"{match.group(1).decode():24s} [{latency:6.1f} ms]"
        )
    else:
        lines.append(f"  {'device attributes (DA1) round-trip':45s} = (NO REPLY in 2s!)")
    lines.append(f"  raw bytes received: {raw_dump!r}")
    return lines


def keylog(fd):
    sys.stdout.write("keylog: capturing raw bytes from the tty. Press q to finish.\r\n")
    sys.stdout.flush()
    last = time.monotonic()
    while True:
        select.select([fd], [], [], None)
        data = os.read(fd, 4096)
        now = time.monotonic()
        delta_ms = (now - last) * 1000
        last = now
        sys.stdout.write(f"  +{delta_ms:8.1f} ms  {data!r}  hex={data.hex(' ')}\r\n")
        sys.stdout.flush()
        if data in (b"q", b"\x03", b"\x04"):
            break


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "report"
    fd = os.open("/dev/tty", os.O_RDWR)
    old = termios.tcgetattr(fd)
    lines = None
    try:
        tty.setraw(fd)
        if mode == "report":
            lines = report(fd)
        elif mode == "keylog":
            keylog(fd)
        else:
            raise SystemExit(f"unknown mode: {mode}")
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old)
        os.close(fd)
    if lines:
        print("terminal state as seen from this pane:")
        print("\n".join(lines))


if __name__ == "__main__":
    main()
