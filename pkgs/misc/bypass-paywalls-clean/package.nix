{ pkgs, ... }:

# Based on:
# https://git.sr.ht/~rycee/nur-expressions/tree/master/item/pkgs/firefox-addons/default.nix#L34

pkgs.stdenv.mkDerivation rec {
  pname = "bypass-paywalls-clean";
  version = "4.1.1.4";
  src = builtins.fetchGit {
    url = "https://git.masu.rs/noah/bpc-uploads.git";
    ref = "main";
    rev = "9166b13355721b047878f259e04c2e9b476b4210";
  };
  preferLocalBuild = true;
  allowSubstitutes = true;
  buildCommand = ''
    dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
    mkdir -p "$dst"
    install -v -m644 "${src}/bypass_paywalls_clean-${version}.xpi" "$dst/magnolia@12.34.xpi"
  '';
}
