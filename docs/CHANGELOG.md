# Changelog

## 2026-09-06

- **Configured OpenID Connect (OIDC) authentication for Immich**:
  - Configured `services.immich.settings.oauth` with OIDC settings pointing to Pocket ID (`auth.masu.rs`), using client ID `1f4e0f8d-6cee-4d67-8d53-74bf6c18ae09`.
  - Added secret management for `immich-oidc-secret.age` via `secrets.immich-oidc-secret` with owner `immich` and group `shared` (0440).
  - Wired client secret substitution using NixOS's native `clientSecret._secret = config.secrets.immich-oidc-secret.dest`, leveraging `utils.genJqSecretsReplacement` with systemd `LoadCredential`.
  - Configured `systemd.services.immich-server` to order after `immich-oidc-secret-secret.service`.
  - Updated `docs/oidc-services.md` with the verified configuration and redirect URIs.

- **Fixed OpenSSH authorized principals certificate authentication for Cloudflare Tunnel**:
  - Replaced manual `environment.etc."ssh/authorized_principals/${username}"` symlink and `Match User` config with NixOS native `users.users.<name>.openssh.authorizedPrincipals`.
  - Root cause: `environment.etc` without an explicit `mode` creates symlinks pointing into `/nix/store`, which has group-writable mode `0775` (`nixbld` group). Under `StrictModes yes`, sshd refused authentication with `bad ownership or modes for directory /nix/store`, causing certificate principal matching to fail with `Certificate does not contain an authorized principal`.
  - Setting `users.users.<name>.openssh.authorizedPrincipals` causes NixOS to generate `/etc/ssh/authorized_principals.d/<name>` with `mode = "0444"`, copying the file instead of symlinking into the store, and automatically configuring `services.openssh.settings.AuthorizedPrincipalsFile = "/etc/ssh/authorized_principals.d/%u"`.
  - Also added `mode = "0444"` to `/etc/ssh/ca.pub` and moved `TrustedUserCAKeys` into `services.openssh.settings`.

- **Configured OpenID Connect (OIDC) authentication for Mealie**:
  - Configured `services.mealie.settings` with OIDC settings pointing to Pocket ID (`auth.masu.rs`), using client ID `040925ed-b39e-4442-b8e8-369c948c0cd2`.
  - Added secret management for `mealie-oidc-secret.age` via `secrets.mealie-oidc-secret`, using `prefix = "OIDC_CLIENT_SECRET="` to generate an environment file.
  - Configured `services.mealie.credentialsFile` to load the client secret via systemd's `EnvironmentFile` without exposing it in the world-readable Nix store or systemd unit file.
  - Configured `systemd.services.mealie` to order after `mealie-oidc-secret-secret.service`.
  - Updated `docs/oidc-services.md` with the verified configuration and callback URI (`https://cooking.masu.rs/login`).

- **Configured OpenID Connect (OIDC) authentication for Actual Budget**:
  - Configured `services.actual.settings` with `loginMethod = "openid"` and `openId` settings pointing to Pocket ID (`auth.masu.rs`), using client ID `92afe9f8-7ef6-42ab-8a06-701df3c7179d`.
  - Added secret management for `actualbudget-oidc-secret.age` via `secrets.actualbudget-oidc-secret`, set with owner `actualbudget` and group `shared` (0440).
  - Configured `systemd.services.actual` to order after the decrypted secret service and granted the dynamic unit access via `SupplementaryGroups = [ "shared" ]` and `PrivateUsers = false`.
  - Updated `docs/oidc-services.md` with the verified callback URI (`https://money.masu.rs/openid/callback`) and NixOS configuration snippet.

## 2026-08-31 (later): automatic self-heal hook

- Confirmed by A/B in the live shell: after curing the lag with `set -g fish_autosuggestion_enabled 0`, re-enabling with `1` does **not** bring the lag back — the toggle resets the wedged autosuggestion state rather than merely masking it.
- Added `__autosuggestion_unwedge` (lag-triage module): a `fish_postexec` event handler that toggles `fish_autosuggestion_enabled` off/on after every command — i.e. at the exact moment a TUI has just exited, when the wedge forms. Builtins only, no visible output (verified in an interactive PTY test), and it skips the reset when the user has deliberately disabled autosuggestions.
- Honest caveat: the manual cure had keystrokes between the off and the on; whether the instant off/on inside an event handler resets the same reader-internal state is unproven. The flight recorder therefore STAYS ARMED (`~/.local/state/lag-triage/RECORD`) until the hook has survived normal use for a while. If lag recurs despite the hook: cure manually (`set … 0`, type a few chars, `set … 1`), and keep the flight log for that pid — then the hook needs the stronger form (disable at postexec, re-enable one prompt-cycle later, scoped to TUI commands).
- Limitations by design: the hook fires only in shells that run commands, so a wedge formed without any command executing in that shell (if that is possible — e.g. floating-pane TUIs never touch the pane shell) would not be healed until the next command runs there.

