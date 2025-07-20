# Navidrome is a self-hosted music streaming service. This means I can play
# files from my server to devices.

{ config, lib, ... }:

let
  inherit (config.nmasur.settings) hostnames;
  cfg = config.nmasur.presets.services.navidrome;
in

{

  options.nmasur.presets.services.navidrome.enable = lib.mkEnableOption "Navidrome music streaming";

  config = lib.mkIf cfg.enable {

    secrets.navidrome-integrations = {
      source = ./navidrome-integrations.age;
      dest = "/var/private/navidrome-integrations";
    };

    services.navidrome = {
      enable = true;
      settings = {
        MusicFolder = "/data/audio/music";
        EnableInsightsCollector = false;
      };
      environmentFile = config.secrets.navidrome-integrations.dest;
    };

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ hostnames.navidrome ];

    # Allow web traffic to Caddy
    nmasur.presets.services.caddy.routes = [
      {
        match = [ { host = [ hostnames.navidrome ]; } ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [
              { dial = "localhost:${builtins.toString config.services.navidrome.settings.Port}"; }
            ];
          }
        ];
      }
    ];
  };
}
