{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "firefox-history-exporter";
  version = "1.0";
  src = ./.;

  nativeBuildInputs = [ pkgs.zip ];

  # We are not building anything, just packaging.
  dontBuild = true;

  installPhase = ''
    # The directory structure expected by Firefox and home-manager.
    # The UUID is the official application ID for Firefox.
    install_dir=$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}
    mkdir -p $install_dir

    # The filename of the .xpi file serves as the extension's ID.
    # An email-like format is a common convention.
    extension_id="firefox-history-exporter@localhost.xpi"

    # Go into the source directory and zip all files into the .xpi archive.
    # This ensures the manifest.json is at the root of the archive.
    (cd $src; zip $install_dir/$extension_id *)
  '';

  meta = with pkgs.lib; {
    description = "Automatically exports today's browsing history.";
    license = licenses.mit;
  };
}
