{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "wallpapers";
  version = "0.1";
  src = pkgs.fetchFromGitLab {
    owner = "exorcist365";
    repo = "wallpapers";
    rev = "8d2860ac6c05cec0f78d5c9d07510f4ff5da90dc";
    sha256 = "155lb7w563dk9kdn4752hl0zjhgnq3j4cvs9z98nb25k1xpmpki7";
  };
  installPhase = ''
    cp -r $src/ $out/
  '';
}
