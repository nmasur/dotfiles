# Changelog

## 2026-08-29 (later)

- Added a diagnostic toolkit (`lag-triage` / `unlag` fish functions + `term-probe` binary, `presets/programs/lag-triage/`) for the still-recurring post-TUI typing lag in fish + Zellij + Ghostty, instead of another blind fix. Findings that motivated it:
  - All three prior fixes were either no-ops or insufficient: `fish_features = no-query-term` is a **no-op** because `query-term` already defaults to *off* in fish 4.8.1 (verified with `status features`); disabling Ghostty's fish integration inside Zellij and setting `support_kitty_keyboard_protocol = false` did not stop recurrence.
  - PTY captures of fish 4.8.1 (`TERM=xterm-256color`, with and without `$ZELLIJ`) show fish never writes Kitty keyboard sequences to the wire — it uses modifyOtherKeys (`\e[>4;1m`), application keypad (`\e=`), bracketed paste (`?2004`), and color-theme reporting (`?2031`), enabling them at every prompt and disabling them before every external command. Crucially, a fresh subshell's startup bytes are identical to the parent's post-command re-enable bytes, so "a subshell fixes the lag" cannot be explained by a simple terminal-state reset — leaving two competing hypotheses that only live capture can separate: (1) fish-internal reader state poisoned by stray/partial escape bytes (e.g. leaked from a closing floating pane), cleared only by a new fish process; (2) Zellij/Ghostty-level stuck state (Zellij 0.45's `StdinAnsiParser` is already a proven source of input delays — see the Alt-Shift-P fix below).
  - Also note: the floating-pane TUIs (jjui via Alt-Shift-J, yazi via Alt-Shift-Y, scrollback editor) run in their own panes and never pass through the shell's fish process at all, while `nvim` runs inside the shell pane — the triage log records which path preceded the lag.
  - **Next occurrence: run `lag-triage` in the lagging shell BEFORE starting a new shell.** It snapshots the environment, queries pane terminal state (kitty flags, modifyOtherKeys, DEC modes, DA1 round-trip latency), captures raw keystroke bytes+timing bypassing fish, then applies staged resets (kitty pop/clear, modifyOtherKeys off, keypad/cursor, mouse/focus/sync, altscreen, stty, DECSTR) — the stage that cures it names the stuck layer. Logs to `~/.local/state/lag-triage/` for an upstream issue. `unlag` is the one-shot convenience version (if `unlag` never helps but `exec fish` does, the bug is fish-internal).

## 2026-08-29

- Fixed 1.5-second latency when pressing `Alt-Shift-P` to trigger `zellij-session` in Zellij 0.45.0 + Ghostty:
  - **Root Cause**: Zellij 0.45.0 introduced `StdinAnsiParser` (`zellij-client/src/stdin_ansi_parser.rs`) using `termwiz::InputParser` to parse ANSI control strings (OSCs, CSIs, DCSs) arriving on stdin. When pressing `Alt-Shift-P` (Option-Shift-P) with `support_kitty_keyboard_protocol = false`, Ghostty sent `\x1bP` (`ESC` + uppercase `P`). In ECMA-48 / VT100 standards, `ESC P` is the 7-bit ASCII representation of `DCS` (Device Control String). `StdinAnsiParser` buffered `\x1bP` waiting for a DCS string payload and string terminator (`ST` / `\x1b\`), hitting a ~1.5-second escape timeout before flushing `\x1bP` as residue to the keyboard handler.
  - **Fix**: Added `alt+shift+p=text:\x1b[112;4u` and `super+shift+p=text:\x1b[112;4u` in `ghostty.nix` to send the explicit CSI-u sequence for `Alt+Shift+p` (`'p'` with modifier 4 = `ALT | SHIFT`). `StdinAnsiParser` immediately recognizes `\x1b[112;4u` as non-DCS input and passes it straight to the keyboard handler with 0ms latency.

## 2026-08-26

- Fixed macOS shortcuts (`Cmd+T`, `Ctrl+Tab`, `Cmd+Shift+]`, `Cmd+Shift+[`, `Cmd+K`, `Cmd+Shift+E`) in Zellij + Ghostty after disabling the Kitty keyboard protocol:
  - Mapped Ghostty keybindings (`super+t`, `super+shift+]`, `super+shift+[`, `ctrl+tab`, `ctrl+shift+tab`, `super+k`, `super+shift+e`) to send standard `Alt` (`ESC`-prefix) text sequences (`\x1bt`, `\x1b}`, `\x1b{`, `\x1bK`, `\x1bE`).
  - Added matching `Alt` keybindings (`Alt t`, `Alt ]`, `Alt }`, `Alt [`, `Alt {`, `Alt Shift k`, `Alt Shift e`) in `zellij.nix` for tab creation, tab navigation, scroll mode, and scrollback editing. Symbols like `]` and `}` are parsed by Zellij's termwiz input engine as distinct character codes (`'}'` vs `']'`), so binding both `Alt }` and `Alt Shift ]` ensures `\x1b}` triggers tab navigation correctly.
  - Keeps Kitty keyboard protocol disabled in Zellij (`support_kitty_keyboard_protocol = false`) so no CSI-u flags leak into Fish shell, guaranteeing zero post-TUI typing lag while restoring all shortcuts.

- Fixed persistent Fish typing lag after long TUI sessions (Neovim, jjui, Yazi) inside Zellij + Ghostty, which the `no-query-term` / Ghostty-integration fixes from 2026-08-25 did not resolve:
  - Verified on Fish 4.8.1 that the `query-term` feature already defaults to `off`, so exporting `fish_features = no-query-term` is a no-op on this Fish version — it isn't the cause of (or fix for) this class of lag.
  - Set `support_kitty_keyboard_protocol = false` in `zellij.nix`. Zellij and Ghostty have several open upstream bugs (zellij-org/zellij#3887, #3723, #4178) where the Kitty keyboard protocol's enhancement-flag stack is left in an elevated state after a full-screen TUI exits without properly popping it. Every subsequent keystroke then arrives as a CSI-u sequence that Fish must wait out an escape-disambiguation timeout to parse, which reads as typing lag that worsens the longer the TUI session ran, and persists until the pane's protocol state resets (e.g. a fresh shell/pane). Disabling the protocol support in Zellij avoids the whole bug class; trades off precise modifier reporting (e.g. distinguishing Ctrl+Shift+key) for TUIs running inside Zellij panes, which this setup doesn't otherwise depend on (Shift+Enter is handled via a literal Ghostty `text:` keybind, not the Kitty protocol).

## 2026-08-25

- Fixed Nix evaluation warnings for `stdenv` deprecation and `gemini-cli`:
  - Replaced deprecated `stdenv.isLinux` and `stdenv.isDarwin` checks across module presets and package definitions with `stdenv.hostPlatform.isLinux` and `stdenv.hostPlatform.isDarwin`.
  - Replaced deprecated `pkgs.gemini-cli` with `pkgs.antigravity-cli` (and updated binary invocation to `agy`) in `experimental.nix` profile and `daily-summary.nix` launchd service.

## 2026-08-25

- Fixed multi-second hang and permanent typing latency in Fish after exiting TUIs inside Zellij and Ghostty:
  - Exported `fish_features = "no-query-term"` in `home.sessionVariables` and added `set -gx fish_features no-query-term` to Fish's top-level `shellInit`. Previous attempt (`set -a fish_features no-query-term` in `interactiveShellInit`) set a local variable inside an anonymous initialization function block that went out of scope immediately after startup. Furthermore, Fish reads `fish_features` at binary launch before interactive init functions run. Without `no-query-term` exported prior to Fish startup, Fish attempted terminal feature queries (Primary Device Attributes `DA1` / `\e[?c` and termcap) whenever a TUI (e.g. Neovim, Lazygit, Yazi) exited and returned control to Fish. Zellij drops or delays DA1 response sequences, causing Fish to block on a multi-second stdin timeout, followed by severe input reader desynchronization and typing latency on every subsequent keystroke.
  - Disabled `programs.ghostty.enableFishIntegration` and conditionally sourced Ghostty's shell integration script in `shellInit` only when NOT running inside a multiplexer (`not set -q ZELLIJ` and `not set -q TMUX`). Sourcing Ghostty's shell integration inside Zellij sent duplicate and conflicting OSC 133 prompt markers and DECSCUSR cursor escape sequences to Zellij's PTY parser.

## 2026-08-16

- Fixed Zellij new tab directory tracking by adding `__fish_update_cwd_osc` override in `presets/programs/zellij.nix`. Fish's default OSC 7 sequence includes `$hostname`, which on macOS or dynamic network environments evaluates to `Noah-MacBook-Pro.local` or a domain suffix. Zellij compares the OSC 7 hostname against its system hostname (`Noah-MacBook-Pro`), finds a mismatch, and silently ignores the CWD update, leaving new tabs stuck in a previous directory or session default. Overriding `__fish_update_cwd_osc` to send `file://<PWD>` (empty hostname) ensures Zellij always updates its cached CWD on every `cd` and prompt render.
- Fixed Firefox "profile cannot be loaded" error on macOS by removing `home.file."Library/Application Support/Firefox/installs.ini"`. Hardcoding an installation hash in `installs.ini` broke whenever Firefox was updated or rebuilt in the Nix store because the nix store path changed, causing Firefox to compute a new installation hash, fail to match or write to the read-only `installs.ini` symlink, and error out. Firefox on macOS uses `profiles.ini` (managed by Home Manager) and `MOZ_LEGACY_PROFILES=1` (exported by nixpkgs' launcher wrapper).

## 2026-08-03

- Added `presets/security/corporate-ca.nix` (nix-darwin) and enabled it on the
  `lookingglass` host to trust a corporate TLS-intercepting proxy's root CA.
  Behind the corp network, Nix fetches failed with `SSL peer certificate ...
  self-signed certificate in certificate chain (19)` because Nix's stock Mozilla
  CA bundle doesn't contain the interception root. The module appends the cert
  to `security.pki.certificateFiles`, which rebuilds
  `/etc/ssl/certs/ca-certificates.crt` (read by both the Nix daemon and, via
  `NIX_SSL_CERT_FILE`, client-side flake fetches).

  The cert is kept **out of this public repo** and referenced by absolute path.
  It is passed as a string (not a Nix path literal) so pure flake evaluation
  doesn't read it at eval time, and it lives at a root-owned, world-readable
  path because the unprivileged `nixbld` build user cannot traverse `$HOME`
  (mode `0750`) to read it at build time.

  One-time setup on a machine behind the proxy:

  ```sh
  # 1. Extract the self-signed corporate root from any TLS connection it MITMs
  #    (the last cert in the chain, subject == issuer). Any HTTPS host works:
  echo | openssl s_client -connect example.com:443 -servername example.com \
    -showcerts 2>/dev/null \
    | awk '/BEGIN CERT/{c++} c==2' > /tmp/CorpCA.pem
  openssl x509 -in /tmp/CorpCA.pem -noout -subject -issuer   # sanity check

  # 2. Install to the root-owned path the config points at:
  sudo install -d -m 0755 -o root -g wheel /etc/ssl/corp-ca
  sudo install -m 0644 -o root -g wheel /tmp/CorpCA.pem \
    /etc/ssl/corp-ca/CorpCA.pem

  # 3. Bootstrap the first rebuild (which must fetch inputs over the proxy)
  #    with a combined bundle, then it's permanent:
  cat /etc/ssl/certs/ca-certificates.crt /etc/ssl/corp-ca/CorpCA.pem \
    > /tmp/combined-ca.crt
  NIX_SSL_CERT_FILE=/tmp/combined-ca.crt nh darwin switch . --configuration lookingglass
  ```

- Fixed the `zellij-session` fish function in `presets/programs/zellij.nix`
  truncating the session name (derived from the target directory basename)
  to 20 characters. Zellij names each session's Unix-domain IPC socket
  `$TMPDIR/zellij-<uid>/<version>/<name>`, and on macOS the socket path is
  capped at 103 bytes. The `/var/folders/...` `$TMPDIR` prefix consumes ~79
  of those, leaving only ~24 chars for the name, so switching into directories
  with long basenames overflowed the socket path. Because `switch-session`
  had already detached from the current session by the time the new one failed
  to bind, the failure took down the entire terminal instead of erroring
  gracefully.

## 2026-07-25

- Added jjui config generation to `jujutsu.nix` in Home Manager to include custom GitHub ruleset bypass commands (`ctrl+b` and `ctrl+shift+b`).
- Added `overlays/cheetah3.nix` to disable `pythonMetadataCheckPhase` for `cheetah3`.
  This fixes an issue where the NixOS rebuild fails for `sabnzbd` due to `importlib.metadata.PackageNotFoundError: No package metadata was found for cheetah3` during the Python package evaluation in `nixos-unstable`.

## 2026-07-20

- Added `overlays/paho-mqtt.nix` to disable paho-mqtt's flaky, socket-based
  test suite. Its `checkPhase` hangs in the Nix sandbox and times out with a
  `KeyboardInterrupt` after ~150s, which was breaking the `flame` rebuild
  (paho-mqtt is pulled in transitively, e.g. via mealie). The override is
  applied through `pythonPackagesExtensions` so it covers every Python
  package set.
