# Changelog

## 2026-08-16

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
