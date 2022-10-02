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
  };

}
