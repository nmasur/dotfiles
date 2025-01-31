{ config, lib, ... }:

let
  cfg = config.nmasur.presets.services.restic;
in
{

  options.nmasur.presets.services.restic = {
    enable = lib.mkEnableOption "Restic backup service";
    resticPassword = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      description = "Password file path for Restic backups";
      default = ../../../../../../private/restic.age;
    };
    s3 = {
      endpoint = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "S3 endpoint for Restic backups";
        default = "s3.us-east-1.amazonaws.com";
      };
      bucket = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "S3 bucket for Restic backups";
        default = null;
      };
      accessKeySecretPair = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        description = "Path to file containing S3 access and secret key for Restic backups";
        default = ../../../../../../private/s3-glacier.age;
      };
    };
  };

  config = lib.mkIf (cfg.enable) {

    secrets.restic-s3-creds = {
      source = cfg.s3.accessKeySecretPair;
      dest = "${config.secretsDirectory}/restic-s3-creds";
    };
    secrets.restic = {
      source = cfg.resticPassword;
      dest = "${config.secretsDirectory}/restic";
    };

    services.restic.backups = {
      default = {
        repository = "s3:${cfg.endpoint}/${cfg.s3.bucket}/restic";
        paths = [ ];
        environmentFile = config.secrets.restic-s3-creds.dest;
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
