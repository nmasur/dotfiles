{ config, pkgs, lib, ... }: {

  imports = [ ./secrets.nix ];

  options = {

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

    users.groups.backup = { };

    secrets.backup = {
      source = ../../private/backup.age;
      dest = "${config.secretsDirectory}/backup";
      group = "backup";
      permissions = "0440";
    };

    # # Backup library to object storage
    # services.restic.backups.calibre = {
    #   user = "calibre-web";
    #   repository =
    #     "s3://${config.backupS3.endpoint}/${config.backupS3.bucket}/calibre";
    #   paths = [
    #     "/var/books"
    #     "/var/lib/calibre-web/app.db"
    #     "/var/lib/calibre-web/gdrive.db"
    #   ];
    #   initialize = true;
    #   timerConfig = { OnCalendar = "00:05:00"; };
    #   environmentFile = backupS3File;
    # };

  };

}
