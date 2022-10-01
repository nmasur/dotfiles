{ config, pkgs, lib, ... }:

let

  libraryPath = "${config.homePath}/media/books";

in {

  options = { };

  config = {
    services.calibre-server = {
      enable = true;
      libraries = [ libraryPath ];
    };

    services.calibre-web = {
      enable = true;
      openFirewall = true;
      options = {
        reverseProxyAuth.enable = false;
        enableBookConversion = true;
      };
    };

    home-manager.users.${config.user}.home.activation = {

      # Always create library directory if it doesn't exist
      calibreLibrary =
        config.home-manager.users.${config.user}.lib.dag.entryAfter
        [ "writeBoundary" ] ''
          if [ ! -d "${libraryPath}" ]; then
              $DRY_RUN_CMD mkdir --parents $VERBOSE_ARG ${libraryPath}
          fi
        '';

    };

  };

}
