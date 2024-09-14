{ config, lib, ... }:

{

  config = lib.mkIf config.services.ntfy-sh.enable {
    services.ntfy-sh = {
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
