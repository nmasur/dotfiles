# n8n is an automation integration tool for connecting data from services
# together with triggers.

{ config, lib, ... }:
{

  config = lib.mkIf config.services.n8n.enable {

    unfreePackages = [ "n8n" ];

    services.n8n = {
      webhookUrl = "https://${config.hostnames.n8n}";
      settings = {
        listen_address = "127.0.0.1";
        port = 5678;

      };
    };

    systemd.services.n8n.environment = {
      N8N_EDITOR_BASE_URL = config.services.n8n.webhookUrl;
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
            upstreams = [ { dial = "localhost:${builtins.toString config.services.n8n.settings.port}"; } ];
          }
        ];
      }
    ];
  };
}
