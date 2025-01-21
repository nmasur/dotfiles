{ config, lib, ... }:

let
  cfg = config.nmasur.presets.services.ntfy-sh;
in

{
  options.nmasur.presets.services.ntfy-sh.enable = lib.mkEnableOption "ntfy notification service";

  config = lib.mkIf cfg.enable {
    services.ntfy-sh = {
      enable = true;
      settings = {
        base-url = "https://${config.hostnames.notifications}";
        upstream-base-url = "https://ntfy.sh";
        listen-http = ":8333";
        behind-proxy = true;
        auth-default-access = "deny-all";
        auth-file = "/var/lib/ntfy-sh/user.db";
      };
    };

    caddy.routes = [
      {
        match = [ { host = [ config.hostnames.notifications ]; } ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [ { dial = "localhost${config.services.ntfy-sh.settings.listen-http}"; } ];
          }
        ];
      }
    ];

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ config.hostnames.notifications ];

  };
}
