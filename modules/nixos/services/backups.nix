# This is my setup for backing up SQlite databases and other systems to S3 or
# S3-equivalent services (like Backblaze B2).

{ config, lib, ... }:
{

  options = {

    backup.s3 = {
      endpoint = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "S3 endpoint for backups";
        default = null;
      };
      bucket = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "S3 bucket for backups";
        default = null;
      };
      accessKeyId = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "S3 access key ID for backups";
        default = null;
      };
      resticBucket = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "S3 bucket for restic backups";
        default = null;
      };
    };
  };

  config = lib.mkIf (config.backup.s3.endpoint != null) {

    users.groups.backup = { };

    secrets.backup = {
      source = ../../../private/backup.age;
      dest = "${config.secretsDirectory}/backup";
      group = "backup";
      permissions = "0440";
    };

    users.users.litestream.extraGroups = [ "backup" ];

    services.litestream = {
      enable = true;
      environmentFile = config.secrets.backup.dest;
      settings = { };
    };

    # Broken on 2024-08-23
    # https://github.com/NixOS/nixpkgs/commit/0875d0ce1c778f344cd2377a5337a45385d6ffa0
    insecurePackages = [ "litestream-0.3.13" ];

    # Wait for secret to exist
    systemd.services.litestream = {
      after = [ "backup-secret.service" ];
      requires = [ "backup-secret.service" ];
      environment.AWS_ACCESS_KEY_ID = config.backup.s3.accessKeyId;
    };

    # # Backup library to object storage
    # services.restic.backups.calibre = {
    #   user = "calibre-web";
    #   repository =
    #     "s3://${config.backup.s3.endpoint}/${config.backup.s3.bucket}/calibre";
    #   paths = [
    #     "/var/books"
    #     "/var/lib/calibre-web/app.db"
    #     "/var/lib/calibre-web/gdrive.db"
    #   ];
    #   initialize = true;
    #   timerConfig = { OnCalendar = "00:05:00"; };
    #   environmentFile = backup.s3File;
    # };

    secrets.s3-glacier = {
      source = ../../../private/s3-glacier.age;
      dest = "${config.secretsDirectory}/s3-glacier";
    };
    secrets.restic = {
      source = ../../../private/restic.age;
      dest = "${config.secretsDirectory}/restic";
    };

    services.restic.backups = lib.mkIf (config.backup.s3.resticBucket != null) {
      default = {
        repository = "s3:s3.us-east-1.amazonaws.com/${config.backup.s3.resticBucket}/restic";
        paths = [ ];
        environmentFile = config.secrets.s3-glacier.dest;
        passwordFile = config.secrets.restic.dest;
        pruneOpts = [
          "--keep-daily 14"
          "--keep-weekly 6"
          "--keep-monthly 12"
          "--keep-yearly 100"
        ];
      };
    };

  };
}
