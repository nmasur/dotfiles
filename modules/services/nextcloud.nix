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
