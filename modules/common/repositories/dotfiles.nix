{ config, pkgs, lib, ... }: {

  options.dotfiles.enable = lib.mkEnableOption "Clone dotfiles.";

  config = lib.mkIf config.dotfiles.enable {

    home-manager.users.${config.user} = {

      home.activation = {

        # Always clone dotfiles repository if it doesn't exist
        cloneDotfiles =
          config.home-manager.users.${config.user}.lib.dag.entryAfter
          [ "writeBoundary" ] ''
            if [ ! -d "${config.dotfilesPath}" ]; then
                $DRY_RUN_CMD mkdir --parents $VERBOSE_ARG $(dirname "${config.dotfilesPath}")

                # Force HTTPS because anonymous SSH doesn't work
                GIT_CONFIG_COUNT=1 \
                    GIT_CONFIG_KEY_0="url.https://github.com/.insteadOf" \
                    GIT_CONFIG_VALUE_0="git@github.com:" \
                    $DRY_RUN_CMD \
                    ${pkgs.git}/bin/git clone ${config.dotfilesRepo} "${config.dotfilesPath}"
            fi
          '';

      };

      # Set a variable for dotfiles repo, not necessary but convenient
      home.sessionVariables.DOTS = config.dotfilesPath;

    };

  };

}
