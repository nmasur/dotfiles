{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.services.loadkey;
in
{

  options.nmasur.presets.services.loadkey.enable =
    lib.mkEnableOption "Load the private key as an SSH file";

  config = lib.mkIf cfg.enable {

    home.activation = {

      # Always load the key if it doesn't exist
      cloneDotfiles = config.lib.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -f ~/.ssh/id_ed25519 ]; then
            run mkdir -p ~/.ssh/

            $DRY_RUN_CMD mkdir --parents $VERBOSE_ARG $(dirname "${config.dotfilesPath}")
            $DRY_RUN_CMD ${pkgs.git}/bin/git \
                clone ${config.dotfilesRepo} "${config.dotfilesPath}"
        fi
      '';
    };

  };
}
