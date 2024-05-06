# n8n is an automation integration tool for connecting data from services
# together with triggers.

{ config, lib, ... }:
{

  config = lib.mkIf config.services.n8n.enable {

    unfreePackages = [ "n8n" ];

    services.n8n = {
      settings = {
        n8n = {
          listenAddress = "127.0.0.1";
          port = 5678;
        };
      };
    };

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ config.hostnames.n8n ];

    # Allow web traffic to Caddy
    caddy.routes = [
      {
        match = [ { host = [ config.hostnames.n8n ]; } ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [ { dial = "localhost:${builtins.toString config.services.n8n.settings.n8n.port}"; } ];
          }
        ];
      }
    ];
  };
}
