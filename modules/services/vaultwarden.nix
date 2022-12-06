{ config, pkgs, lib, ... }:

let vaultwardenPath = "/var/lib/bitwarden_rs"; # Default service directory

in {

  imports = [ ./caddy.nix ./secrets.nix ./backups.nix ];

  options = {

    vaultwardenServer = lib.mkOption {
      description = "Hostname for Vaultwarden.";
      type = lib.types.str;
    };

  };

  config = {
    services.vaultwarden = {
      enable = true;
      config = {
        DOMAIN = "https://${config.vaultwardenServer}";
        SIGNUPS_ALLOWED = false;
        SIGNUPS_VERIFY = true;
        INVITATIONS_ALLOWED = true;
        WEB_VAULT_ENABLED = true;
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
        WEBSOCKET_ENABLED = true;
        WEBSOCKET_ADDRESS = "0.0.0.0";
        WEBSOCKET_PORT = 3012;
        LOGIN_RATELIMIT_SECONDS = 60;
        LOGIN_RATELIMIT_MAX_BURST = 10;
        ADMIN_RATELIMIT_SECONDS = 300;
        ADMIN_RATELIMIT_MAX_BURST = 3;
      };
      environmentFile = config.secrets.vaultwarden.dest;
      dbBackend = "sqlite";
    };

    secrets.vaultwarden = {
      source = ../../private/vaultwarden.age;
      dest = "${config.secretsDirectory}/vaultwarden";
      owner = "vaultwarden";
      group = "vaultwarden";
    };

    networking.firewall.allowedTCPPorts = [ 3012 ];

    caddyRoutes = [{
      match = [{ host = [ config.vaultwardenServer ]; }];
      handle = [{
        handler = "reverse_proxy";
        upstreams = [{ dial = "localhost:8222"; }];
        headers.request.add."X-Real-IP" = [ "{http.request.remote.host}" ];
      }];
    }];

    ## Backup config

    # Open to groups, allowing for backups
    systemd.services.vaultwarden.serviceConfig.StateDirectoryMode =
      lib.mkForce "0770";
    systemd.tmpfiles.rules = [
      "f ${vaultwardenPath}/db.sqlite3 0660 vaultwarden vaultwarden"
      "f ${vaultwardenPath}/db.sqlite3-shm 0660 vaultwarden vaultwarden"
      "f ${vaultwardenPath}/db.sqlite3-wal 0660 vaultwarden vaultwarden"
    ];

    # Allow litestream and vaultwarden to share a sqlite database
    users.users.litestream.extraGroups = [ "vaultwarden" ];
    users.users.vaultwarden.extraGroups = [ "litestream" ];

    # Backup sqlite database with litestream
    services.litestream = {
      settings = {
        dbs = [{
          path = "${vaultwardenPath}/db.sqlite3";
          replicas = [{
            url =
              "s3://${config.backupS3.bucket}.${config.backupS3.endpoint}/vaultwarden";
          }];
        }];
      };
    };

    # Don't start litestream unless vaultwarden is up
    systemd.services.litestream = {
      after = [ "vaultwarden.service" ];
      requires = [ "vaultwarden.service" ];
    };

    # Run a separate file backup on a schedule
    systemd.timers.vaultwarden-backup = {
      timerConfig = {
        OnCalendar = "*-*-* 06:00:00"; # Once per day
        Unit = "vaultwarden-backup.service";
      };
      wantedBy = [ "timers.target" ];
    };

    # Backup other Vaultwarden data to object storage
    systemd.services.vaultwarden-backup = {
      description = "Backup Vaultwarden files";
      environment.AWS_ACCESS_KEY_ID = config.backupS3.accessKeyId;
      serviceConfig = {
        Type = "oneshot";
        User = "vaultwarden";
        Group = "backup";
        EnvironmentFile = config.secrets.backup.dest;
      };
      script = ''
        ${pkgs.awscli2}/bin/aws s3 sync \
            ${vaultwardenPath}/ \
            s3://${config.backupS3.bucket}/vaultwarden/ \
            --endpoint-url=https://${config.backupS3.endpoint} \
            --exclude "*db.sqlite3*" \
            --exclude ".db.sqlite3*"
      '';
    };

  };

}
