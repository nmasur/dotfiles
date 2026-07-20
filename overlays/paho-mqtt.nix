# Disable paho-mqtt's flaky test suite.
#
# paho-mqtt's checkPhase runs socket-based integration tests that hang in
# the Nix sandbox (they eventually time out with a KeyboardInterrupt after
# ~150s, reporting errors and failing the build). This breaks the flame
# rebuild, where paho-mqtt is pulled in transitively (e.g. via mealie).
#
# Applied through pythonPackagesExtensions so it covers every Python
# package set (python3Packages, python314Packages, ...).

_inputs: _final: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (_pyfinal: pyprev: {
      paho-mqtt = pyprev.paho-mqtt.overridePythonAttrs (_old: {
        doCheck = false;
        doInstallCheck = false;
      });
    })
  ];
}
