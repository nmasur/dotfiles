{ config, lib, ... }: {

  options = {
    streamServer = lib.mkOption {
      type = lib.types.str;
      description = "Hostname for Jellyfin library";
    };
  };

  config = {

    services.jellyfin.enable = true;

    caddyRoutes = [{
      match = [{ host = [ config.streamServer ]; }];
      handle = [{
        handler = "reverse_proxy";
        upstreams = [{ dial = "localhost:8096"; }];
      }];
    }];

    # Create videos directory, allow anyone in Jellyfin group to manage it
    system.activationScripts.jellyfin = let videosDirectory = "/var/videos";
    in {
      text = ''
        if [ ! -d "${videosDirectory}" ]; then
          $DRY_RUN_CMD mkdir --parents $VERBOSE_ARG ${videosDirectory}
          $DRY_RUN_CMD chmod 775 $VERBOSE_ARG ${videosDirectory}
        fi
      '';
    };

  };

}
