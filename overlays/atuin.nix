_inputs: _final: prev: {

  # atuin 18.23.0's PTY-driven e2e tests (e2e_capture, e2e_pty) time out in the
  # darwin build sandbox: shell hooks never report a session ID or history
  # entry. Unit tests pass, but cargo aborts on the first failing e2e binary.
  atuin = prev.atuin.overrideAttrs (_old: {
    doCheck = false;
  });

}
