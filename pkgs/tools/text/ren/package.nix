{ pkgs, ... }:
pkgs.rustPlatform.buildRustPackage {
  pname = "ren-find";
  version = "0.0.7";
  src = pkgs.fetchFromGitHub {
    owner = "robenkleene";
    repo = "ren-find";
    rev = "4af7c8e54ecc499097121909f02ecb42a8a60d24";
    sha256 = pkgs.lib.fakeHash;
  };
  cargoHash = "sha256-3bI3j2xvNHp4kyLEq/DZvRJBF2rn6pE4n8oXh67edDI=";
}
