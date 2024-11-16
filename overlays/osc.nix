inputs: _final: prev: {

  osc = prev.buildGoModule {
    pname = "osc";
    version = "v0.4.4";
    src = inputs.osc;

    vendorHash = "sha256-VEzVd1LViMtqhQaltvGuupEemV/2ewMuVYjGbKOi0iw=";

    ldflags = [
      "-s"
      "-w"
    ];
  };
}
