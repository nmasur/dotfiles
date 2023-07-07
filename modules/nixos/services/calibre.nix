{ config, pkgs, lib, ... }:

let

  libraryPath = "/data/books";

in {

  options = {
    backups.calibre = lib.mkOption {
      type = lib.types.bool;
      description = "Whether to backup Calibre library";
      default = true;
    };
  };

  config = lib.mkIf config.services.calibre-web.enable {

    services.calibre-web = {
      openFirewall = true;
      options = {
        reverseProxyAuth.enable = false;
        enableBookConversion = true;
        enableBookUploading = true;
        calibreLibrary = libraryPath;
      };
    };

    caddy.routes = [{
      match = [{ host = [ config.hostnames.books ]; }];
      handle = [{
        handler = "reverse_proxy";
        upstreams = [{ dial = "localhost:8083"; }];
        headers.request.add."X-Script-Name" = [ "/calibre-web" ];
      }];
    }];

    # Grant user access to Calibre directories
    users.users.${config.user}.extraGroups = [ "calibre-web" ];

    # Run a backup on a schedule
    systemd.timers.calibre-backup = lib.mkIf config.backups.calibre {
      timerConfig = {
        OnCalendar = "*-*-* 00:00:00"; # Once per day
        Unit = "calibre-backup.service";
      };
      wantedBy = [ "timers.target" ];
    };

    # Backup Calibre data to object storage
    systemd.services.calibre-backup = lib.mkIf config.backups.calibre {
      description = "Backup Calibre data";
      environment.AWS_ACCESS_KEY_ID = config.backup.s3.accessKeyId;
      serviceConfig = {
        Type = "oneshot";
        User = "calibre-web";
        Group = "backup";
        EnvironmentFile = config.secrets.backup.dest;
      };
      script = ''
        ${pkgs.awscli2}/bin/aws s3 sync \
            ${libraryPath}/ \
            s3://${config.backup.s3.bucket}/calibre/ \
            --endpoint-url=https://${config.backup.s3.endpoint}
      '';
    };

  };

}
