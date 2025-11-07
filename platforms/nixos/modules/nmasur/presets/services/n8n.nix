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

    allowUnfreePackages = [ "n8n" ];

    services.n8n = {
      enable = true;
      environment = {
        N8N_LISTEN_ADDRESS = "127.0.0.1";
        N8N_PORT = 5678;
        N8N_EDITOR_BASE_URL = "https://${hostnames.n8n}";
      };
    };

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ hostnames.n8n ];

    # Allow web traffic to Caddy
    nmasur.presets.services.caddy.routes = [
      {
        match = [ { host = [ hostnames.n8n ]; } ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [
              { dial = "localhost:${builtins.toString config.services.n8n.environment.N8N_PORT}"; }
            ];
          }
        ];
      }
    ];
  };
}
