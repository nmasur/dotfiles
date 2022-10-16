{ config, lib, ... }:

let giteaPath = "/var/lib/gitea"; # Default service directory

in {

  imports = [ ./caddy.nix ./backups.nix ];

  options = {

    giteaServer = lib.mkOption {
      description = "Hostname for Gitea.";
      type = lib.types.str;
    };

  };

  config = {
    services.gitea = {
      enable = true;
      httpPort = 3001;
      httpAddress = "127.0.0.1";
      rootUrl = "https://${config.giteaServer}/";
      database.type = "sqlite3";
      settings = {
        repository = {
          DEFAULT_PUSH_CREATE_PRIVATE = true;
          DISABLE_HTTP_GIT = false;
          ACCESS_CONTROL_ALLOW_ORIGIN = config.giteaServer;
          ENABLE_PUSH_CREATE_USER = true;
          ENABLE_PUSH_CREATE_ORG = true;
          DEFAULT_BRANCH = "main";
        };
        server = {
          SSH_PORT = 22;
          START_SSH_SERVER = false; # Use sshd instead
          DISABLE_SSH = false;
          # SSH_LISTEN_HOST = "0.0.0.0";
          # SSH_LISTEN_PORT = 122;
        };
        service.DISABLE_REGISTRATION = true;
        session.COOKIE_SECURE = true;
        ui.SHOW_USER_EMAIL = false;
      };
      extraConfig = null;
    };

    networking.firewall.allowedTCPPorts = [ 122 ];

    caddyRoutes = [{
      match = [{ host = [ config.giteaServer ]; }];
      handle = [{
        handler = "reverse_proxy";
        upstreams = [{ dial = "localhost:3001"; }];
      }];
    }];

    ## Backup config

    # Open to groups, allowing for backups
    systemd.services.gitea.serviceConfig.StateDirectoryMode =
      lib.mkForce "0770";
    systemd.tmpfiles.rules = [
      "d ${giteaPath}/data 0775 gitea gitea"
      "f ${giteaPath}/data/gitea.db 0660 gitea gitea"
    ];

    # Allow litestream and gitea to share a sqlite database
    users.users.litestream.extraGroups = [ "gitea" ];
    users.users.gitea.extraGroups = [ "litestream" ];

    # Backup sqlite database with litestream
    services.litestream = {
      settings = {
        dbs = [{
          path = "${giteaPath}/data/gitea.db";
          replicas = [{
            url =
              "s3://${config.backupS3.bucket}.${config.backupS3.endpoint}/gitea";
          }];
        }];
      };
    };

    # Don't start litestream unless gitea is up
    systemd.services.litestream = {
      after = [ "gitea.service" ];
      requires = [ "gitea.service" ];
    };

  };

}
