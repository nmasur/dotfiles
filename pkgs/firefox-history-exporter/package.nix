{ pkgs, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "firefox-history-exporter";
  version = "1.1";
  src = ./.;

  nativeBuildInputs = [ pkgs.zip ];

  dontUnpack = true;

  installPhase = ''
    dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
    mkdir -p "$dst"
    zip -j "$dst/firefox-history-exporter@nmasur.com.xpi" \
      "${src}/manifest.json" \
      "${src}/background.js" \
      "${src}/popup.html" \
      "${src}/popup.js"
  '';

  meta = with pkgs.lib; {
    description = "Automatically exports today's browsing history.";
    license = licenses.mit;
  };
}
