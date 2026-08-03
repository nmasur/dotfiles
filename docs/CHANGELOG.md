# Changelog

## 2026-08-03

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
