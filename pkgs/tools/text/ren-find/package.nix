{ pkgs, ... }:
pkgs.rustPlatform.buildRustPackage {
  pname = "ren-find";
  version = "0.0.7";
  src = pkgs.fetchFromGitHub {
    owner = "robenkleene";
    repo = "ren-find";
    rev = "50c40172e354caffee48932266edd7c7a76a20fd";
    sha256 = "sha256-zVIt6Xp+Mvym6gySvHIZJt1QgzKVP/wbTGTubWk6kzI=";
  };
  cargoHash = "sha256-lSeO/GaJPZ8zosOIJRXVIEuPXaBg1GBvKBIuXtu1xZg=";
}
