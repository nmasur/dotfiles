{ config, pkgs, lib, ... }: {

  home-manager.users.${config.user} = {

    home.activation = {

      # Always clone dotfiles repository if it doesn't exist
      cloneDotfiles =
        config.home-manager.users.${config.user}.lib.dag.entryAfter
        [ "writeBoundary" ] ''
          if [ ! -d "${config.dotfilesPath}" ]; then
              $DRY_RUN_CMD mkdir --parents $VERBOSE_ARG $(dirname "${config.dotfilesPath}")
              $DRY_RUN_CMD ${pkgs.git}/bin/git clone ${config.dotfilesRepo} "${config.dotfilesPath}"
          fi
        '';

    };

    programs.fish = {
      shellAbbrs = {
        nr = lib.mkIf pkgs.stdenv.isLinux
          "doas nixos-rebuild switch --flake ${config.dotfilesPath}";
      };
    };

  };

}
