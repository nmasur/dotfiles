{ config, lib, ... }:
let
  inherit (config.nmasur.settings) hostnames;
  cfg = config.nmasur.presets.services.thelounge;
in
{

  config = lib.mkIf cfg.enable {

    services.thelounge = {
      public = false;
      port = 9000;
      extraConfig = {
        reverseProxy = true;
        maxHistory = 10000;
      };
    };

    # Adding new users:
    # nix shell nixpkgs#thelounge
    # sudo su - thelounge -s /bin/sh -c "thelounge add myuser"

    # Allow web traffic to Caddy
    caddy.routes = [
      {
        match = [ { host = [ hostnames.irc ]; } ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [ { dial = "localhost:${builtins.toString config.services.thelounge.port}"; } ];
          }
        ];
      }
    ];

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ hostnames.irc ];
  };
}
