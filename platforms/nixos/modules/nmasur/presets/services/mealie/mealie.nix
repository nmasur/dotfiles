{ config, lib, ... }:

let
  inherit (config.nmasur.settings) hostnames;
  cfg = config.nmasur.presets.services.mealie;
in

{

  options.nmasur.presets.services.mealie.enable = lib.mkEnableOption "mealie recipe manager";
  config = lib.mkIf cfg.enable {

    secrets.mealie-oidc-secret = {
      source = ./mealie-oidc-secret.age;
      dest = "${config.secretsDirectory}/mealie-oidc-secret";
      prefix = "OIDC_CLIENT_SECRET=";
    };
    systemd.services.mealie-oidc-secret-secret = {
      requiredBy = [ "mealie.service" ];
      before = [ "mealie.service" ];
    };

    services.mealie = {
      enable = true;
      port = 9099;
      database.createLocally = true;
      listenAddress = "127.0.0.1";
      credentialsFile = config.secrets.mealie-oidc-secret.dest;
      settings = {
        TOKEN_TIME = 7200; # Hours for login to last (300 days)
        OIDC_AUTH_ENABLED = "true";
        OIDC_SIGNUP_ENABLED = "true";
        OIDC_CONFIGURATION_URL = "https://${hostnames.auth}/.well-known/openid-configuration";
        OIDC_CLIENT_ID = "040925ed-b39e-4442-b8e8-369c948c0cd2";
        OIDC_PROVIDER_NAME = "Pocket ID";
        OIDC_USER_CLAIM = "email";
      };
    };

    systemd.services.mealie = {
      after = [ "mealie-oidc-secret-secret.service" ];
    };

    # Fix BASE_URL for downloading backups
    systemd.services.mealie.environment.BASE_URL = lib.mkForce "https://${hostnames.recipes}";

    nmasur.presets.services.caddy.routes = [
      {
        match = [ { host = [ hostnames.recipes ]; } ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [ { dial = "localhost:${toString config.services.mealie.port}"; } ];
          }
        ];
      }
    ];

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ hostnames.recipes ];

    # Point localhost to the local domain
    networking.hosts."127.0.0.1" = [ hostnames.recipes ];

  };

}
