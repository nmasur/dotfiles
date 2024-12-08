{ config, lib, ... }:
{

  config = lib.mkIf config.services.audiobookshelf.enable {

    services.audiobookshelf = {
      group = "shared";
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

  };

}
