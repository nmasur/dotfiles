{ config, lib, ... }:
{

  options = {
    hostnames.audiobooks = lib.mkOption {
      type = lib.types.str;
      description = "Hostname for audiobook server (Audiobookshelf).";
    };
  };

  config = lib.mkIf config.services.audiobookshelf.enable {

    services.audiobookshelf = {
      dataDir = "audiobookshelf";
    };

    # Allow web traffic to Caddy
    caddy.routes = [
      {
        match = [ { host = [ config.hostnames.audiobooks ]; } ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [ { dial = "localhost:${builtins.toString config.services.audiobookshelf.port}"; } ];
          }
        ];
      }
    ];

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ config.hostnames.audiobooks ];

    # Grant user access to Audiobookshelf directories
    users.users.${config.user}.extraGroups = [ config.services.audiobookshelf.group ];

    # Grant audiobookshelf access to media and Calibre directories
    users.users.${config.services.audiobookshelf.user}.extraGroups = [
      "media"
      "calibre-web"
    ];

  };

}
