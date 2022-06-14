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

    programs.fish = let
      system = if pkgs.stdenv.isDarwin then "darwin" else "nixos";
      sudo = if pkgs.stdenv.isDarwin then "doas" else "sudo";
    in {
      shellAbbrs = { nr = lib.mkIf pkgs.stdenv.isLinux "rebuild-${system}"; };
      functions = {
        rebuild-nixos = {
          body = ''
            pushd ${config.dotfilesPath}
            git add --all
            popd
            echo "${sudo} ${system}-rebuild switch --flake ${config.dotfilesPath}"
            ${sudo} ${system}-rebuild switch --flake ${config.dotfilesPath}
          '';
        };
      };
    };

  };

}
