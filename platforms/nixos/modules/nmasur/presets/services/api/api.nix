{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.nmasur.settings) hostnames;
  cfg = config.nmasur.presets.services.api;
in

{

  options.nmasur.presets.services.api = {
    enable = lib.mkEnableOption "API gateway and backend services";
  };

  config = lib.mkIf cfg.enable {

    services.api = {
      enable = true;
      hostname = hostnames.api;
      backends.actual = {
        enable = true;
        actualServerUrl = "http://127.0.0.1:${builtins.toString config.nmasur.presets.services.actualbudget.port}";
        apiKeysFile = config.secrets.api-actual-keys.dest;
        serverPasswordFile = config.secrets.actualbudget-password.dest;
        budgets = {
          budget1 = {
            syncIdFile = config.secrets.api-actual-budget1-sync-id.dest;
          };
          budget2 = {
            syncIdFile = config.secrets.api-actual-budget2-sync-id.dest;
          };
        };
      };
    };

    secrets = {
      api-actual-keys = {
        source = ./api-actual-keys.age;
        dest = "${config.secretsDirectory}/api-actual-keys";
        owner = "api_actual";
        group = "api_actual";
        prefix = "API_KEYS=";
      };
      api-actual-budget1-sync-id = {
        source = ./api-actual-budget1-sync-id.age;
        dest = "${config.secretsDirectory}/api-actual-budget1-sync-id";
        owner = "api_actual";
        group = "api_actual";
        prefix = "ACTUAL_SYNC_ID_BUDGET1=";
      };
      api-actual-budget2-sync-id = {
        source = ./api-actual-budget2-sync-id.age;
        dest = "${config.secretsDirectory}/api-actual-budget2-sync-id";
        owner = "api_actual";
        group = "api_actual";
        prefix = "ACTUAL_SYNC_ID_BUDGET2=";
      };
    };

    systemd.services.api-actual = {
      after = [
        "postgresql-setup.service"
        "actual.service"
        "api-actual-keys-secret.service"
        "api-actual-budget1-sync-id-secret.service"
        "api-actual-budget2-sync-id-secret.service"
        "actualbudget-password-secret.service"
      ];
      requires = [
        "postgresql-setup.service"
        "api-actual-keys-secret.service"
        "api-actual-budget1-sync-id-secret.service"
        "api-actual-budget2-sync-id-secret.service"
        "actualbudget-password-secret.service"
      ];
    };

    # Postgres peer authentication for api_actual
    services.postgresql.authentication = lib.mkAfter ''
      local api_actual api_actual peer
    '';

    # Backup PostgreSQL database for api_actual
    services.postgresqlBackup = {
      enable = true;
      databases = [ "api_actual" ];
    };

    # Allow web traffic to Caddy
    nmasur.presets.services.caddy.routes = config.services.api.caddyRoutes;

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ hostnames.api ];

    # Backups
    services.restic.backups.default.paths = [ "/var/lib/api-actual" ];

  };

}
