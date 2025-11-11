{ config, lib, ... }:

let
  inherit (config.nmasur.settings) hostnames;
  cfg = config.nmasur.presets.services.mealie;
in

{

  options.nmasur.presets.services.mealie.enable = lib.mkEnableOption "mealie recipe manager";
  config = lib.mkIf cfg.enable {

    services.mealie = {
      enable = true;
      port = 9099;
      database.createLocally = true;
      listenAddress = "127.0.0.1";
    };

    nmasur.presets.services.caddy.routes = [
      {
        match = [ { host = [ hostnames.recipes ]; } ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [ { dial = "localhost:${builtins.toString config.services.mealie.port}"; } ];
          }
        ];
      }
    ];

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ hostnames.recipes ];

    # Point localhost to the local domain
    networking.hosts."127.0.0.1" = [ hostnames.recipes ];

  };

}
