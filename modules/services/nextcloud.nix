{ config, pkgs, lib, ... }:

let

  adminpassFile = "/var/lib/nextcloud/creds";
  backupS3File = "/var/lib/nextcloud/backup-creds";

in {

  imports = [ ./caddy.nix ../shell/age.nix ];

  options = {

    nextcloudServer = lib.mkOption {
      type = lib.types.str;
      description = "Hostname for Nextcloud";
    };

    # Options for backup
    backupS3 = {
      endpoint = lib.mkOption {
        type = lib.types.str;
        description = "S3 endpoint for backups";
      };
      bucket = lib.mkOption {
        type = lib.types.str;
        description = "S3 bucket for backups";
      };
      accessKeyId = lib.mkOption {
        type = lib.types.str;
        description = "S3 access key ID for backups";
      };
    };

  };

  config = {

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud24; # Required to specify
      https = true;
      hostName = "localhost";
      maxUploadSize = "50G";
      config = {
        adminpassFile = adminpassFile;
        extraTrustedDomains = [ config.nextcloudServer ];
        trustedProxies = [

          # Cloudflare IPv4: https://www.cloudflare.com/ips-v4
          "173.245.48.0/20"
          "103.21.244.0/22"
          "103.22.200.0/22"
          "103.31.4.0/22"
          "141.101.64.0/18"
          "108.162.192.0/18"
          "190.93.240.0/20"
          "188.114.96.0/20"
          "197.234.240.0/22"
          "198.41.128.0/17"
          "162.158.0.0/15"
          "104.16.0.0/13"
          "104.24.0.0/14"
          "172.64.0.0/13"
          "131.0.72.0/22"

          # Cloudflare IPv6: https://www.cloudflare.com/ips-v6
          "2400:cb00::/32"
          "2606:4700::/32"
          "2803:f800::/32"
          "2405:b500::/32"
          "2405:8100::/32"
          "2a06:98c0::/29"
          "2c0f:f248::/32"

        ];
      };
    };

    # Don't let Nginx use main ports (using Caddy instead)
    services.nginx.virtualHosts."localhost".listen = [{
      addr = "127.0.0.1";
      port = 8080;
    }];

    caddyRoutes = [{
      match = [{ host = [ config.nextcloudServer ]; }];
      handle = [{
        handler = "reverse_proxy";
        upstreams = [{ dial = "localhost:8080"; }];
      }];
    }];

    # Create credentials file for nextcloud
    systemd.services.nextcloud-creds = {
      requiredBy = [ "nextcloud-setup.service" ];
      before = [ "nextcloud-setup.service" ];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      script = ''
        mkdir --parents $(dirname ${adminpassFile})
        ${pkgs.age}/bin/age --decrypt \
          --identity ${config.identityFile} \
          --output ${adminpassFile} \
          ${builtins.toString ../../private/nextcloud.age}
        chown nextcloud:nextcloud ${adminpassFile}
        chmod 0700 ${adminpassFile}
      '';
    };

    ## Backup config

    # Open to groups, allowing for backups
    systemd.services.phpfpm-nextcloud.serviceConfig.StateDirectoryMode =
      lib.mkForce "0770";

    # Allow litestream and nextcloud to share a sqlite database
    users.users.litestream.extraGroups = [ "nextcloud" ];
    users.users.nextcloud.extraGroups = [ "litestream" ];

    # Backup sqlite database with litestream
    services.litestream = {
      enable = true;
      settings = {
        dbs = [{
          path = "/var/lib/nextcloud/data/nextcloud.db";
          replicas = [{
            url =
              "s3://${config.backupS3.bucket}.${config.backupS3.endpoint}/nextcloud";
          }];
        }];
      };
      environmentFile = backupS3File;
    };

    # Don't start litestream unless nextcloud is up
    systemd.services.litestream = {
      after = [ "phpfpm-nextcloud.service" ];
      requires = [ "phpfpm-nextcloud.service" ];
      environment.LITESTREAM_ACCESS_KEY_ID = config.backupS3.accessKeyId;
    };

    # Create credentials file for litestream
    systemd.services.litestream-s3 = {
      requiredBy = [ "litestream.service" ];
      before = [ "litestream.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        echo \
          LITESTREAM_SECRET_ACCESS_KEY=$(${pkgs.age}/bin/age --decrypt \
            --identity ${config.identityFile} \
            ${builtins.toString ../../private/backup.age} \
          ) > ${backupS3File}
        chown litestream:litestream ${backupS3File}
        chmod 0700 ${backupS3File}
      '';
    };

  };

}
