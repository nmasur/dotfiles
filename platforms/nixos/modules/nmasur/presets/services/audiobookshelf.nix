{
  config,
  lib,
  hostnames,
  ...
}:

let
  cfg = config.nmasur.presets.services.audiobookshelf;
in

{

  options.nmasur.presets.services.audiobookshelf.enable =
    lib.mkEnableOption "Audiobookshelf e-book and audiobook manager";

  config = lib.mkIf cfg.enable {

    services.audiobookshelf = {
      enable = true;

      # This is the default /var/lib/audiobookshelf
      dataDir = "audiobookshelf";
    };

    # Allow web traffic to Caddy
    nmasur.presets.services.caddy.routes = [
      {
        match = [ { host = [ hostnames.audiobooks ]; } ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [ { dial = "localhost:${builtins.toString config.services.audiobookshelf.port}"; } ];
          }
        ];
      }
    ];

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ hostnames.audiobooks ];

  };

}
