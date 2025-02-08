{ config, lib, ... }:

let
  cfg = config.nmasur.presets.services.uptime-kuma;
  inherit (config.nmasur.settings) hostnames;
in

{

  options.nmasur.presets.services.uptime-kuma.enable = lib.mkEnableOption "Uptime-kuma ping monitor";

  config = lib.mkIf cfg.enable {

    services.uptime-kuma = {
      enable = true;
      settings = {
        PORT = "3033";
      };
    };

    # Allow web traffic to Caddy
    caddy.routes = [
      {
        match = [ { host = [ hostnames.status ]; } ];
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
    services.cloudflare-dyndns.domains = [ hostnames.status ];

  };

}
