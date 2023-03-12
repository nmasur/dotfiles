{ config, lib, ... }: {

  options = {
    arrServer = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "Hostname for arr services";
      default = null;
    };
  };

  config = lib.mkIf (config.arrServer != null) {

    services.sonarr.enable = true;
    services.radarr.enable = true;
    services.bazarr.enable = true;
    services.prowlarr.enable = true;

    # Requires updating the base_url config value in each service
    # If you try to rewrite the URL, the service won't redirect properly
    caddy.routes = [
      {
        group = "download";
        match = [{
          host = [ config.arrServer ];
          path = [ "/sonarr*" ];
        }];
        handle = [{
          handler = "reverse_proxy";
          upstreams = [{ dial = "localhost:8989"; }];
        }];
      }
      {
        group = "download";
        match = [{
          host = [ config.arrServer ];
          path = [ "/radarr*" ];
        }];
        handle = [{
          handler = "reverse_proxy";
          upstreams = [{ dial = "localhost:7878"; }];
        }];
      }
      {
        group = "download";
        match = [{
          host = [ config.arrServer ];
          path = [ "/prowlarr*" ];
        }];
        handle = [{
          handler = "reverse_proxy";
          upstreams = [{ dial = "localhost:9696"; }];
        }];
      }
      {
        group = "download";
        match = [{
          host = [ config.arrServer ];
          path = [ "/bazarr*" ];
        }];
        handle = [{
          handler = "reverse_proxy";
          upstreams = [{ dial = "localhost:6767"; }];
        }];
      }
    ];

  };

}
