{ config, lib, ... }:

{

  config = lib.mkIf config.services.immich.enable {

    services.immich = {
      port = 2283;
      group = "shared";
      database.enable = true;
      redis.enable = true;
      machine-learning.enable = true;
      machine-learning.environment = { };
      mediaLocation = "/data/images";
      secretsFile = null;
      settings.server.externalDomain = "https://${config.hostnames.photos}";
      environment = {
        IMMICH_ENV = "production";
        IMMICH_LOG_LEVEL = "log";
        NO_COLOR = "false";
        IMMICH_TRUSTED_PROXIES = "127.0.0.1";
      };
    };

    caddy.routes = [
      {
        match = [ { host = [ config.hostnames.photos ]; } ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [ { dial = "localhost:${builtins.toString config.services.immich.port}"; } ];
          }
        ];
      }
    ];

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ config.hostnames.photos ];

    # Point localhost to the local domain
    networking.hosts."127.0.0.1" = [ config.hostnames.photos ];

    # Backups
    services.restic.backups.default.paths = [ "/data/images" ];

  };

}
