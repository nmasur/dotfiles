inputs: _final: prev: {

  gh-collaborators = prev.buildGoModule rec {
    pname = "gh-collaborators";
    version = "v2.0.3";
    src = inputs.gh-collaborators;

    # vendorHash = "sha256-rsRDOgJBa8T6+bC/APcmuRmg6ykbIp9pwRnJ9rrfHEs=";
    vendorHash = "sha256-fykxRb2U9DDsXorRTLiVWmhMY89N7RS07sal8ww6gz4=";

    ldflags = [
      "-s"
      "-w"
      "-X github.com/katiem0/gh-collaborators/cmd.Version=${version}"
      # "-X main.Version=${version}"
    ];
  };
}
