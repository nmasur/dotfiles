{ config, lib, ... }: {

  options.metricsServer = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    description = "Hostname of the metrics server.";
    default = null;
  };

  config = lib.mkIf config.services.grafana.enable {

    services.grafana.settings.server = {
      domain = config.metricsServer;
      http_addr = "127.0.0.1";
      http_port = 3000;
      protocol = "http";
    };

    caddy.routes = [{
      match = [{ host = [ config.metricsServer ]; }];
      handle = [{
        handler = "reverse_proxy";
        upstreams = [{ dial = "localhost:3000"; }];
      }];
    }];

  };

}
