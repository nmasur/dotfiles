{ pkgs, ... }:

# Based on:
# https://git.sr.ht/~rycee/nur-expressions/tree/master/item/pkgs/firefox-addons/default.nix#L34

pkgs.stdenv.mkDerivation rec {
  pname = "bypass-paywalls-clean";
  version = "4.0.6.1";
  src = builtins.fetchGit {
    url = "https://gitflic.ru/project/magnolia1234/bpc_uploads.git";
    ref = "main";
    rev = "85a367220f5ae2181354f65fb1093e2f1ac9e417";
  };
  preferLocalBuild = true;
  allowSubstitutes = true;
  buildCommand = ''
    dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
    mkdir -p "$dst"
    install -v -m644 "${src}/bypass_paywalls_clean-${version}.xpi" "$dst/magnolia@12.34.xpi"
  '';
}
