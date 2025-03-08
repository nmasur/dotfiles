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
      loadkey = config.lib.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -d ~/.ssh ]; then
            run mkdir --parents $VERBOSE_ARG ~/.ssh/
        fi
        # But only load if using interactive mode
        if [[ $- == *i* ]]; then
            if [ ! -f ~/.ssh/id_ed25519 ]; then
                printf "\nEnter the seed phrase for your SSH key...\n"
                printf "\nThen press ^D when complete.\n\n"
                mkdir -p ~/.ssh/
                ${pkgs.melt}/bin/melt restore ~/.ssh/id_ed25519
                printf "\n\nContinuing activation.\n\n"
            fi
        fi
      '';
    };

  };
}
