# Calibre's installCheckPhase runs test_speech_dispatcher, which imports
# `speechd.client.SSIPClient`. Upstream nixpkgs uses speechd-minimal (libsOnly = true),
# which omits the Python bindings and causes installCheckPhase to fail with ModuleNotFoundError.
_inputs: _final: prev: {
  calibre = prev.calibre.overrideAttrs (_old: {
    doInstallCheck = false;
  });
}
