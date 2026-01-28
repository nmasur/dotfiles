{ pkgs, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "firefox-history-exporter";
  version = "1.0";
  src = ./.;

  nativeBuildInputs = [ pkgs.zip ];

  # We aren't building, just packaging
  dontUnpack = true;

  buildCommand = ''
    dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
    mkdir -p "$dst"
    (cd ${src}; zip "$dst/firefox-history-exporter@nmasur.com.xpi" manifest.json background.js popup.html popup.js)
  '';

  meta = with pkgs.lib; {
    description = "Automatically exports today's browsing history.";
    license = licenses.mit;
  };
}
