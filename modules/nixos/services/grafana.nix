{ config, lib, ... }: {

  options.metricsServer = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    description = "Hostname of the metrics server.";
    default = null;
  };

  config = lib.mkIf config.services.grafana.enable {

    # Required to fix error in latest nixpkgs
    services.grafana.settings = { };

    caddy.routes = [{
      match = [{ host = [ config.metricsServer ]; }];
      handle = [{
        handler = "reverse_proxy";
        upstreams = [{ dial = "localhost:3000"; }];
      }];
    }];

  };

}
