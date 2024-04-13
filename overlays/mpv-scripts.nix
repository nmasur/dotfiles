inputs: _final: prev: {

  mpvScripts = prev.mpvScripts // {
    # Delete current file after quitting
    mpv-delete-file = prev.stdenv.mkDerivation rec {
      pname = "mpv-delete-file";
      version = "0.1"; # made-up
      src = inputs.zenyd-mpv-scripts + "/delete_file.lua";
      dontBuild = true;
      dontUnpack = true;
      installPhase = "install -Dm644 ${src} $out/share/mpv/scripts/delete_file.lua";
      passthru.scriptName = "delete_file.lua";
    };
  };
}
