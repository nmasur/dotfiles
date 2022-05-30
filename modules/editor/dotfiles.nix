{ config, pkgs, lib, ... }: {

  home-manager.users.${config.user} = {

    home.activation = {

      # Always clone dotfiles repository if it doesn't exist
      cloneDotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -d "${config.dotfilesPath}" ]; then
            $DRY_RUN_CMD mkdir --parents $VERBOSE_ARG $(dirname ${config.dotfilesPath})
            $DRY_RUN_CMD ${pkgs.git}/bin/git clone https://github.com/nmasur/dotfiles ${config.dotfilesPath}
        fi
      '';

    };

  };

}
