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
      sudo = if pkgs.stdenv.isDarwin then "" else "doas";
    in {
      shellAbbrs = {
        nr = "rebuild-${system}";
        nro = "rebuild-${system} offline";
      };
      functions = {
        "rebuild-${system}" = {
          body = ''
            if test "$argv[1]" = "offline"
                set option "--option substitute false"
            end
            pushd ${config.dotfilesPath}
            git add --all
            popd
            echo "${sudo} ${system}-rebuild switch $option --flake ${config.dotfilesPath}"
            ${sudo} ${system}-rebuild switch $option --flake ${config.dotfilesPath}
          '';
        };
      };
    };

  };

}
