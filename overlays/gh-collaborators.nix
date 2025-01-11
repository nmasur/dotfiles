inputs: _final: prev: {

  gh-collaborators = prev.buildGoModule rec {
    pname = "gh-collaborators";
    version = "v3.0.0";
    src = inputs.gh-collaborators;

    vendorHash = "sha256-9qmvG2q9t1Zj8yhKFyA99IaJ90R/gRVdQVjdliVKLRE";

    ldflags = [
      "-s"
      "-w"
      "-X github.com/katiem0/gh-collaborators/cmd.Version=${version}"
      # "-X main.Version=${version}"
    ];
  };
}
