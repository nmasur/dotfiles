{ config, lib, ... }:

let
  inherit (config.nmasur.settings) hostnames;
  cfg = config.nmasur.presets.services.immich;
in

{

  options.nmasur.presets.services.immich.enable = lib.mkEnableOption "Immich photo manager";
  config = lib.mkIf cfg.enable {

    secrets.immich-oidc-secret = {
      source = ./immich-oidc-secret.age;
      dest = "${config.secretsDirectory}/immich-oidc-secret";
      owner = config.services.immich.user;
      group = config.services.immich.group;
      permissions = "0440";
    };
    systemd.services.immich-oidc-secret-secret = {
      requiredBy = [ "immich-server.service" ];
      before = [ "immich-server.service" ];
    };

    services.immich = {
      enable = true;
      port = 2283;
      database.enable = true;
      redis.enable = true;
      machine-learning.enable = true;
      machine-learning.environment = { };
      mediaLocation = "/data/images";
      secretsFile = null;
      settings = {
        server.externalDomain = "https://${hostnames.photos}";
        oauth = {
          enabled = true;
          issuerUrl = "https://${hostnames.auth}";
          clientId = "1f4e0f8d-6cee-4d67-8d53-74bf6c18ae09";
          clientSecret._secret = config.secrets.immich-oidc-secret.dest;
          scope = "openid profile email";
          autoRegister = true;
          buttonText = "Login with Pocket ID";
        };
      };
      environment = {
        IMMICH_ENV = "production";
        IMMICH_LOG_LEVEL = "log";
        NO_COLOR = "false";
        IMMICH_TRUSTED_PROXIES = "127.0.0.1";
      };
    };

    systemd.services.immich-server = {
      after = [ "immich-oidc-secret-secret.service" ];
    };

    nmasur.presets.services.caddy.routes = [
      {
        match = [ { host = [ hostnames.photos ]; } ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [ { dial = "localhost:${builtins.toString config.services.immich.port}"; } ];
          }
        ];
      }
    ];

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ hostnames.photos ];

    # Point localhost to the local domain
    networking.hosts."127.0.0.1" = [ hostnames.photos ];

    # Backups
    services.restic.backups.default.paths = [ "/data/images" ];

  };

}
