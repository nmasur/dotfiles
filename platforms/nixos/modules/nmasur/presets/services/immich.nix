{ config, lib, ... }:

let
  cfg = config.nmasur.presets.services.immich;
  inherit (config.nmasur.settings) hostnames;
in

{

  options.nmasur.presets.services.immich.enable = lib.mkEnableOption "Immich photo manager";
  config = lib.mkIf cfg.enable {

    services.immich = {
      enable = true;
      port = 2283;
      group = lib.mkIf config.nmasur.profiles.shared-media.enable "shared";
      database.enable = true;
      redis.enable = true;
      machine-learning.enable = true;
      machine-learning.environment = { };
      mediaLocation = "/data/images";
      secretsFile = null;
      settings.server.externalDomain = "https://${hostnames.photos}";
      environment = {
        IMMICH_ENV = "production";
        IMMICH_LOG_LEVEL = "log";
        NO_COLOR = "false";
        IMMICH_TRUSTED_PROXIES = "127.0.0.1";
      };
    };

    caddy.routes = [
      {
        match = [ { host = [ hostnames.photos ]; } ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [ { dial = "localhost:${builtins.toString config.services.immich.port}"; } ];
          }
        ];
      }
    ];

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ hostnames.photos ];

    # Point localhost to the local domain
    networking.hosts."127.0.0.1" = [ hostnames.photos ];

    # Backups
    services.restic.backups.default.paths = [ "/data/images" ];

  };

}
