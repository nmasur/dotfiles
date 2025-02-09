{ pkgs, ... }:

pkgs.buildGoModule rec {
  pname = "gh-collaborators";
  version = "v3.0.0";
  src = {
    owner = "katiem0";
    repo = "gh-collaborators";
    rev = "4af7c8e54ecc499097121909f02ecb42a8a60d24";
    sha256 = pkgs.lib.fakeHash;
  };

  vendorHash = "sha256-9qmvG2q9t1Zj8yhKFyA99IaJ90R/gRVdQVjdliVKLRE";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/katiem0/gh-collaborators/cmd.Version=${version}"
    # "-X main.Version=${version}"
  ];
}
