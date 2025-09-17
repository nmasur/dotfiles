# Stalwart is a self-hosted email service, but in my case I want to use it as a
# vCard contacts database server and ignore the email component.

{ config, lib, ... }:

let
  inherit (config.nmasur.settings) hostnames;
  cfg = config.nmasur.presets.services.stalwart-mail;
in

{

  options.nmasur.presets.services.stalwart-mail = {
    enable = lib.mkEnableOption "Stalwart mail and contacts server";
    port = lib.mkOption {
      type = lib.types.port;
      description = "Port to use for the localhost";
      default = 7982;
    };
  };

  config = lib.mkIf cfg.enable {

    services.stalwart-mail = {
      enable = true;
      settings = {
        server.listener.http = {
          bind = [ "127.0.0.1:${builtins.toString cfg.port}" ];
          protocol = "http";
        };
        authentication.fallback-admin = {
          user = "admin";
          secret = "$6$W/zXJP0xtZSUQqIe$DedCz9ncAn8mtfQVCg8Fzguuz.x8u1dfVU/d7wKyc6ujLuY4WCdtY0OeYwpv8huJfKAgBKE3go2MTrT99ID7I1";
        };
      };
    };

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ hostnames.contacts ];

    # Allow web traffic to Caddy
    nmasur.presets.services.caddy.routes = [
      {
        match = [ { host = [ hostnames.contacts ]; } ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [
              { dial = "localhost:${builtins.toString cfg.port}"; }
            ];
          }
        ];
      }
    ];
  };
}
