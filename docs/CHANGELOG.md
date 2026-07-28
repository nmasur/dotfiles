# Changelog

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
