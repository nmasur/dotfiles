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
        nr = "rebuild-nixos";
        nro = "rebuild-nixos offline";
      };
      functions = {
        rebuild-nixos = {
          body = ''
            if test "$argv[1]" = "offline"
                set option "--option substitute false"
            end
            pushd ${config.dotfilesPath}
            git add --all
            popd
            commandline -r "doas nixos-rebuild switch $option --flake ${config.dotfilesPath}"
            commandline -f execute
          '';
        };
      };
    };

  };

}
