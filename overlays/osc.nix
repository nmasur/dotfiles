inputs: _final: prev: {

  osc = prev.buildGoModule {
    pname = "osc";
    version = "v0.4.6";
    src = inputs.osc;

    vendorHash = "sha256-POtQWIjPObsfa3YZ1dLZgedZFUcc4HeTWjU20AucoKc=";

    ldflags = [
      "-s"
      "-w"
    ];
  };
}
