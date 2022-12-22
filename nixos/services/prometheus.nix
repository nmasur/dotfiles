{ config, pkgs, lib, ... }: {

  options.metricsServer = lib.mkOption {
    type = lib.types.str;
    description = "Hostname of the Grafana server.";
    default = null;
  };

  config = lib.mkIf (config.metricsServer != null) {

    services.grafana.enable = true;

    # Required to fix error in latest nixpkgs
    services.grafana.settings = { };

    services.prometheus = {
      enable = true;
      exporters.node.enable = true;
      scrapeConfigs = [{
        job_name = "local";
        static_configs = [{ targets = [ "127.0.0.1:9100" ]; }];
      }];
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