## 2026-08-31: culprit confirmed — fish's autosuggestion pipeline

- A/B test in a live lagging shell (pid 56089): `set -g fish_autosuggestion_enabled 0` (builtin only, nothing else) **instantly cured the lag**. The post-TUI typing lag is in fish 4.8.1's autosuggestion pipeline.
- Sampling that shell afterwards showed it had **only one thread** (the main thread): the poisoned state is main-thread-side bookkeeping, not a hung worker still sitting in the process. Source review (`src/threads/threads.rs`, `src/threads/debounce.rs`): `ThreadPool::perform` silently queues work with no spawn and no wake when it believes `total_threads == max_threads` — a leaked `total_threads` count (workers that died without decrementing, e.g. across a TUI's lifetime) would strand all future autosuggestion work forever; the Debounce then abandons its token every 500ms and re-enqueues per keystroke. The exact step that delays keystroke *echo* is still unproven — the flight recorder (armed via `~/.local/state/lag-triage/RECORD`) logs the reader's per-keystroke behavior and will capture it on the next occurrence in a recorded shell.
- Precedent: fish had a closely-related bug class before (#11841 — unread terminal query responses "causing noticeable lags"). No fish release newer than 4.8.1 exists, so no upstream fix to adopt; an upstream report with the flight-recorder capture is the path to a real fix.
- Practical interim cure (harmless, instant, in the lagging shell): `set -g fish_autosuggestion_enabled 0`, and re-enable with `1` — whether lag returns on re-enable is the next discriminating datum.

## 2026-08-30 (later): sampler attach CURES the lag — wedged-thread evidence + flight recorder

- Major new datum: in a lagging shell, running `mkdir` + `/usr/bin/sample $fish_pid … &` + `disown` **cured the lag instantly**, before any planned reset/toggle test could run. Plain external commands do NOT cure it (the 2026-08-29 triage ran many and the lag survived), so the distinguishing action is the sampler **attaching and suspending/resuming fish's threads**. Conclusion: a fish-internal thread/wait is wedged (missed wakeup or stuck blocking wait), and per-keystroke work at the main commandline stalls against it; suspension/resume kicks it loose. Consistent with: `read` prompts unaffected (no autosuggestion/highlight pipeline), subshells immune (fresh threads), raw input clean. The captured sample (`~/.local/state/lag-triage/fish-sample.txt`) shows only the post-cure state — sampling is a cure, not a capture.
- Therefore the observer must be running BEFORE the lag starts: the `fish-no-query-term` wrapper is now a **flight recorder** — `touch ~/.local/state/lag-triage/RECORD`, then every newly spawned pane shell logs `FISH_DEBUG=reader,term-support,proc-termowner,iothread,fd-monitor,topic-monitor` to `~/.local/state/lag-triage/flight/fish-<ts>-<pid>.log` (3-day auto-cleanup; remove RECORD to disable, zero overhead when off). When lag next occurs, the log already contains what each keystroke did during the lag.
- `lag-sample` now takes a PID and should be run from a DIFFERENT pane (`echo $fish_pid` — a builtin — in the lagging shell to get it), since attaching from inside cures the lag.
- **Next-occurrence checklist (in order, least perturbing first):** (1) in the lagging shell, builtins only: `set -g fish_autosuggestion_enabled 0` → type at the real commandline; if cured, the autosuggestion/debounce path is implicated (a worker thread was seen in `HistorySearch::go_to_next_match`); (2) still laggy: `fish_default_key_bindings` → test (vi-mode path); (3) from another pane: `kill -WINCH <pid>` → test, then `kill -CONT <pid>` → test (discriminates reader-wakeup vs generic unwedge; if WINCH cures, a window resize would too); (4) from another pane: `lag-sample <pid>` while typing in the lagging pane; (5) immediately save the flight log for that pid.

## 2026-08-30

- **The post-TUI typing lag is NOT resolved** by the `fish-no-query-term` wrapper: lag recurred in a fresh zellij session after exiting Claude Code, in a shell verified (via `ps eww`) to have `fish_features=no-query-term` in its environment. The query-term reader-degradation bug proven on 2026-08-29 is real (and the wrapper stays as hardening against it), but it is not the mechanism behind this lag. Downgraded the entry below from "root cause" to "a root cause".
- Known constraints on the real mechanism: per-keystroke lag at the main fish commandline; fish `read` prompts unaffected; raw input reaches the pane practical as plain bytes; a subshell/`exec fish` cures it (process-local state). Note the 2026-08-29 triage's reset ladder short-circuited on a false "y" at stage A, so stages B–G (mouse/keypad/altscreen/stty/DECSTR resets) were never actually tested against real lag.
- Added `lag-sample` (fish function): stack-samples the lagging fish process plus the zellij server/client via `/usr/bin/sample` for 8s while the user types at the commandline. This directly names where the time goes (fish reader? highlighting/autosuggestion threads? zellij render loop?) instead of inferring it. Next occurrence: run `lag-sample` in the lagging shell, type junk at the prompt until done, then inspect `~/.local/state/lag-triage/sample-*.txt`. Follow with `unlag` (full reset ladder, never yet truly tested), then A/B toggles: `set -g fish_autosuggestion_enabled 0`, `fish_default_key_bindings`.

## 2026-08-29 (a root cause found and fixed — but not THE lag)

- **Root-caused and fixed the recurring post-TUI typing lag** (fish + Zellij + Ghostty) using a `lag-triage` capture from a live lagging shell plus a deterministic PTY reproduction (`presets/programs/lag-triage/upstream_repro.py`):
  - **Root cause chain**: (1) fish latches feature flags from its **startup environment**, before `config.fish` runs — so the existing `set -gx fish_features no-query-term` in `shellInit` never applied to the shell that set it, only to its children. (2) Zellij spawns pane shells via `default_shell` with no `fish_features` in the environment, so every pane's fish latched `query-term` **on** (the fish 4.8.1 default; the triage log from the lagging shell confirmed `query-term on` while `$fish_features` was correctly set to `no-query-term`). (3) With query-term on, fish sends OSC 11 + CPR (`\e[6n`) + DA1 (`\e[0c`) after **every** command and waits for replies relayed by Zellij. (4) Reproduced on fish 4.8.1: if the terminal fails to reply during just **one** such cycle — answering everything before and after — that fish process's interactive reader is **permanently degraded** (keystroke echo >3s, never recovers; ~35ms before). In production Zellij drops/mangles a relay during TUI teardown or heavy output (cf. zellij-org/zellij#5158), e.g. after `nh home switch`, nvim, jjui, yazi.
  - **Why every previous observation finally makes sense**: subshells and `exec fish` were never "resetting" anything — they *inherited* the exported `fish_features=no-query-term` from config.fish, latched query-term off at startup, and were therefore **immune**. The parent zellij-spawned shell never had the variable at startup and stayed vulnerable. Raw keystroke capture in the lagging pane showed instant plain bytes (input path fine) and no stuck terminal modes — the damage was inside the fish process, exactly as the repro shows.
  - **Fix**: `zellij.nix` now spawns panes through a `fish-no-query-term` wrapper (`export fish_features=no-query-term; exec fish`), so the feature is latched off in every pane shell. Verified: interactive fish through the built wrapper with the real config reports `query-term off`; the PTY repro with `no-query-term` in the environment shows ~35ms echo through all failure phases.
  - **Correction** to the earlier 2026-08-29 entry: `query-term` does **not** default to off in fish 4.8.1 — it defaults on; it only *appeared* off in non-interactive checks because the user config's `set -gx` takes effect for `fish -c` (no reader latch) but not for interactive shells.
  - Upstream: fish-shell should bound the reader's wait for query replies instead of degrading permanently (repro script kept at `presets/programs/lag-triage/upstream_repro.py` for filing); Zellij's reply relaying is the trigger (zellij-org/zellij#5158).
  - `lag-triage` now checks `status features` and calls out `query-term on` as the known root cause, and warns that its `read`-prompt typing tests may not exhibit main-commandline lag (which produced a false "fixed by stage A" in the first capture).

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

## 2026-09-06

- Configured Grafana OIDC authentication via Pocket ID in `platforms/nixos/modules/nmasur/presets/services/grafana/grafana.nix`.
- Enabled `auth.oauth_allow_insecure_email_lookup = true` in Grafana settings to allow linking an incoming OAuth login to an existing Grafana user account with the same email.

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
