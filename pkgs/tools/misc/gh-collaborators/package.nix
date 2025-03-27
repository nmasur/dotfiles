{ buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "gh-collaborators";
  version = "v3.0.0";
  src = fetchFromGitHub {
    owner = "katiem0";
    repo = "gh-collaborators";
    rev = "bf412dde50605e48af86f291c2ac8714f2c1b228";
    sha256 = "sha256-SGmP/8Fvf2rcYkwscMOFG01Y0VJGb/TXrNZtLacurxA=";
  };

  vendorHash = "sha256-9qmvG2q9t1Zj8yhKFyA99IaJ90R/gRVdQVjdliVKLRE";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/katiem0/gh-collaborators/cmd.Version=${version}"
    # "-X main.Version=${version}"
  ];
}
