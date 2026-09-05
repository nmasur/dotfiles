{ config, lib, ... }:

let
  inherit (config.nmasur.settings) hostnames;
  cfg = config.nmasur.presets.services.pocket-id;
in

{

  options.nmasur.presets.services.pocket-id.enable = lib.mkEnableOption "Pocket ID OIDC provider";

  config = lib.mkIf cfg.enable {

    secrets.pocket-id = {
      source = ./pocket-id.age;
      dest = "${config.secretsDirectory}/pocket-id";
      owner = "pocket-id";
      group = "pocket-id";
      permissions = "0440";
    };
    systemd.services.pocket-id-secret = {
      requiredBy = [ "pocket-id.service" ];
      before = [ "pocket-id.service" ];
    };

    services.pocket-id = {
      enable = true;
      settings = {
        APP_URL = "https://${hostnames.auth}";
        TRUST_PROXY = true;
        PORT = 3034;
      };
      credentials = {
        ENCRYPTION_KEY = config.secrets.pocket-id.dest;
      };
    };

    # Allow web traffic to Caddy
    nmasur.presets.services.caddy.routes = [
      {
        match = [ { host = [ hostnames.auth ]; } ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [
              { dial = "localhost:${builtins.toString config.services.pocket-id.settings.PORT}"; }
            ];
          }
        ];
      }
    ];

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ hostnames.auth ];

  };

}
