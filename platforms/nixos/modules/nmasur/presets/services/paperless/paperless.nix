# Paperless-ngx is a document scanning and management solution.

{ config, lib, ... }:

let
  inherit (config.nmasur.settings) hostnames username;
  cfg = config.nmasur.presets.services.paperless;
in
{

  options.nmasur.presets.services.paperless.enable =
    lib.mkEnableOption "Paperless-ngx document manager";

  config = lib.mkIf cfg.enable {

    services.paperless = {
      enable = true;
      mediaDir = "/data/generic/paperless";
      passwordFile = config.secrets.paperless.dest;
      settings = {
        PAPERLESS_OCR_USER_ARGS = builtins.toJSON { invalidate_digital_signatures = true; };
        PAPERLESS_URL = "https://${hostnames.paperless}";

        # Enable if changing the path name in Caddy
        # PAPERLESS_FORCE_SCRIPT_NAME = "/paperless";
        # PAPERLESS_STATIC_URL = "/paperless/static/";
      };
    };

    # Allow Nextcloud and user to see files
    users.users.nextcloud.extraGroups = lib.mkIf config.services.nextcloud.enable [ "paperless" ];
    users.users.${username}.extraGroups = [ "paperless" ];

    nmasur.presets.services.caddy.routes = [
      {
        match = [
          {
            host = [ hostnames.paperless ];
            # path = [ "/paperless*" ]; # Change path name in Caddy
          }
        ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [ { dial = "localhost:${builtins.toString config.services.paperless.port}"; } ];
          }
        ];
      }
    ];

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ hostnames.paperless ];

    secrets.paperless = {
      source = ./paperless.age;
      dest = "${config.secretsDirectory}/paperless";
      owner = "paperless";
      group = "paperless";
      permissions = "0440";
    };
    systemd.services.paperless-secret = {
      requiredBy = [ "paperless.service" ];
      before = [ "paperless.service" ];
    };

    # Fix paperless shared permissions
    systemd.services.paperless-web.serviceConfig.UMask = lib.mkForce "0026";
    systemd.services.paperless-scheduler.serviceConfig.UMask = lib.mkForce "0026";
    systemd.services.paperless-task-queue.serviceConfig.UMask = lib.mkForce "0026";

    # Backups
    services.restic.backups.default.paths = [ "/data/generic/paperless/documents" ];

  };
}
