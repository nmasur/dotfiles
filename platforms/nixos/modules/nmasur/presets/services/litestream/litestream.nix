# This is my setup for backing up SQlite databases and other systems to S3 or
# S3-equivalent services (like Backblaze B2).

{ config, lib, ... }:

let
  cfg = config.nmasur.presets.services.litestream;
in
{

  options.nmasur.presets.services.litestream = {
    enable = lib.mkEnableOption "Litestream SQLite backups";
    s3 = {
      endpoint = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "S3 endpoint for Litestream backups";
        default = "s3.us-west-002.backblazeb2.com";
      };
      bucket = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "S3 bucket for Litestream backups";
        default = "noahmasur-backup";
      };
      accessKeyId = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "S3 access key ID for Litestream backups";
        default = "0026b0e73b2e2c80000000005";
      };
      accessKeySecret = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        description = "S3 secret key path for Litestream backups";
        default = ./backup.age;
      };
    };
  };

  config = lib.mkIf (cfg.enable) {

    users.groups.backup = { };

    secrets.litestream-backup = {
      source = cfg.s3.accessKeySecret;
      dest = "${config.secretsDirectory}/backup";
      group = "backup";
      permissions = "0440";
    };

    users.users.litestream.group = "backup";

    services.litestream = {
      enable = true;
      environmentFile = config.secrets.litestream-backup.dest;
      settings = { };
    };

    # Broken on 2024-08-23
    # https://github.com/NixOS/nixpkgs/commit/0875d0ce1c778f344cd2377a5337a45385d6ffa0
    allowInsecurePackages = [ "litestream-0.3.13" ];

    # Wait for secret to exist
    systemd.services.litestream = {
      after = [ "backup-secret.service" ];
      requires = [ "backup-secret.service" ];
      environment.AWS_ACCESS_KEY_ID = cfg.s3.accessKeyId;
    };

  };
}
