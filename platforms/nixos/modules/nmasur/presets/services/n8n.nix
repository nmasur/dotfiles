# n8n is an automation integration tool for connecting data from services
# together with triggers.

{ config, lib, ... }:

let
  inherit (config.nmasur.settings) hostnames;
  cfg = config.nmasur.presets.services.n8n;
in

{

  options.nmasur.presets.services.n8n.enable = lib.mkEnableOption "n8n low-code automation tool";

  config = lib.mkIf cfg.enable {

    unfreePackages = [ "n8n" ];

    services.n8n = {
      webhookUrl = "https://${hostnames.n8n}";
      settings = {
        listen_address = "127.0.0.1";
        port = 5678;

      };
    };

    systemd.services.n8n.environment = {
      N8N_EDITOR_BASE_URL = config.services.n8n.webhookUrl;
    };

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ hostnames.n8n ];

    # Allow web traffic to Caddy
    caddy.routes = [
      {
        match = [ { host = [ hostnames.n8n ]; } ];
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
