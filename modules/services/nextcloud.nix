{ config, pkgs, lib, ... }:

let adminpassFile = "/var/lib/nextcloud/creds";

in {

  imports = [ ./caddy.nix ../shell/age.nix ];

  options = {

    nextcloudServer = lib.mkOption {
      type = lib.types.str;
      description = "Hostname for Nextcloud";
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
    system.activationScripts.nextcloud = {
      deps = [ "age" ];
      text = ''
        if [ ! -f "${adminpassFile}" ]; then
          $DRY_RUN_CMD mkdir --parents $VERBOSE_ARG $(dirname ${adminpassFile})
          $DRY_RUN_CMD ${pkgs.age}/bin/age --decrypt \
            --identity ${config.identityFile} \
            --output ${adminpassFile} \
            ${builtins.toString ../../private/nextcloud.age}
          $DRY_RUN_CMD chown nextcloud:nextcloud ${adminpassFile}
        fi
      '';
    };

  };

}
