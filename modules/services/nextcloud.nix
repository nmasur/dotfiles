{ config, pkgs, lib, ... }:

let
  adminpassFile = "/var/lib/nextcloud/creds";
  s3SecretFile = "/var/lib/nextcloud/creds-s3";

in {

  options = {

    nextcloudServer = lib.mkOption {
      type = lib.types.str;
      description = "Hostname for Nextcloud";
    };

    nextcloudS3 = {
      bucket = lib.mkOption {
        type = lib.types.str;
        description = "S3 bucket name for Nextcloud storage";
      };
      hostname = lib.mkOption {
        type = lib.types.str;
        description = "S3 endpoint for Nextcloud storage";
      };
      key = lib.mkOption {
        type = lib.types.str;
        description = "S3 access key for Nextcloud storage";
      };
    };
  };

  config = {

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud24; # Required to specify
      https = true;
      hostName = "localhost";
      config = {
        adminpassFile = adminpassFile;
        extraTrustedDomains = [ config.nextcloudServer ];
        objectstore.s3 = {
          enable = true;
          bucket = config.nextcloudS3.bucket;
          hostname = config.nextcloudS3.hostname;
          key = config.nextcloudS3.key;
          autocreate = false;
          secretFile = s3SecretFile;
        };
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

    # Create credentials files
    system.activationScripts.nextcloud.text =
      let identityFile = "${config.homePath}/.ssh/id_ed25519";
      in ''
        if [ ! -f "${identityFile}" ]; then
          $DRY_RUN_CMD echo -e \nEnter the seed phrase for your SSH key...\n
          $DRY_RUN_CMD echo -e \nThen press ^D when complete.\n\n
          $DRY_RUN_CMD ${pkgs.melt}/bin/melt restore ${identityFile}
          $DRY_RUN_CMD chown ${config.user}:wheel ${identityFile}*
          $DRY_RUN_CMD echo -e \n\nContinuing activation.\n\n
        fi
        if [ ! -f "${adminpassFile}" ]; then
          $DRY_RUN_CMD mkdir --parents $VERBOSE_ARG $(dirname ${adminpassFile})
          $DRY_RUN_CMD ${pkgs.age}/bin/age --decrypt \
            --identity ${identityFile} \
            --output ${adminpassFile} \
            ${builtins.toString ../../private/nextcloud.age}
          $DRY_RUN_CMD chown nextcloud:nextcloud ${adminpassFile}
        fi
        if [ ! -f "${s3SecretFile}" ]; then
          $DRY_RUN_CMD mkdir --parents $VERBOSE_ARG $(dirname ${s3SecretFile})
          $DRY_RUN_CMD ${pkgs.age}/bin/age --decrypt \
            --identity ${identityFile} \
            --output ${s3SecretFile} \
            ${builtins.toString ../../private/nextcloud-s3.age}
          $DRY_RUN_CMD chown nextcloud:nextcloud ${s3SecretFile}
        fi
      '';

  };

}
