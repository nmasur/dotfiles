# Calibre-web is an E-Book library and management tool.

# - Exposed to the public via Caddy.
# - Hostname defined with config.hostnames.books
# - File directory backed up to S3 on a cron schedule.

{
  config,
  pkgs,
  lib,
  ...
}:

let

  cfg = config.nmasur.presets.services.calibre-web;
  libraryPath = "/data/books";
in
{

  options.nmasur.presets.services.calibre-web = {
    enable = lib.mkEnableOption "Calibre-Web e-book manager";
  };

  config = lib.mkIf cfg.enable {

    services.calibre-web = {
      group = lib.mkIf config.nmasur.profiles.shared-media.enable "shared";
      openFirewall = true;
      options = {
        reverseProxyAuth.enable = false;
        enableBookConversion = true;
        enableBookUploading = true;
        calibreLibrary = libraryPath;
      };
    };

    # Allow web traffic to Caddy
    caddy.routes = [
      {
        match = [ { host = [ config.hostnames.books ]; } ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [
              { dial = "localhost:${builtins.toString config.services.calibre-web.listen.port}"; }
            ];
            # This is required when calibre-web is behind a reverse proxy
            # https://github.com/janeczku/calibre-web/issues/19
            headers.request.add."X-Script-Name" = [ "/calibre-web" ];
          }
        ];
      }
    ];

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ config.hostnames.books ];

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
    systemd.services.calibre-backup = {
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
