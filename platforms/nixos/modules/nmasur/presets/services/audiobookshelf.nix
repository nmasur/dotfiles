{
  config,
  lib,
  globals,
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

      # Setting a generic group to make it easier for the different programs
      # that make use of the same files
      group = lib.mkIf config.nmasur.profiles.shared-media.enable "shared";

      # This is the default /var/lib/audiobookshelf
      dataDir = "audiobookshelf";
    };

    # Allow web traffic to Caddy
    caddy.routes = [
      {
        match = [ { host = [ globals.hostnames.audiobooks ]; } ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [ { dial = "localhost:${builtins.toString config.services.audiobookshelf.port}"; } ];
          }
        ];
      }
    ];

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ globals.hostnames.audiobooks ];

  };

}
