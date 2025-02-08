{
  config,
  lib,
  ...
}:
let
  cfg = config.nmasur.presets.services.filebrowser;
  inherit (config.nmasur.settings) hostnames;
in
{

  options.nmasur.presets.services.filebrowser.enable = lib.mkEnableOption "Filebrowser private files";

  config = lib.mkIf cfg.enable {

    services.filebrowser = {
      enable = true;
      # Generate password: htpasswd -nBC 10 "" | tr -d ':\n'
      password = "$2y$10$ze1cMob0k6pnXRjLowYfZOVZWg4G.dsPtH3TohbUeEbI0sdkG9.za";
    };

    caddy.routes = [
      {
        match = [ { host = [ hostnames.files ]; } ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [
              { dial = "localhost:8020"; }
            ];
          }
        ];
      }
    ];

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ hostnames.files ];

  };

}
