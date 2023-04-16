{ config, pkgs, lib, ... }: {

  options = {

    nextcloudServer = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "Hostname for Nextcloud";
      default = null;
    };

  };

  config = lib.mkIf (config.nextcloudServer != null) {

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud26; # Required to specify
      datadir = "/data/nextcloud";
      https = true;
      hostName = "localhost";
      maxUploadSize = "50G";
      config = {
        adminpassFile = config.secrets.nextcloud.dest;
        extraTrustedDomains = [ config.nextcloudServer ];
      };
    };

    # Don't let Nginx use main ports (using Caddy instead)
    services.nginx.virtualHosts."localhost".listen = [{
      addr = "127.0.0.1";
      port = 8080;
    }];

    # Point Caddy to Nginx
    caddy.routes = [{
      match = [{ host = [ config.nextcloudServer ]; }];
      handle = [{
        handler = "reverse_proxy";
        upstreams = [{ dial = "localhost:8080"; }];
      }];
    }];

    # Create credentials file for nextcloud
    secrets.nextcloud = {
      source = ../../../private/nextcloud.age;
      dest = "${config.secretsDirectory}/nextcloud";
      owner = "nextcloud";
      group = "nextcloud";
      permissions = "0440";
    };
    systemd.services.nextcloud-secret = {
      requiredBy = [ "nextcloud-setup.service" ];
      before = [ "nextcloud-setup.service" ];
    };

    # Grant user access to Nextcloud directories
    users.users.${config.user}.extraGroups = [ "nextcloud" ];

    ## Backup config

    # Open to groups, allowing for backups
    systemd.services.phpfpm-nextcloud.serviceConfig.StateDirectoryMode =
      lib.mkForce "0770";

    # Allow litestream and nextcloud to share a sqlite database
    users.users.litestream.extraGroups = [ "nextcloud" ];
    users.users.nextcloud.extraGroups = [ "litestream" ];

    # Backup sqlite database with litestream
    services.litestream = {
      settings = {
        dbs = [{
          path = "${config.services.nextcloud.datadir}/data/nextcloud.db";
          replicas = [{
            url =
              "s3://${config.backup.s3.bucket}.${config.backup.s3.endpoint}/nextcloud";
          }];
        }];
      };
    };

    # Don't start litestream unless nextcloud is up
    systemd.services.litestream = {
      after = [ "phpfpm-nextcloud.service" ];
      requires = [ "phpfpm-nextcloud.service" ];
    };

  };

}
