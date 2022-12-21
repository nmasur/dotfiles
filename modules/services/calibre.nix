{ config, pkgs, lib, ... }: {

  options = {
    bookServer = lib.mkOption {
      type = lib.types.str;
      description = "Hostname for Calibre library";
      default = null;
    };
  };

  config = lib.mkIf config.bookServer != null {

    services.calibre-web = {
      enable = true;
      openFirewall = true;
      options = {
        reverseProxyAuth.enable = false;
        enableBookConversion = true;
        enableBookUploading = true;
      };
    };

    # Fix: https://github.com/janeczku/calibre-web/issues/2422
    nixpkgs.overlays = [
      (final: prev: {
        calibre-web = prev.calibre-web.overrideAttrs (old: {
          patches = (old.patches or [ ])
            ++ [ ../../patches/calibre-web-cloudflare.patch ];
        });
      })
    ];

    caddy.routes = [{
      match = [{ host = [ config.bookServer ]; }];
      handle = [{
        handler = "reverse_proxy";
        upstreams = [{ dial = "localhost:8083"; }];
        headers.request.add."X-Script-Name" = [ "/calibre-web" ];
      }];
    }];

    # Run a backup on a schedule
    systemd.timers.calibre-backup = {
      timerConfig = {
        OnCalendar = "*-*-* 00:00:00"; # Once per day
        Unit = "calibre-backup.service";
      };
      wantedBy = [ "timers.target" ];
    };

    # Backup Calibre data to object storage
    systemd.services.calibre-backup =
      let libraryPath = "/var/lib/calibre-web"; # Default location
      in {
        description = "Backup Calibre data";
        environment.AWS_ACCESS_KEY_ID = config.backupS3.accessKeyId;
        serviceConfig = {
          Type = "oneshot";
          User = "calibre-web";
          Group = "backup";
          EnvironmentFile = config.secrets.backup.dest;
        };
        script = ''
          ${pkgs.awscli2}/bin/aws s3 sync \
              ${libraryPath}/ \
              s3://${config.backupS3.bucket}/calibre/ \
              --endpoint-url=https://${config.backupS3.endpoint}
        '';
      };

  };

}
