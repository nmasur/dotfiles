{ pkgs, ... }:
pkgs.rustPlatform.buildRustPackage {
  pname = "rep-grep";
  version = "0.0.7";
  src = pkgs.fetchFromGitHub {
    owner = "robenkleene";
    repo = "rep-grep";
    rev = "4af7c8e54ecc499097121909f02ecb42a8a60d24";
    sha256 = pkgs.lib.fakeHash;
  };
  cargoHash = "sha256-GEr3VvQ0VTKHUbW/GFEgwLpQWP2ZhS/4KYjDvfFLgxo=";
}
