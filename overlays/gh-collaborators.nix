_final: prev: {

  gh-collaborators = prev.buildGo122Module rec {
    pname = "gh-collaborators";
    version = "2.0.2";

    src = prev.fetchFromGitHub {
      owner = "katiem0";
      repo = "gh-collaborators";
      rev = version;
      sha256 = "sha256-sz5LHkwZ28aA2vbMnFMzAlyGiJBDZm7jwDQYxgKBPLU=";
    };

    vendorHash = "sha256-rsRDOgJBa8T6+bC/APcmuRmg6ykbIp9pwRnJ9rrfHEs=";

    ldflags = [
      "-s"
      "-w"
      "-X github.com/katiem0/gh-collaborators/cmd.Version=${version}"
      # "-X main.Version=${version}"
    ];
  };
}
