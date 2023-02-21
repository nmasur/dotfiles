{ config, lib, ... }: {

  options = {
    n8nServer = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "Hostname for n8n automation";
      default = null;
    };
  };

  config = lib.mkIf (config.n8nServer != null) {

    services.n8n = {
      enable = true;
      settings = {
        n8n = {
          listenAddress = "127.0.0.1";
          port = 5678;
        };
      };
    };

    caddy.routes = [{
      match = [{ host = [ config.n8nServer ]; }];
      handle = [{
        handler = "reverse_proxy";
        upstreams = [{ dial = "localhost:5678"; }];
      }];
    }];

  };

}
