{ config, lib, ... }: {

  config = lib.mkIf config.services.grafana.enable {

    services.grafana.settings.server = {
      domain = config.hostnames.metrics;
      http_addr = "127.0.0.1";
      http_port = 3000;
      protocol = "http";
    };

    caddy.routes = [{
      match = [{ host = [ config.hostnames.metrics ]; }];
      handle = [{
        handler = "reverse_proxy";
        upstreams = [{
          dial = "localhost:${
              builtins.toString
              config.services.grafana.settings.server.http_port
            }";
        }];
      }];
    }];

  };

}
