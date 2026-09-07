# Paperless-ngx is a document scanning and management solution.

{
  config,
  pkgs,
  lib,
  ...
}:

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
      environmentFile = "${config.secretsDirectory}/paperless-env";
      configureTika = true; # Enable processing of emails
      settings = {
        PAPERLESS_OCR_USER_ARGS = builtins.toJSON { invalidate_digital_signatures = true; };
        PAPERLESS_URL = "https://${hostnames.paperless}";
        PAPERLESS_DATE_ORDER = "MDY"; # Check document for US-formatted dates

        # OIDC Authentication with Pocket ID
        PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
        PAPERLESS_REDIRECT_LOGIN_TO_SSO = true;
        PAPERLESS_USE_X_FORWARD_HOST = true;
        PAPERLESS_PROXY_SSL_HEADER = [
          "HTTP_X_FORWARDED_PROTO"
          "https"
        ];
        PAPERLESS_TRUSTED_PROXIES = [
          "127.0.0.1"
          "::1"
        ];

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
      requiredBy = [ "paperless-scheduler.service" ];
      before = [ "paperless-scheduler.service" ];
    };

    secrets.paperless-oidc-secret = {
      source = ./paperless-oidc-secret.age;
      dest = "${config.secretsDirectory}/paperless-oidc-secret";
      owner = "paperless";
      group = "paperless";
      permissions = "0440";
    };
    systemd.services.paperless-oidc-secret-secret = {
      requiredBy = [
        "paperless-secret-key.service"
        "paperless-scheduler.service"
        "paperless-task-queue.service"
        "paperless-consumer.service"
        "paperless-web.service"
      ];
      before = [
        "paperless-secret-key.service"
        "paperless-scheduler.service"
        "paperless-task-queue.service"
        "paperless-consumer.service"
        "paperless-web.service"
      ];
      postStart = ''
        SECRET="$(tr -d '\r\n' < '${config.secrets.paperless-oidc-secret.dest}')"
        JSON=$(${pkgs.jq}/bin/jq -nc \
          --arg secret "$SECRET" \
          --arg auth "https://${hostnames.auth}" \
          '{
            openid_connect: {
              APPS: [
                {
                  provider_id: "pocket-id",
                  name: "Pocket ID",
                  client_id: "e6ff7fce-8e67-4c66-8f32-5ec3db4740a9",
                  secret: $secret,
                  settings: {
                    server_url: $auth,
                    token_auth_method: "client_secret_basic",
                    oauth_pkce_enabled: true,
                    email_authentication: true,
                    verified_email: true
                  }
                }
              ]
            }
          }')
        echo "PAPERLESS_SOCIALACCOUNT_PROVIDERS='$JSON'" > '${config.secretsDirectory}/paperless-env'
        chown paperless:paperless '${config.secretsDirectory}/paperless-env'
        chmod 0440 '${config.secretsDirectory}/paperless-env'
      '';
    };

    # Fix paperless shared permissions
    systemd.services.paperless-web.serviceConfig.UMask = lib.mkForce "0026";
    systemd.services.paperless-scheduler.serviceConfig.UMask = lib.mkForce "0026";
    systemd.services.paperless-task-queue.serviceConfig.UMask = lib.mkForce "0026";

    # Backups
    services.restic.backups.default.paths = [ "/data/generic/paperless/documents" ];

  };
}
