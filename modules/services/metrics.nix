{ config, lib, ... }: {

  options = {
    metricsServer = lib.mkOption {
      type = lib.types.str;
      description = "Hostname for Metrics server";
    };
    metricsPasswordHashed = lib.mkOption {
      type = lib.types.str;
      description = "Metrics password hashed with `caddy hash-password`";
    };
  };

  imports = [ ./caddy.nix ];

  config = {

    services.netdata.enable = true;

    caddyRoutes = [{
      match = [{ host = [ config.metricsServer ]; }];
      handle = [
        {
          handler = "authentication";
          providers = {
            http_basic = {
              accounts = [{
                username = config.user;
                password = config.metricsPasswordHashed;
              }];
            };
          };
        }
        {
          handler = "reverse_proxy";
          upstreams = [{ dial = "localhost:19999"; }];
        }
      ];
    }];

  };

}
