{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.nmasur.settings) hostnames username;
  cfg = config.nmasur.presets.services.gitea;
  giteaPath = "/var/lib/gitea"; # Default service directory
in
{

  options.nmasur.presets.services.gitea.enable = lib.mkEnableOption "Gitea git server";
  config = lib.mkIf cfg.enable {
    services.gitea = {
      enable = true;
      database.type = "sqlite3";
      settings = {
        actions.ENABLED = true;
        metrics.ENABLED = true;
        mailer.SENDMAIL_PATH = "/run/wrappers/bin/sendmail";
        repository = {
          # Pushing to a repo that doesn't exist automatically creates one as
          # private.
          DEFAULT_PUSH_CREATE_PRIVATE = true;

          # Allow git over HTTP.
          DISABLE_HTTP_GIT = false;

          # Allow requests hitting the specified hostname.
          ACCESS_CONTROL_ALLOW_ORIGIN = hostnames.git;

          # Automatically create viable users/orgs on push.
          ENABLE_PUSH_CREATE_USER = true;
          ENABLE_PUSH_CREATE_ORG = true;

          # Default when creating new repos.
          DEFAULT_BRANCH = "main";
        };
        server = {
          HTTP_PORT = 3001;
          HTTP_ADDRESS = "127.0.0.1";
          ROOT_URL = "https://${hostnames.git}/";
          SSH_PORT = 22;
          START_SSH_SERVER = false; # Use sshd instead
          DISABLE_SSH = false;
        };

        # Don't allow public users to register accounts.
        service.DISABLE_REGISTRATION = true;

        # Force using HTTPS for all session access.
        session.COOKIE_SECURE = true;

        # Hide users' emails.
        ui.SHOW_USER_EMAIL = false;
      };
      extraConfig = null;
    };

    users.users.${username}.extraGroups = [ "gitea" ];

    nmasur.presets.services.caddy.routes = [
      # Prevent public access to Prometheus metrics.
      {
        match = [
          {
            host = [ hostnames.git ];
            path = [ "/metrics*" ];
          }
        ];
        handle = [
          {
            handler = "static_response";
            status_code = "403";
          }
        ];
      }
      # Allow access to primary server.
      {
        match = [ { host = [ hostnames.git ]; } ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [
              { dial = "localhost:${builtins.toString config.services.gitea.settings.server.HTTP_PORT}"; }
            ];
          }
        ];
      }
    ];

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ hostnames.git ];

    # Configure DNS to point to this machine without a proxy
    nmasur.presets.services.cloudflare.noProxyDomains = [ "ssh.${hostnames.git}" ];

    # Scrape the metrics endpoint for Prometheus.
    nmasur.presets.services.prometheus-exporters.scrapeTargets = [
      "127.0.0.1:${builtins.toString config.services.gitea.settings.server.HTTP_PORT}"
    ];

    ## Backup config

    # Open to groups, allowing for backups
    systemd.services.gitea.serviceConfig.StateDirectoryMode = lib.mkForce "0770";
    systemd.tmpfiles.rules = [ "f ${giteaPath}/data/gitea.db 0660 gitea gitea" ];

    # Allow litestream and gitea to share a sqlite database
    users.users.litestream.extraGroups = [ "gitea" ];
    users.users.gitea.extraGroups = [ "litestream" ];

    # Backup sqlite database with litestream
    services.litestream = {
      settings = {
        dbs = [
          {
            path = "${giteaPath}/data/gitea.db";
            replicas = [
              {
                url = "s3://${config.nmasur.presets.services.litestream.s3.bucket}.${config.nmasur.presets.services.litestream.s3.endpoint}/gitea";
              }
            ];
          }
        ];
      };
    };

    # Don't start litestream unless gitea is up
    systemd.services.litestream = {
      after = [ "gitea.service" ];
      requires = [ "gitea.service" ];
    };

    # Run a repository file backup on a schedule
    systemd.timers.gitea-backup =
      lib.mkIf (config.nmasur.presets.services.litestream.s3.endpoint != null)
        {
          timerConfig = {
            OnCalendar = "*-*-* 00:00:00"; # Once per day
            Unit = "gitea-backup.service";
          };
          wantedBy = [ "timers.target" ];
        };

    # Backup Gitea repos to object storage
    systemd.services.gitea-backup = lib.mkIf config.nmasur.presets.services.litestream.enable {
      description = "Backup Gitea data";
      environment.AWS_ACCESS_KEY_ID = config.nmasur.presets.services.litestream.s3.accessKeyId;
      serviceConfig = {
        Type = "oneshot";
        User = "gitea";
        Group = "backup";
        EnvironmentFile = config.secrets.litestream-backup.dest;
      };
      script = ''
        ${pkgs.awscli2}/bin/aws s3 sync --exclude */gitea.db* \
            ${giteaPath}/repositories/ \
            s3://${config.nmasur.presets.services.litestream.s3.bucket}/gitea-data/ \
            --endpoint-url=https://${config.nmasur.presets.services.litestream.s3.endpoint}
      '';
    };
  };
}
