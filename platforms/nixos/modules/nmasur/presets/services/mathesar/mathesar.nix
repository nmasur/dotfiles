{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.nmasur.settings) hostnames;
  cfg = config.nmasur.presets.services.mathesar;
in

{

  options.nmasur.presets.services.mathesar = {
    enable = lib.mkEnableOption "Postgres web UI";
    port = lib.mkOption {
      type = lib.types.port;
      description = "Port to use for the localhost";
      default = 8099;
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.services.mathesar = {
      description = "Postgres web UI";
      after = [
        "network.target"
        "postgresql.target"
      ];
      requires = [
        "mathesar-secret.service"
        "mathesar-postgres-secret.service"
      ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        POSTGRES_HOST = "127.0.0.1";
        POSTGRES_DB = "mathesar_django";
        POSTGRES_USER = "mathesar";
        # POSTGRES_PASSWORD = "none";
        POSTGRES_PORT = "5432";
        ALLOWED_HOSTS = "*";
        SKIP_STATIC_COLLECTION = "true";
        DEBUG = "true";
      };
      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        StateDirectory = "mathesar";

        EnvironmentFile = [
          config.secrets.mathesar.dest
          config.secrets.mathesar-postgres.dest
        ];
      };
      preStart = "exec ${pkgs.nmasur.mathesar}/bin/mathesar-install";
      script =
        let
          args = [ "--bind=127.0.0.1:${builtins.toString cfg.port}" ];
        in
        ''
          exec ${pkgs.nmasur.mathesar}/bin/mathesar-gunicorn ${toString args}
        '';
    };

    secrets.mathesar = {
      source = ./mathesar.age;
      dest = "${config.secretsDirectory}/mathesar";
      owner = builtins.toString config.users.users.postgres.uid;
      group = builtins.toString config.users.users.postgres.uid;
    };
    secrets.mathesar-postgres = {
      source = ./mathesar-postgres.age;
      dest = "${config.secretsDirectory}/mathesar-postgres";
      owner = builtins.toString config.users.users.postgres.uid;
      group = builtins.toString config.users.users.postgres.uid;
    };

    # Allow web traffic to Caddy
    nmasur.presets.services.caddy.routes = [
      {
        match = [ { host = [ hostnames.mathesar ]; } ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [ { dial = "localhost:${builtins.toString cfg.port}"; } ];
          }
        ];
      }
    ];

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ hostnames.mathesar ];

  };
}
