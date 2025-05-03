{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.nmasur.settings) username hostnames;
  cfg = config.nmasur.presets.services.pgweb;
in

{

  options.nmasur.presets.services.pgweb = {
    enable = lib.mkEnableOption "Postgres web UI";
    port = lib.mkOption {
      type = lib.types.port;
      description = "Port to use for the localhost";
      default = 8081;
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.services.pgweb = {
      description = "Postgres web UI";
      after = [
        "postgresql.target"
      ];
      # requires = [ "pgweb-secret.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        DynamicUser = false;
        User = "postgres";
        Group = "postgres";
        StateDirectory = "pgweb";
        ExecStart =
          let
            args = [
              "--url postgres:///hippocampus?host=/run/postgresql"
            ];
          in
          "${lib.getExe pkgs.pgweb} ${toString args}";
      };
    };

    # Allow web traffic to Caddy
    nmasur.presets.services.caddy.routes = [
      {
        match = [ { host = [ hostnames.postgresql ]; } ];
        handle = [
          {
            handler = "authentication";
            providers = {
              http_basic = {
                hash = {
                  algorithm = "bcrypt";
                };
                accounts = [
                  {
                    username = username;
                    password = "$2a$14$dtzWBh7ZDNgqFIJTJO7Rxe15Y189agBiWKZFJbs4sZz7QhqGQAwJS";
                  }
                ];
              };
            };
          }
          {
            handler = "reverse_proxy";
            upstreams = [ { dial = "localhost:${builtins.toString cfg.port}"; } ];
          }
        ];
      }
    ];

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ hostnames.postgresql ];

  };
}
