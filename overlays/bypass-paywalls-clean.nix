inputs: _final: prev: {

  # Based on:
  # https://git.sr.ht/~rycee/nur-expressions/tree/master/item/pkgs/firefox-addons/default.nix#L34

  bypass-paywalls-clean =
    let
      addonId = "magnolia@12.34";
    in
    prev.stdenv.mkDerivation rec {
      pname = "bypass-paywalls-clean";
      version = "3.6.6.0";
      src = inputs.bypass-paywalls-clean;
      preferLocalBuild = true;
      allowSubstitutes = true;
      buildCommand = ''
        dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
        mkdir -p "$dst"
        install -v -m644 "${src}" "$dst/${addonId}.xpi"
      '';
    };
}
