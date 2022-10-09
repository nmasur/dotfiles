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
    systemd.services.videos-library = {
      wantedBy = [ "jellyfin.service" ];
      requiredBy = [ "jellyfin.service" ];
      before = [ "jellyfin.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = let videosDirectory = "/var/videos";
      in ''
        mkdir --parents --mode 0755 ${videosDirectory}
        chown jellyfin:jellyfin ${videosDirectory}
      '';
    };

  };

}
