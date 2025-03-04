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
      src = builtins.fetchGit {
        url = "https://gitflic.ru/magnolia1234/bpc_uploads";
        # owner = "magnolia1234";
        # repo = "bpc_uploads";
        rev = "365832a498fa58cb124e74e3836edc182178c6de";
        sha256 = "0000000000000000000000000000000000000000000000000000";
      };
      preferLocalBuild = true;
      allowSubstitutes = true;
      buildCommand = ''
        dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
        mkdir -p "$dst"
        install -v -m644 "${src}" "$dst/${addonId}.xpi"
      '';
    };
}
