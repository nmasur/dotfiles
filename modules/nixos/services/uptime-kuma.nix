{ config, lib, ... }:
{

  config = lib.mkIf config.services.uptime-kuma.enable {

    services.uptime-kuma = {
      settings = {
        PORT = "3033";
      };
    };

    # Allow web traffic to Caddy
    caddy.routes = [
      {
        match = [ { host = [ config.hostnames.status ]; } ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [
              { dial = "localhost:${config.services.uptime-kuma.settings.PORT}"; }
            ];
          }
        ];
      }
    ];

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ config.hostnames.status ];

  };

}
