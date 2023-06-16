# Testing: https://github.com/cli/cli/issues/5011#issuecomment-1576931518

_final: prev: {
  gh = prev.gh.overrideAttrs (old: {
    src = prev.fetchFromGitHub {
      owner = "cli";
      repo = "cli";
      rev = "420f63c3ec660d27182b713bd18459e7376f0a7a";
      sha256 = "sha256-ik4YCQBTr9637dofrh/AcgoOBa8Bx9F+brUMpC8u5U8=";
    };
  });
}
