{ config, pkgs, lib, ... }: {

  options.metricsServer = lib.mkOption {
    type = lib.types.str;
    description = "Hostname of the Grafana server.";
    default = "grafana.masu.rs";
  };

  config = {

    services.grafana.enable = true;
    services.prometheus = {
      enable = true;
      exporters.node.enable = true;
      scrapeConfigs = [{
        job_name = "local";
        static_configs = [{ targets = [ "127.0.0.1:9100" ]; }];
      }];
    };

    caddyRoutes = [{
      match = [{ host = [ config.metricsServer ]; }];
      handle = [{
        handler = "reverse_proxy";
        upstreams = [{ dial = "localhost:3000"; }];
      }];
    }];

  };

}
