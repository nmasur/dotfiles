{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "wallpapers";
  version = "0.1";
  src = pkgs.fetchFromGitLab {
    owner = "exorcist365";
    repo = "wallpapers";
    rev = "8d2860ac6c05cec0f78d5c9d07510f4ff5da90dc";
    sha256 = "sha256-1c1uDz37MhksWC75myv6jao5q2mIzD8X8I+TykXXmWg=";
  };
  installPhase = ''
    cp -r $src/ $out/
  '';
}
